import 'package:flutter/material.dart';

import 'src/bet_lab_screen.dart';

void main() {
  runApp(const BetLabApp());
}

class BetLabApp extends StatelessWidget {
  const BetLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BET LAB',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const BetLabScreen(),
    );
  }
}
