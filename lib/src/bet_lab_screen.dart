import 'dart:async';

import 'package:flutter/material.dart';

import 'crash_lab_engine.dart';

class BetLabScreen extends StatefulWidget {
  const BetLabScreen({super.key});

  @override
  State<BetLabScreen> createState() => _BetLabScreenState();
}

class _BetLabScreenState extends State<BetLabScreen> {
  final CrashLabEngine _engine = CrashLabEngine(
    rtp: 1.0,
  );

  Timer? _roundTimer;

  @override
  void dispose() {
    _roundTimer?.cancel();
    super.dispose();
  }

  void _startRound() {
    _roundTimer?.cancel();

    setState(() {
      _engine.startRound();
    });

    if (!_engine.isRoundRunning) {
      return;
    }

    _roundTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (Timer timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          _engine.advanceTo(
            _engine.currentMultiplier * 1.01,
          );
        });

        if (!_engine.isRoundRunning) {
          timer.cancel();
        }
      },
    );
  }

  void _cashOut() {
    setState(() {
      _engine.cashOut();
    });
  }

  void _reset() {
    _roundTimer?.cancel();

    setState(() {
      _engine.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BET LAB — CRASH MODE'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _EducationalBanner(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Balance',
                    value: '${_engine.balance}',
                    suffix: ' Credits',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Stake',
                    value: '${_engine.stake}',
                    suffix: ' Credits',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _FlightStage(engine: _engine),
            const SizedBox(height: 16),
            _RoundStatusCard(engine: _engine),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _engine.canStartRound ? _startRound : null,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'START ROUND',
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: _engine.canCashOut ? _cashOut : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        _engine.canCashOut
                            ? 'CASH OUT ${_engine.currentMultiplier.toStringAsFixed(2)}x'
                            : 'CASH OUT',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _CrashHistoryCard(history: _engine.crashHistory),
            const SizedBox(height: 20),
            _MathCard(engine: _engine),
            const SizedBox(height: 20),
            _SessionCard(engine: _engine),
            const SizedBox(height: 20),
            _DeveloperCard(engine: _engine),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _reset,
              child: const Text('RESET LAB'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EducationalBanner extends StatelessWidget {
  const _EducationalBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'EDUCATIONAL CRASH SIMULATION — FAKE CREDITS ONLY',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onTertiaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.suffix,
  });

  final String label;
  final String value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: suffix),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlightStage extends StatelessWidget {
  const _FlightStage({required this.engine});

  final CrashLabEngine engine;

  @override
  Widget build(BuildContext context) {
    final double multiplier = engine.currentMultiplier;
    final double progress =
        ((1.0 - (1.0 / multiplier)) * 0.90).clamp(0.0, 0.90).toDouble();

    final Alignment planeAlignment = Alignment(
      -0.82 + (1.55 * progress),
      0.72 - (1.30 * progress),
    );

    final bool hasCrashed =
        !engine.isRoundRunning && engine.lastRound != null;

    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: const _TrajectoryPainter(),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: hasCrashed
                ? Align(
                    key: ValueKey<double>(engine.lastRound!.crashPoint),
                    alignment: planeAlignment,
                    child: _ExplosionMarker(
                      crashPoint: engine.lastRound!.crashPoint,
                    ),
                  )
                : AnimatedAlign(
                    key: const ValueKey<String>('flying-plane'),
                    duration: const Duration(milliseconds: 50),
                    curve: Curves.linear,
                    alignment: planeAlignment,
                    child: Icon(
                      Icons.flight_takeoff,
                      size: 54,
                      color:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
          ),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: hasCrashed
                    ? Colors.red.withValues(alpha: 0.78)
                    : Colors.black.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                hasCrashed
                    ? 'CRASH ${multiplier.toStringAsFixed(2)}x'
                    : '${multiplier.toStringAsFixed(2)}x',
                style: TextStyle(
                  fontSize: hasCrashed ? 34 : 46,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplosionMarker extends StatelessWidget {
  const _ExplosionMarker({required this.crashPoint});

  final double crashPoint;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey<String>('explosion-$crashPoint'),
      tween: Tween<double>(begin: 0.55, end: 1.35),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutBack,
      builder: (BuildContext context, double scale, Widget? child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.orange.withValues(alpha: 0.24),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.58),
              blurRadius: 28,
              spreadRadius: 8,
            ),
          ],
        ),
        child: const Icon(
          Icons.local_fire_department,
          size: 62,
          color: Colors.orangeAccent,
        ),
      ),
    );
  }
}

