# flat-rate

A private work record for a flat-rate automotive technician: what was flagged, what was
actually spent, and — the current goal — whether it matches what showed up on the
paycheck. Kept by the technician, for the technician.

**A Flutter app exists and runs**, but the milestone it was built for changed direction
partway through, before its own gate ever returned a result. See
[docs/HANDOFF.md](docs/HANDOFF.md) for the honest version of where that leaves things. The
riskiest assumption underneath all of it — that a technician will record actual time at
all — is still untested. A week of paper decides that, and still gates everything.

## Run it

```
flutter run
```

Needs the Flutter SDK on PATH and a connected Android device or emulator. See
[docs/COMMANDS.md](docs/COMMANDS.md) for the full command list and where the SDK lives on
this machine.

## Docs

| Page | What it covers |
|---|---|
| [docs/HANDOFF.md](docs/HANDOFF.md) | State as of the last session, and what is not yet trustworthy — read this first |
| [docs/PLAN.md](docs/PLAN.md) | The living plan and the assumptions table |
| [docs/plans/build-m1-reconciliation.md](docs/plans/build-m1-reconciliation.md) | The current build contract: a work record that reconciles against a statement |
| [docs/plans/scope-change-proposal-2026-09-05.md](docs/plans/scope-change-proposal-2026-09-05.md) | Why the direction changed, argued in full |
| [docs/plans/paper-week.md](docs/plans/paper-week.md) | The still-unrun probe that gates the build |
| [docs/TASKS.md](docs/TASKS.md) | What is queued, waiting, parked and done |
| [docs/COMMANDS.md](docs/COMMANDS.md) | Every command, and what it is for |
