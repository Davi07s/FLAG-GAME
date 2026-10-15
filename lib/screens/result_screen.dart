import 'package:flutter/material.dart';

import '../models/game_result.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final GameResult result;

  @override
  Widget build(BuildContext context) {
    final percentage = result.accuracy.toStringAsFixed(1).replaceAll('.', ',');
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Tempo esgotado!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Text('Respostas: ${result.answered}'),
            Text('Acertos: ${result.correct}'),
            Text('Pontos: ${result.score}'),
            Text('Percentual de acertos: $percentage%'),
            if (result.answered == 0)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Nenhuma resposta foi registrada nesta partida.'),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('Voltar ao menu'),
            ),
          ],
        ),
      ),
    );
  }
}
