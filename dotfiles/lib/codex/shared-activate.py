"""Coordinated OS/app-server activation; run outside the shared service cgroup.

Usage: shared-activate.py --preflight|--activate /absolute/path/activation.json
The configuration and fsynced receipt stay in the operator's private handoff
directory. `interrupt` contains only checkpointed {id, turn_id} pairs that the
coordinator authorized this helper to finish before stopping the service.
"""
import asyncio
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time

from websockets.asyncio.client import unix_connect

ROOT = None
CONFIG = {}


def record(stage, **details):
    with (ROOT / "activation-receipt.jsonl").open("a") as out:
        out.write(json.dumps({"time": time.time(), "stage": stage, **details}) + "\n")
        out.flush()
        os.fsync(out.fileno())


def command(*args, **kwargs):
    try:
        return subprocess.run(args, check=True, text=True, capture_output=True, **kwargs).stdout.strip()
    except subprocess.CalledProcessError as exc:
        record("command-failed", argv=list(args), returncode=exc.returncode,
               stdout=exc.stdout[-16384:], stderr=exc.stderr[-16384:])
        raise RuntimeError(f"{args[0]} exited {exc.returncode}: {exc.stderr.strip()}") from exc


def preflight():
    candidate = Path(CONFIG["candidate"])
    with candidate.open("rb") as binary:
        digest = hashlib.file_digest(binary, "sha256").hexdigest()
    assert digest == CONFIG["candidate_sha256"], "candidate identity changed"
    assert candidate.is_file() and os.access(candidate, os.X_OK)
    checkpoint = Path(CONFIG["peer_checkpoint"]).read_bytes()
    assert hashlib.sha256(checkpoint).hexdigest() == CONFIG["peer_checkpoint_sha256"], "peer checkpoint changed"
    assert Path(CONFIG["selector"]).resolve() == Path(CONFIG["old_runtime"]).parent.parent, "runtime selector changed"
    pid = int(command("systemctl", "--user", "show", CONFIG["unit"], "--property=MainPID", "--value"))
    assert str(Path(f"/proc/{pid}/exe").resolve()) == CONFIG["old_runtime"], "shared runtime changed"
    own_group = Path("/proc/self/cgroup").read_text().strip()
    shared_group = Path(f"/proc/{pid}/cgroup").read_text().strip()
    assert own_group != shared_group, "activation still lives inside shared server"
    record("preflight-passed", activation_pid=os.getpid(), cgroup=own_group, old_pid=pid)


async def quiesce_threads():
    async with unix_connect(CONFIG["socket"], uri="ws://localhost/", compression=None,
                            user_agent_header=None, proxy=None, max_size=8 * 1024 * 1024) as ws:
        sequence = 0

        async def rpc(method, params):
            nonlocal sequence
            sequence += 1
            await ws.send(json.dumps({"id": sequence, "method": method, "params": params}))
            while True:
                response = json.loads(await asyncio.wait_for(ws.recv(), timeout=30))
                if response.get("id") == sequence:
                    if "error" in response:
                        raise RuntimeError({"method": method, "error": response["error"]})
                    return response["result"]

        await rpc("initialize", {"clientInfo": {"name": "shared_server_activation", "version": "1"},
                                 "capabilities": {"experimentalApi": True}})
        await ws.send(json.dumps({"method": "initialized", "params": {}}))
        deadline = asyncio.get_running_loop().time() + 30
        interrupted = False
        while True:
            active = []
            cursor = None
            while True:
                page = await rpc("thread/loaded/list", {"cursor": cursor, "limit": 100})
                for thread_id in page["data"]:
                    result = await rpc("thread/read", {"threadId": thread_id, "includeTurns": False})
                    if result["thread"]["status"]["type"] == "active":
                        active.append(thread_id)
                cursor = page["nextCursor"]
                if cursor is None:
                    break
            if not active:
                record("assistant-turns-idle")
                return
            authorized = {thread["id"] for thread in CONFIG.get("interrupt", [])}
            assert set(active) <= authorized, f"uncheckpointed active assistant turns: {active}"
            if not interrupted:
                for thread in CONFIG.get("interrupt", []):
                    if thread["id"] in active:
                        await rpc("turn/interrupt", {"threadId": thread["id"], "turnId": thread["turn_id"]})
                        record("checkpointed-turn-interrupted", thread_id=thread["id"], turn_id=thread["turn_id"])
                interrupted = True
            assert asyncio.get_running_loop().time() < deadline, f"assistant turns still active: {active}"
            await asyncio.sleep(0.1)


