# BET LAB

BET LAB is a small Flutter educational simulation built for a documentary-style video about how software presentation can shape a gambling-like experience.

> **This is not a betting product.** It uses fake credits only. There are no deposits, withdrawals, real odds, external betting APIs, or real-money features.

## Current milestone — v1 Neutral Engine

The first version is deliberately plain and transparent:

- 1,000 fake starting credits
- fixed 100-credit stake
- configurable lab-only win probability (`0.45` by default)
- configurable payout multiplier (`2.0` by default)
- seeded pseudo-random generator for repeatable filming
- neutral WIN / LOSS presentation
- full session accounting
- developer view showing the last random value and threshold
- expected-return calculation visible in the UI

The chosen probability and payout are **illustrative lab settings**, not claims about any real gambling operator.

## Run locally

This repository intentionally keeps generated platform scaffolding out of the initial source snapshot. After cloning on a machine with Flutter installed:

```bash
flutter create --platforms=android .
flutter pub get
flutter test
flutter run
```

The existing `lib/`, `test/`, `pubspec.yaml`, and documentation are the project source of truth.

## Filming layout

Recommended recording layout:

- VS Code: ~60% of the screen
- Android Emulator: ~40%
- enlarge editor font to 18–20px
- hide minimap, terminal, and unused panels
- keep the emulator on the BET LAB screen while coding

## Planned documentary stages

Each behavioral design experiment should be introduced in its own commit so the video can show a real code diff:

1. `v1` — Neutral engine and transparent accounting
2. `v2` — Visually emphasize wins without changing the engine
3. `v3` — Educational partial-return / false-win demonstration
4. `v4` — Educational loss-chasing prompt demonstration
5. `v5` — Compare slow vs fast next-round timing
6. `v6` — Compare selective headline metrics with the full ledger
7. `v7` — Final audit view and resettable documentary lab

Patterns that are intentionally harmful will be clearly labeled in code and UI as **educational demonstrations**, not recommended product behavior.

## Technical note on repeatability

The engine uses `Random(42)` so a filming session can be reset to the same pseudo-random sequence on the same Dart implementation. The UI exposes the generated value so the outcome remains auditable on camera.

## License

MIT. See [LICENSE](LICENSE).
