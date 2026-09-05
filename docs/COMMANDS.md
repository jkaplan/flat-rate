# Commands

Every repeated task in flat-rate has a name. Nothing here needs remembering as a long
invocation.

| Command | What it does |
|---|---|
| `dart test` | **The check command.** Runs every test. Nothing is committed that breaks it |
| `dart test test/ratios_test.dart` | Just the arithmetic, when that is what changed |
| `dart pub get` | Resolve dependencies after editing `pubspec.yaml` |
| `dart analyze` | Static analysis across the package |
| `flutter doctor` | Diagnose the toolchain when something stops working |

## Toolchain

The Flutter SDK lives at `C:\src\flutter`, cloned from the stable branch on 2026-09-05,
and `C:\src\flutter\bin` is on the user PATH. Dart 3.13.2 comes bundled with it — there is
no separate Dart install.

**A stale PATH entry exists.** `C:\flutter\bin` is also on the user PATH and that directory
does not exist. It is inert, because a missing directory resolves to nothing, but it sits
ahead of the real entry and is worth removing before it confuses somebody.

**Trigger:** if an invocation with flags is typed twice, it becomes a named command
before it is typed a third time, and it is listed here.
