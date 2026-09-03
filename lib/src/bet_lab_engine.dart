import 'dart:math';

class BetRoundResult {
  const BetRoundResult({
    required this.stake,
    required this.payout,
    required this.randomValue,
    required this.isWin,
    required this.balanceAfter,
  });

  final int stake;
  final int payout;
  final double randomValue;
  final bool isWin;
  final int balanceAfter;

  int get net => payout - stake;
}

class BetLabEngine {
  BetLabEngine({
    this.startingBalance = 1000,
    this.stake = 100,
    this.winProbability = 0.45,
    this.payoutMultiplier = 2.0,
    this.seed = 42,
  })  : assert(startingBalance >= 0),
        assert(stake > 0),
        assert(winProbability >= 0 && winProbability <= 1),
        assert(payoutMultiplier >= 0),
        balance = startingBalance,
        _random = Random(seed);

  final int startingBalance;
  final int stake;
  final double winProbability;
  final double payoutMultiplier;
  final int seed;

  Random _random;

  int balance;
  int totalStaked = 0;
  int totalReturned = 0;
  int roundsPlayed = 0;
  BetRoundResult? lastResult;

  double get expectedReturnRate => winProbability * payoutMultiplier;

  double get expectedNetRate => expectedReturnRate - 1;

  int get sessionNet => totalReturned - totalStaked;

  bool get canPlay => balance >= stake;

  BetRoundResult? play() {
    if (!canPlay) {
      return null;
    }

    final double randomValue = _random.nextDouble();
    final bool isWin = randomValue < winProbability;
    final int payout = isWin ? (stake * payoutMultiplier).round() : 0;

    balance -= stake;
    totalStaked += stake;

    balance += payout;
    totalReturned += payout;
    roundsPlayed += 1;

    final BetRoundResult result = BetRoundResult(
      stake: stake,
      payout: payout,
      randomValue: randomValue,
      isWin: isWin,
      balanceAfter: balance,
    );

    lastResult = result;
    return result;
  }

  void reset() {
    _random = Random(seed);
    balance = startingBalance;
    totalStaked = 0;
    totalReturned = 0;
    roundsPlayed = 0;
    lastResult = null;
  }
}
