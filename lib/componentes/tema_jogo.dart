import 'package:flutter/material.dart';

// Tema compartilhado pelas telas; não armazena estado da partida.
final temaJogo = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xff4d38a6),
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: const Color(0xff2c2068),
);
