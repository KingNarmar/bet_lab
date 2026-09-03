import 'dart:math';

class CrashRoundResult {
  const CrashRoundResult({
    required this.stake,
    required this.crashPoint,
    required this.cashOutMultiplier,
    required this.payout,
    required this.balanceAfter,
  });

  final int stake;
  final double crashPoint;
  final double? cashOutMultiplier;
  final int payout;
  final int balanceAfter;

  bool get didCashOut => cashOutMultiplier != null;

  int get net => payout - stake;
}

class CrashLabEngine {
  CrashLabEngine({
    this.startingBalance = 1000,
    this.stake = 100,
    this.rtp = 1.0,
    double Function()? randomDouble,
  })  : assert(startingBalance >= 0),
        assert(stake > 0),
        assert(rtp > 0 && rtp <= 1),
        balance = startingBalance,
        _randomDouble = randomDouble ?? Random.secure().nextDouble;

  final int startingBalance;
  final int stake;

  /// Educational model parameter.
  ///
  /// v1 intentionally starts at 1.0 (100%) so the first filmed baseline is
  /// mathematically fair. A later experiment can change this to 0.97 to show
  /// how a house edge changes the long-run expectation without changing the UI.
  final double rtp;

  final double Function() _randomDouble;

  int balance;
  int totalStaked = 0;
  int totalReturned = 0;
  int roundsPlayed = 0;
  int biggestReturn = 0;

  bool isRoundRunning = false;
  double currentMultiplier = 1.0;
  double? cashOutMultiplier;
  int currentPayout = 0;
  CrashRoundResult? lastRound;

  final List<double> crashHistory = <double>[];

  double? _crashPoint;

  bool get canStartRound => !isRoundRunning && balance >= stake;

  bool get canCashOut => isRoundRunning && cashOutMultiplier == null;

  int get sessionNet => totalReturned - totalStaked;

  double? get revealedCrashPoint =>
      isRoundRunning ? null : lastRound?.crashPoint;

  /// In this educational model, for targets above 1.00x:
  /// P(reach target) = RTP / target.
  double chanceToReach(double target) {
    assert(target >= 1.0);

    if (target <= 1.0) {
      return 1.0;
    }

    return min(1.0, rtp / target);
  }

  double expectedReturnRateAt(double target) {
    return chanceToReach(target) * target;
  }

  bool startRound() {
    if (!canStartRound) {
      return false;
    }

    balance -= stake;
    totalStaked += stake;
    roundsPlayed += 1;

    currentMultiplier = 1.0;
    cashOutMultiplier = null;
    currentPayout = 0;
    _crashPoint = _generateCrashPoint();
    isRoundRunning = true;

    if (_crashPoint! <= 1.0) {
      _finishRound();
    }

    return true;
  }

  void advanceTo(double multiplier) {
    if (!isRoundRunning) {
      return;
    }

    final double nextMultiplier = max(currentMultiplier, multiplier);
    final double crashPoint = _crashPoint!;

    if (nextMultiplier >= crashPoint) {
      currentMultiplier = crashPoint;
      _finishRound();
      return;
    }

    currentMultiplier = nextMultiplier;
  }

  int? cashOut() {
    if (!canCashOut) {
      return null;
    }

    final int payout = (stake * currentMultiplier).round();

    cashOutMultiplier = currentMultiplier;
    currentPayout = payout;
    balance += payout;
    totalReturned += payout;
    biggestReturn = max(biggestReturn, payout);

    return payout;
  }

  void reset() {
    balance = startingBalance;
    totalStaked = 0;
    totalReturned = 0;
    roundsPlayed = 0;
    biggestReturn = 0;
    isRoundRunning = false;
    currentMultiplier = 1.0;
    cashOutMultiplier = null;
    currentPayout = 0;
    lastRound = null;
    crashHistory.clear();
    _crashPoint = null;
  }

  double _generateCrashPoint() {
    final double u = _randomDouble();
    assert(u >= 0 && u < 1);

    // Educational crash distribution, not SPRIBE/Aviator source code.
    // For target x > 1: P(crashPoint >= x) = rtp / x.
    final double rawCrashPoint = rtp / (1.0 - u);
    final double roundedDown = (rawCrashPoint * 100).floor() / 100;

    return max(1.0, roundedDown);
  }

  void _finishRound() {
    final double crashPoint = _crashPoint!;

    isRoundRunning = false;
    currentMultiplier = crashPoint;

    final CrashRoundResult result = CrashRoundResult(
      stake: stake,
      crashPoint: crashPoint,
      cashOutMultiplier: cashOutMultiplier,
      payout: currentPayout,
      balanceAfter: balance,
    );

    lastRound = result;
    crashHistory.insert(0, crashPoint);

    if (crashHistory.length > 8) {
      crashHistory.removeLast();
    }

    _crashPoint = null;
  }
}
