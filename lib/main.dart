import 'package:flutter/material.dart';

import 'telas/tela_inicial.dart';

void main() => runApp(const AplicativoBandeiras());

class AplicativoBandeiras extends StatelessWidget {
  const AplicativoBandeiras({super.key});

  @override
  Widget build(BuildContext contexto) => MaterialApp(
    debugShowCheckedModeBanner: false, //remove faixa de debug
    title: 'Flag Game',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    ),
    home: const TelaInicial(), //tela inicial do jogo
  );
}
