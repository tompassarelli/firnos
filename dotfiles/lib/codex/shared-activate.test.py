"""Isolated systemd regression: CODEX_TEST_RUNTIME must name an installed Codex binary.

Uses private empty conversation data, never the live user's shared unit. No model
turn is submitted; original-listener continuation remains an activation canary.
"""
import asyncio
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import socket
import subprocess
import tempfile
import time
from unittest.mock import AsyncMock, patch

SOURCE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("activation", SOURCE / "shared-activate.py")
activation = importlib.util.module_from_spec(spec)
spec.loader.exec_module(activation)
runtime = Path(os.environ["CODEX_TEST_RUNTIME"]).resolve(strict=True)
launcher = SOURCE.parent.parent / "bin/codex-shared-server"


def command(*args, **kwargs):
    return subprocess.run(args, check=True, text=True, capture_output=True, **kwargs).stdout.strip()


def wait_inactive(unit):
    deadline = time.monotonic() + 10
    while command("systemctl", "--user", "show", unit, "-p", "ActiveState", "--value") not in ("inactive", "failed"):
        assert time.monotonic() < deadline, "isolated service did not stop"
        time.sleep(0.05)


class ActiveThreadApi:
    def __init__(self):
        self.active = True
        self.requests = []

    async def __aenter__(self):
        return self

    async def __aexit__(self, *args):
        pass

    async def send(self, message):
        self.request = json.loads(message)
        self.requests.append(self.request)

    async def recv(self):
        method = self.request["method"]
        result = {}
        if method == "thread/loaded/list":
            result = {"data": ["checkpointed"], "nextCursor": None}
        elif method == "thread/read":
            result = {"thread": {"status": {"type": "active" if self.active else "idle"}}}
        elif method == "turn/interrupt":
            assert self.request["params"] == {"threadId": "checkpointed", "turnId": "current-turn"}
            self.active = False
        return json.dumps({"id": self.request["id"], "result": result})


with tempfile.TemporaryDirectory(prefix="codex-shared-recovery-") as temporary:
    root = Path(temporary)
    pool = root / "pool"
    pool.mkdir()
    sqlite = pool / "sqlite"
    env = dict(os.environ, NORTH_CODEX_CONVERSATION_HOME=str(pool),
               NORTH_CODEX_CONVERSATION_SQLITE_HOME=str(sqlite), CODEX_RUNTIME=str(runtime))
    home_key = hashlib.sha256(f"{pool}\n{sqlite}".encode()).hexdigest()[:16]
    directory = Path(os.environ["XDG_RUNTIME_DIR"]) / f"codex-shared-{home_key}"
    endpoint = "unix://" + str(directory / "app-server.sock")
    unit = f"codex-shared-{home_key}.service"
    assert unit != "codex-shared-a29cde0b1fc2a000.service"
    try:
        assert command(str(launcher), env=env) == endpoint
        command("systemctl", "--user", "kill", "--kill-whom=main", "--signal=SIGKILL", unit)
        wait_inactive(unit)
        assert not directory.exists(), "systemd did not remove killed owner's socket directory"
        assert command(str(launcher), env=env) == endpoint
        command("systemctl", "--user", "stop", unit)
        wait_inactive(unit)
        directory.mkdir(mode=0o700)
        with socket.socket(socket.AF_UNIX) as stale:
            stale.bind(str(directory / "app-server.sock"))
        assert command(str(launcher), env=env) == endpoint
        print("PASS: SIGKILL cleanup, same-endpoint restart, and legacy dead-socket recovery")

        candidate = root / "bad/bin/codex"
        candidate.parent.mkdir(parents=True)
        candidate.write_text("#!/usr/bin/env bash\necho 'injected candidate startup failure' >&2\nexit 42\n")
        candidate.chmod(0o700)
        selector = root / "current"
        selector.symlink_to(runtime.parent.parent)
        checkpoint = root / "checkpoint"
        checkpoint.write_text("isolated service has no model turns\n")
        activation.ROOT = root
        activation.CONFIG = {
            "candidate": str(candidate), "candidate_sha256": hashlib.sha256(candidate.read_bytes()).hexdigest(),
            "old_runtime": str(runtime), "selector": str(selector), "unit": unit,
            "socket": str(directory / "app-server.sock"), "launcher": str(launcher),
            "conversation_home": str(pool), "sqlite_home": str(sqlite),
            "peer_checkpoint": str(checkpoint), "peer_checkpoint_sha256": hashlib.sha256(checkpoint.read_bytes()).hexdigest(),
            "resume": [{"id": "isolated-continuation-boundary", "message": "no model call"}],
            "preflight_only": False,
        }
        api = ActiveThreadApi()
        with patch.object(activation, "unix_connect", return_value=api):
            try:
                asyncio.run(activation.quiesce_threads())
            except AssertionError as error:
                assert "uncheckpointed active assistant turns" in str(error)
            else:
                raise AssertionError("unknown active turn was admitted")
            assert all(request["method"] != "turn/interrupt" for request in api.requests)
            activation.CONFIG["interrupt"] = [{"id": "checkpointed", "turn_id": "current-turn"}]
            asyncio.run(activation.quiesce_threads())
            assert not api.active
        activation.CONFIG.pop("interrupt")
        print("PASS: uncheckpointed active turns remain untouched; exact authorized turn is interrupted and becomes idle")
        with patch.object(activation, "resume_threads", new_callable=AsyncMock) as resume:
            try:
                activation.activate("--activate")
            except RuntimeError as error:
                assert "previous runtime restored and listeners resumed" in str(error), str(error)
            else:
                raise AssertionError("failed candidate reported success")
            resume.assert_awaited_once()
        assert selector.resolve() == runtime.parent.parent
        asyncio.run(activation.quiesce_threads())
        receipts = [json.loads(line) for line in (root / "activation-receipt.jsonl").read_text().splitlines()]
        failures = [entry for entry in receipts if entry["stage"] == "command-failed"]
        assert len(failures) == 1, failures
        assert "shared server exited before becoming ready" in failures[0]["stderr"], failures
        assert any(entry["stage"] == "previous-runtime-restored" for entry in receipts)
        print("PASS: failed candidate restores selector, running old executable, and API availability; receipt preserves launcher stderr")
    finally:
        subprocess.run(["systemctl", "--user", "stop", unit], capture_output=True)
        lock = Path(os.environ["XDG_RUNTIME_DIR"]) / f"codex-shared-{home_key}.lock"
        lock.unlink(missing_ok=True)