class _TrajectoryPainter extends CustomPainter {
  const _TrajectoryPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..moveTo(size.width * 0.08, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.55,
        size.height * 0.88,
        size.width * 0.90,
        size.height * 0.12,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoundStatusCard extends StatelessWidget {
  const _RoundStatusCard({required this.engine});

  final CrashLabEngine engine;

  @override
  Widget build(BuildContext context) {
    final CrashRoundResult? lastRound = engine.lastRound;
    final String title;
    final String detail;
    final bool showLockedCashOut =
        engine.isRoundRunning && engine.cashOutMultiplier != null;

    if (showLockedCashOut) {
      final int net = engine.currentPayout - engine.stake;
      final String netText = net >= 0 ? '+$net' : '$net';

      title =
          'CASHED OUT — ${engine.cashOutMultiplier!.toStringAsFixed(2)}x';
      detail =
          'Return ${engine.currentPayout} · Net $netText · plane still flying';
    } else if (engine.isRoundRunning) {
      title = 'ROUND RUNNING';
      detail = 'Cash out before the crash point is reached.';
    } else if (lastRound == null) {
      title = 'READY';
      detail = 'Start a round to generate a hidden crash point.';
    } else {
      title = 'CRASH — ${lastRound.crashPoint.toStringAsFixed(2)}x';

      if (lastRound.didCashOut) {
        final int net = lastRound.net;
        final String netText = net >= 0 ? '+$net' : '$net';

        detail =
            'Your cash out stayed locked at ${lastRound.cashOutMultiplier!.toStringAsFixed(2)}x · '
            'Return ${lastRound.payout} · Net $netText';
      } else {
        detail = 'No cash out before the crash · Return 0 · Net -${lastRound.stake}';
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CrashHistoryCard extends StatelessWidget {
  const _CrashHistoryCard({required this.history});

  final List<double> history;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Crash History',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (history.isEmpty)
              const Text('No completed rounds yet.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: history
                    .map(
                      (double value) => Chip(
                        label: Text('${value.toStringAsFixed(2)}x'),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _MathCard extends StatelessWidget {
  const _MathCard({required this.engine});

  final CrashLabEngine engine;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transparent Math',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('RTP model: ${(engine.rtp * 100).toStringAsFixed(0)}%'),
            const Text('For target x > 1:  P(reach x) = RTP / x'),
            const SizedBox(height: 8),
            _ProbabilityRow(
              target: 2,
              chance: engine.chanceToReach(2),
              expectedReturn: engine.expectedReturnRateAt(2),
            ),
            _ProbabilityRow(
              target: 5,
              chance: engine.chanceToReach(5),
              expectedReturn: engine.expectedReturnRateAt(5),
            ),
            _ProbabilityRow(
              target: 10,
              chance: engine.chanceToReach(10),
              expectedReturn: engine.expectedReturnRateAt(10),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProbabilityRow extends StatelessWidget {
  const _ProbabilityRow({
    required this.target,
    required this.chance,
    required this.expectedReturn,
  });

  final double target;
  final double chance;
  final double expectedReturn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '${target.toStringAsFixed(0)}x → '
        '${(chance * 100).toStringAsFixed(2)}% reach chance · '
        '${(expectedReturn * 100).toStringAsFixed(0)}% expected return',
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.engine});

  final CrashLabEngine engine;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session Audit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Rounds Played: ${engine.roundsPlayed}'),
            Text('Total Staked: ${engine.totalStaked}'),
            Text('Total Returned: ${engine.totalReturned}'),
            Text('Biggest Return: ${engine.biggestReturn}'),
            Text(
              'Net Result: ${engine.sessionNet}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeveloperCard extends StatelessWidget {
  const _DeveloperCard({required this.engine});

  final CrashLabEngine engine;

  @override
  Widget build(BuildContext context) {
    final String crashPointText;

    if (engine.isRoundRunning) {
      crashPointText = 'HIDDEN UNTIL ROUND ENDS';
    } else if (engine.revealedCrashPoint == null) {
      crashPointText = '—';
    } else {
      crashPointText = '${engine.revealedCrashPoint!.toStringAsFixed(2)}x';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Developer View',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Random source: Random.secure()'),
            Text('RTP parameter: ${engine.rtp.toStringAsFixed(2)}'),
            Text(
              'Round state: ${engine.isRoundRunning ? 'RUNNING' : 'IDLE'}',
            ),
            Text('Crash point: $crashPointText'),
            const Text('Crash point is generated when START ROUND is pressed.'),
            const Text('The plane animation does not choose the result.'),
          ],
        ),
      ),
    );
  }
}
