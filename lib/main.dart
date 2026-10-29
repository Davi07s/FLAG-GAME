import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Flag Game',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    ),
    home: const HomeScreen(), //tela inicial do jogo
  );
}
