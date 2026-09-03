import 'package:bet_lab/src/crash_lab_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrashLabEngine', () {
    test('starts with a mathematically fair 100% RTP baseline', () {
      final CrashLabEngine engine = CrashLabEngine(
        randomDouble: () => 0.5,
      );

      expect(engine.balance, 1000);
      expect(engine.stake, 100);
      expect(engine.rtp, 1.0);
      expect(engine.roundsPlayed, 0);
      expect(engine.totalStaked, 0);
      expect(engine.totalReturned, 0);
      expect(engine.sessionNet, 0);
      expect(engine.chanceToReach(2), closeTo(0.5, 0.000001));
      expect(engine.chanceToReach(5), closeTo(0.2, 0.000001));
      expect(engine.chanceToReach(10), closeTo(0.1, 0.000001));
      expect(engine.expectedReturnRateAt(2), closeTo(1.0, 0.000001));
      expect(engine.expectedReturnRateAt(5), closeTo(1.0, 0.000001));
      expect(engine.expectedReturnRateAt(10), closeTo(1.0, 0.000001));
    });

    test('fair model generates a 2.00x crash for u = 0.5', () {
      final CrashLabEngine engine = CrashLabEngine(
        randomDouble: () => 0.5,
      );

      expect(engine.startRound(), isTrue);
      expect(engine.isRoundRunning, isTrue);
      expect(engine.revealedCrashPoint, isNull);

      engine.advanceTo(10);

      expect(engine.isRoundRunning, isFalse);
      expect(engine.lastRound!.crashPoint, 2.0);
      expect(engine.revealedCrashPoint, 2.0);
    });

    test('97% model generates a 1.94x crash for u = 0.5', () {
      final CrashLabEngine engine = CrashLabEngine(
        rtp: 0.97,
        randomDouble: () => 0.5,
      );

      engine.startRound();
      engine.advanceTo(10);

      expect(engine.lastRound!.crashPoint, 1.94);
      expect(engine.chanceToReach(2), closeTo(0.485, 0.000001));
      expect(engine.chanceToReach(5), closeTo(0.194, 0.000001));
      expect(engine.chanceToReach(10), closeTo(0.097, 0.000001));
      expect(engine.expectedReturnRateAt(2), closeTo(0.97, 0.000001));
      expect(engine.expectedReturnRateAt(5), closeTo(0.97, 0.000001));
      expect(engine.expectedReturnRateAt(10), closeTo(0.97, 0.000001));
    });

    test('97% model can crash immediately at 1.00x', () {
      final CrashLabEngine engine = CrashLabEngine(
        rtp: 0.97,
        randomDouble: () => 0.0,
      );

      expect(engine.startRound(), isTrue);

      expect(engine.isRoundRunning, isFalse);
      expect(engine.lastRound!.crashPoint, 1.0);
      expect(engine.lastRound!.payout, 0);
      expect(engine.balance, 900);
      expect(engine.totalStaked, 100);
      expect(engine.totalReturned, 0);
      expect(engine.sessionNet, -100);
    });

    test('cash out locks payout while the round keeps running', () {
      final CrashLabEngine engine = CrashLabEngine(
        randomDouble: () => 0.75,
      );

      engine.startRound();
      engine.advanceTo(2.0);

      final int? payout = engine.cashOut();

      expect(payout, 200);
      expect(engine.cashOutMultiplier, 2.0);
      expect(engine.isRoundRunning, isTrue);
      expect(engine.currentMultiplier, 2.0);
      expect(engine.balance, 1100);
      expect(engine.totalStaked, 100);
      expect(engine.totalReturned, 200);
      expect(engine.sessionNet, 100);
      expect(
        engine.balance,
        engine.startingBalance + engine.sessionNet,
      );

      engine.advanceTo(3.0);

      expect(engine.isRoundRunning, isTrue);
      expect(engine.currentMultiplier, 3.0);
      expect(engine.cashOutMultiplier, 2.0);
      expect(engine.currentPayout, 200);

      engine.advanceTo(10);

      expect(engine.isRoundRunning, isFalse);
      expect(engine.lastRound!.crashPoint, 4.0);
      expect(engine.lastRound!.cashOutMultiplier, 2.0);
      expect(engine.lastRound!.payout, 200);
    });

    test('cannot cash out after the crash', () {
      final CrashLabEngine engine = CrashLabEngine(
        randomDouble: () => 0.5,
      );

      engine.startRound();
      engine.advanceTo(2.0);

      expect(engine.isRoundRunning, isFalse);
      expect(engine.cashOut(), isNull);
      expect(engine.balance, 900);
      expect(engine.sessionNet, -100);
    });

    test('reset restores the complete educational session state', () {
      final CrashLabEngine engine = CrashLabEngine(
        randomDouble: () => 0.75,
      );

      engine.startRound();
      engine.advanceTo(2.0);
      engine.cashOut();
      engine.advanceTo(10);
      engine.reset();

      expect(engine.balance, 1000);
      expect(engine.roundsPlayed, 0);
      expect(engine.totalStaked, 0);
      expect(engine.totalReturned, 0);
      expect(engine.biggestReturn, 0);
      expect(engine.sessionNet, 0);
      expect(engine.currentMultiplier, 1.0);
      expect(engine.lastRound, isNull);
      expect(engine.crashHistory, isEmpty);
      expect(engine.isRoundRunning, isFalse);
    });
  });
}