async def resume_threads():
    async with unix_connect(CONFIG["socket"], uri="ws://localhost/", compression=None,
                            user_agent_header=None, proxy=None, max_size=8 * 1024 * 1024) as ws:
        sequence = 0
        observed_activity = set()

        def observe(message):
            params = message.get("params", {})
            method = message.get("method")
            if method == "item/agentMessage/delta" or (
                method == "item/started" and params.get("item", {}).get("type") in
                ("agentMessage", "reasoning", "commandExecution")
            ):
                observed_activity.add((params.get("threadId"), params.get("turnId")))

        async def rpc(method, params):
            nonlocal sequence
            sequence += 1
            await ws.send(json.dumps({"id": sequence, "method": method, "params": params}))
            while True:
                response = json.loads(await asyncio.wait_for(ws.recv(), timeout=90))
                observe(response)
                if response.get("id") == sequence:
                    if "error" in response:
                        raise RuntimeError({"method": method, "error": response["error"]})
                    return response["result"]

        await rpc("initialize", {"clientInfo": {"name": "communication_repair_activation", "version": "1"},
                                 "capabilities": {"experimentalApi": True}})
        await ws.send(json.dumps({"method": "initialized", "params": {}}))
        failures = []
        started = set()
        for thread in CONFIG["resume"]:
            try:
                result = await rpc("thread/resume", {"threadId": thread["id"], "excludeTurns": True})
                assert result["thread"]["id"] == thread["id"]
                turn = await rpc("turn/start", {"threadId": thread["id"],
                    "input": [{"type": "text", "text": thread["message"]}]})
                started.add((thread["id"], turn["turn"]["id"]))
                record("original-thread-start-accepted", thread_id=thread["id"], turn_id=turn["turn"]["id"])
            except Exception as exc:
                failures.append(thread["id"])
                record("thread-reactivation-failed", thread_id=thread["id"], error=str(exc))
        deadline = asyncio.get_running_loop().time() + 120
        pending = set(started)
        while pending:
            for thread_id, turn_id in pending & observed_activity:
                record("original-thread-model-activity-observed", thread_id=thread_id,
                       turn_id=turn_id, autonomousReactivation=True)
            pending -= observed_activity
            if pending:
                remaining = deadline - asyncio.get_running_loop().time()
                assert remaining > 0, f"model activity not observed yet: {pending}"
                observe(json.loads(await asyncio.wait_for(ws.recv(), timeout=remaining)))
        assert not failures, f"unreactivated threads: {failures}"


def activate(mode):
    preflight()
    if mode == "--preflight":
        return
    assert mode == "--activate", "explicit mode required"
    assert not CONFIG.get("preflight_only", True), "activation configuration is not admitted"
    assert CONFIG["candidate"] != CONFIG["old_runtime"], "repair candidate is not configured"
    assert CONFIG["resume"], "original listeners must be resumed"
    asyncio.run(quiesce_threads())
    next_selector = Path(CONFIG["selector"] + ".communication-next")
    assert not next_selector.exists() and not next_selector.is_symlink()
    next_selector.symlink_to(Path(CONFIG["candidate"]).parent.parent)
    env = dict(os.environ)
    env.update({"CODEX_RUNTIME": CONFIG["candidate"],
                "NORTH_CODEX_CONVERSATION_HOME": CONFIG["conversation_home"],
                "NORTH_CODEX_CONVERSATION_SQLITE_HOME": CONFIG["sqlite_home"]})
    try:
        record("restart-starting")
        command("systemctl", "--user", "stop", CONFIG["unit"])
        os.replace(next_selector, CONFIG["selector"])
        endpoint = command(CONFIG["launcher"], env=env)
        assert endpoint == "unix://" + CONFIG["socket"]
        pid = int(command("systemctl", "--user", "show", CONFIG["unit"], "--property=MainPID", "--value"))
        assert str(Path(f"/proc/{pid}/exe").resolve()) == CONFIG["candidate"], "unexpected restarted runtime"
        record("candidate-active", pid=pid, executable=CONFIG["candidate"])
    except Exception as exc:
        record("candidate-start-failed", error=str(exc))
        pid = int(command("systemctl", "--user", "show", CONFIG["unit"], "--property=MainPID", "--value"))
        if pid:
            active = str(Path(f"/proc/{pid}/exe").resolve())
            assert active in (CONFIG["candidate"], CONFIG["old_runtime"]), "unowned replacement server"
            if active == CONFIG["candidate"]:
                command("systemctl", "--user", "stop", CONFIG["unit"])
        if next_selector.is_symlink():
            next_selector.unlink()
        next_selector.symlink_to(Path(CONFIG["old_runtime"]).parent.parent)
        os.replace(next_selector, CONFIG["selector"])
        env["CODEX_RUNTIME"] = CONFIG["old_runtime"]
        endpoint = command(CONFIG["launcher"], env=env)
        assert endpoint == "unix://" + CONFIG["socket"]
        pid = int(command("systemctl", "--user", "show", CONFIG["unit"], "--property=MainPID", "--value"))
        assert str(Path(f"/proc/{pid}/exe").resolve()) == CONFIG["old_runtime"], "previous runtime not restored"
        record("previous-runtime-restored", incident_closed=False)
        asyncio.run(resume_threads())
        record("activation-handoff-complete", outcome="previous-runtime-restored", incident_closed=False)
        raise RuntimeError("candidate activation failed; previous runtime restored and listeners resumed") from exc
    asyncio.run(resume_threads())
    record("activation-handoff-complete", outcome="candidate-active")


if __name__ == "__main__":
    if len(sys.argv) != 3 or sys.argv[1] not in ("--preflight", "--activate"):
        raise SystemExit(__doc__)
    config_path = Path(sys.argv[2]).resolve(strict=True)
    ROOT = config_path.parent
    CONFIG = json.loads(config_path.read_text())
    try:
        activate(sys.argv[1])
    except Exception as exc:
        record("activation-failed", error=str(exc))
        raise
