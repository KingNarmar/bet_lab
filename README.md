# BET LAB

BET LAB is a small Flutter educational simulation built for a documentary-style video about how software design, probability, timing, and presentation can shape a gambling-like experience.

> **This is not a betting product.** It uses fake credits only. There are no deposits, withdrawals, real odds, external betting APIs, or real-money features.

## Current milestone — Crash Mode v1

The current version replaces the old instant WIN / LOSS button with a transparent educational crash-game model:

- 1,000 fake starting credits
- fixed 100-credit stake
- a multiplier that rises from `1.00x`
- a hidden crash point generated at the start of each round
- manual `CASH OUT` before the crash
- crash history
- full session accounting
- developer view that explicitly states when the crash point was generated
- transparent probability rows for `2x`, `5x`, and `10x`

The visual plane does **not** choose the result. The crash point is generated when the round starts; the animation only reveals the already-generated result over time.

## Educational crash distribution

This project uses its own transparent teaching model. It is **not SPRIBE/Aviator source code and is not presented as the proprietary formula of any commercial game**.

For a random value `u` in `[0, 1)`:

```text
raw crash point = RTP / (1 - u)
crash point     = max(1.00, floor(raw * 100) / 100)
```

For a target multiplier `x > 1` this gives approximately:

```text
P(reach x) = RTP / x
```

The filmed baseline intentionally starts with:

```text
RTP = 1.00 = 100%
```

so the first version is mathematically fair. A later documentary experiment can change one line to:

```text
RTP = 0.97 = 97%
```

and compare the long-run expectation without changing the visible game mechanic.

Examples:

| Target | 100% baseline | 97% experiment |
| --- | ---: | ---: |
| 2x | 50.00% chance | 48.50% chance |
| 5x | 20.00% chance | 19.40% chance |
| 10x | 10.00% chance | 9.70% chance |

At a fixed target above `1x`, the model's expected gross return is approximately equal to the configured RTP.

## Randomness

The production lab uses `Random.secure()` and no fixed seed. Tests inject deterministic random values so the probability and accounting rules can be verified without making the filmed app deterministic.

## Run locally

After cloning on a machine with Flutter installed:

```bash
flutter create --platforms=android .
flutter pub get
dart format .
flutter analyze
flutter test
flutter run
```

## Filming layout

Recommended recording layout:

- VS Code: ~60% of the screen
- Android Emulator: ~40%
- editor font around 18–20px
- hide minimap, terminal, and unused panels while narrating
- keep the emulator on the BET LAB screen while coding

## Documentary direction

The crash game is the main visual model for the video. Planned experiments can be layered on top of the transparent baseline:

1. fair `100% RTP` crash baseline
2. explain how the crash point is generated before the animation
3. compare cash-out targets such as `2x`, `5x`, and `10x`
4. change only the RTP parameter and show the mathematical effect
5. examine near-miss perception and crash history
6. compare slower and faster decision loops
7. compare highlighted wins with the full session ledger
8. use a separate Sportsbook Mode to distinguish real-world match outcomes from software pricing and settlement
9. finish with a raw audit view

Patterns that are intentionally harmful will be clearly labeled as **educational demonstrations**, not recommended product behavior.

## License

MIT. See [LICENSE](LICENSE).
