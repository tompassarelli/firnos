# Capacity leases and limits

## Why admission is shared

Idle agent slots do not measure local CPU or memory capacity. A shared atomic
lease prevents several individually reasonable commands from starting together
and exhausting interactive headroom. Cgroups bound descendants as well as the
original command; an estimated duration does not provide that containment.

## Worker leases

Resolve the helper as in the distilled guide. Reserve before admitting a
compute-using child, renew before its bound expires, and retain the release:

```bash
bun "$capacity" reserve --class agent --owner "codex:/root/task" --timeout-seconds 1800
bun "$capacity" renew --lease LEASE --owner "codex:/root/task" --timeout-seconds 1800
bun "$capacity" release --lease LEASE --owner "codex:/root/task"
```

These values illustrate a bounded run, not a deadline prediction. Persistent
reservation is limited to `agent`; all larger classes use `run`.
A settled child missing release evidence leaves the parent responsible for
releasing the exact known lease. A prose report is not a release receipt.

## Headroom and pressure

The helper reserves 25% of CPUs and memory headroom of at least 20% and 4 GiB.
It defers work at CPU PSI of 20% or more over ten seconds, insufficient
available memory, or memory lease budgets above 75% of host capacity.
Every local job joins `agent-capacity.slice`, whose aggregate CPU quota is 75%
of host CPUs. The sum of per-job CPU ceilings may exceed that quota: sleeping
or serial jobs do not consume their ceilings continuously. Agent reservations
retain their 768 MiB memory budget without charging remote inference as local
CPU work. Admission reports CPU pressure separately from CPU ceilings and the
aggregate limit; a reserved ceiling is not a utilization measurement.

Exclusive work requires no other local run lease and prevents new local runs
until release; agent memory reservations may coexist. A run lease outside the
aggregate limit defers new local jobs until its owner finishes. Activation
must therefore wait for old helper invocations to drain; never move or kill
peer jobs to activate this policy.
Full-memory PSI remains diagnostic telemetry: cgroup-local throttling can
raise it without exhausting host headroom, so it does not independently veto
admission. Per-job CPU, memory, and runtime bounds still apply.
The helper implementation owns these thresholds; inspect it
when changing admission behavior rather than adding a parallel calculator.

Expired leases are reclaimable helper state and matching scopes have the same
hard runtime bound. Unleased pressure is different: defer heavy work, identify
the exact process owner with bounded native metadata, and leave signaling to
that owner or accountable parent.

## Alternatives and limits

Manual process censuses are neither atomic admission nor process ownership.
A daemon, dashboard, temperature poller, or recurring census adds no needed
guarantee to this protocol. Pay for admission at start and release at settlement.
Do not mistake a large timeout for evidence that useful progress continues.
