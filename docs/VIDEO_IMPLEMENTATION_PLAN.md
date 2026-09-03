# Video implementation plan

The project evolves by code commits rather than by pretending to type finished code on camera.

## Recording principle

For each stage:

1. show the relevant code in VS Code;
2. explain exactly what the code changes;
3. hot reload / hot restart;
4. trigger the behavior in the Android emulator;
5. pause on the result and explain the behavioral effect;
6. show that the core probability/payout configuration did not change unless the experiment explicitly says so.

## Stage 1 — neutral baseline

Files:

- `lib/src/bet_lab_engine.dart`
- `lib/src/bet_lab_screen.dart`

The baseline intentionally exposes:

- random value;
- win threshold;
- total staked;
- total returned;
- net result;
- expected return and expected net for the lab configuration.

This gives the audience an auditable reference point before any presentation experiments are introduced.
