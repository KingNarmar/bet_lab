import 'package:flutter/material.dart';

import 'bet_lab_engine.dart';

class BetLabScreen extends StatefulWidget {
  const BetLabScreen({super.key});

  @override
  State<BetLabScreen> createState() => _BetLabScreenState();
}

class _BetLabScreenState extends State<BetLabScreen> {
  final BetLabEngine _engine = BetLabEngine();

  void _play() {
    setState(() {
      _engine.play();
    });
  }

  void _reset() {
    setState(() {
      _engine.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final BetRoundResult? result = _engine.lastResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BET LAB v1'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _EducationalBanner(),
            const SizedBox(height: 24),
            _MetricCard(
              label: 'Balance',
              value: '${_engine.balance} Credits',
              valueSize: 40,
            ),
            const SizedBox(height: 16),
            _MetricCard(
              label: 'Stake',
              value: '${_engine.stake} Credits',
              valueSize: 28,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _engine.canPlay ? _play : null,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'PLAY',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _ResultCard(result: result),
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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'EDUCATIONAL SIMULATION — FAKE CREDITS ONLY',
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
    required this.valueSize,
  });

  final String label;
  final String value;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: valueSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final BetRoundResult? result;

  @override
  Widget build(BuildContext context) {
    final String text;

    if (result == null) {
      text = 'Ready';
    } else if (result!.isWin) {
      text = 'WIN — Return: ${result!.payout}';
    } else {
      text = 'LOSS — Return: 0';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.engine});

  final BetLabEngine engine;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Rounds Played: ${engine.roundsPlayed}'),
            Text('Total Staked: ${engine.totalStaked}'),
            Text('Total Returned: ${engine.totalReturned}'),
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

  final BetLabEngine engine;

  @override
  Widget build(BuildContext context) {
    final BetRoundResult? result = engine.lastResult;

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
            Text('Seed: ${engine.seed}'),
            Text(
              result == null
                  ? 'Last random: —'
                  : 'Last random: ${result.randomValue.toStringAsFixed(6)}',
            ),
            Text('Win threshold: < ${engine.winProbability}'),
            Text(
              'Expected return: '
              '${(engine.expectedReturnRate * 100).toStringAsFixed(0)}%',
            ),
            Text(
              'Expected net: '
              '${(engine.expectedNetRate * 100).toStringAsFixed(0)}%',
            ),
          ],
        ),
      ),
    );
  }
}
