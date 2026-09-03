import 'package:bet_lab/src/bet_lab_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BetLabEngine', () {
    test('starts with transparent neutral defaults', () {
      final BetLabEngine engine = BetLabEngine();

      expect(engine.balance, 1000);
      expect(engine.stake, 100);
      expect(engine.winProbability, 0.45);
      expect(engine.payoutMultiplier, 2.0);
      expect(engine.roundsPlayed, 0);
      expect(engine.totalStaked, 0);
      expect(engine.totalReturned, 0);
      expect(engine.sessionNet, 0);
      expect(engine.expectedReturnRate, closeTo(0.9, 0.000001));
      expect(engine.expectedNetRate, closeTo(-0.1, 0.000001));
    });

    test('every played round preserves the accounting identity', () {
      final BetLabEngine engine = BetLabEngine();

      for (int i = 0; i < 10 && engine.canPlay; i += 1) {
        final BetRoundResult? result = engine.play();

        expect(result, isNotNull);
        expect(result!.stake, 100);
        expect(result.payout == 0 || result.payout == 200, isTrue);
        expect(result.randomValue, greaterThanOrEqualTo(0));
        expect(result.randomValue, lessThan(1));
        expect(result.isWin, result.randomValue < engine.winProbability);
        expect(
          engine.balance,
          engine.startingBalance + engine.sessionNet,
        );
      }
    });

    test('does not play when the balance is below the stake', () {
      final BetLabEngine engine = BetLabEngine(
        startingBalance: 50,
        stake: 100,
      );

      expect(engine.canPlay, isFalse);
      expect(engine.play(), isNull);
      expect(engine.balance, 50);
      expect(engine.roundsPlayed, 0);
    });

    test('reset restores the seeded session state', () {
      final BetLabEngine engine = BetLabEngine();

      final BetRoundResult firstRun = engine.play()!;
      engine.play();
      engine.reset();
      final BetRoundResult secondRun = engine.play()!;

      expect(engine.roundsPlayed, 1);
      expect(secondRun.randomValue, firstRun.randomValue);
      expect(secondRun.isWin, firstRun.isWin);
    });
  });
}
