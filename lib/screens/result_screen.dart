import 'package:flutter/material.dart';

import '../models/game_result.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result, this.replayBuilder});

  final GameResult result;
  final WidgetBuilder? replayBuilder;

  @override
  Widget build(BuildContext context) {
    final percentage = result.accuracy.toStringAsFixed(1).replaceAll('.', ',');
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff4d38a6),
          brightness: Brightness.dark,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xff2c2068),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 36,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Resultado',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xffd4caee)),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Fim de jogo!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xffffcf38),
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            color: Color(0xff1c1549),
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tempo esgotado!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xffd4caee)),
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned.fill(
                                child: CircularProgressIndicator(
                                  value: result.accuracy / 100,
                                  strokeWidth: 22,
                                  strokeCap: StrokeCap.round,
                                  color: const Color(0xff31d780),
                                  backgroundColor: const Color(0xff4d38a6),
                                  semanticsLabel: 'Percentual de acertos',
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '$percentage%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 52,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      'de acertos',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xffd4caee),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Percentual de acertos: $percentage%',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xffd4caee)),
                    ),
                    const SizedBox(height: 16),
                    const ExcludeSemantics(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Color(0xffffcf38),
                            size: 48,
                          ),
                          Icon(
                            Icons.star_rounded,
                            color: Color(0xffffcf38),
                            size: 48,
                          ),
                          Icon(
                            Icons.star_rounded,
                            color: Color(0xffffcf38),
                            size: 48,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final singleColumn =
                            constraints.maxWidth < 280 ||
                            MediaQuery.textScalerOf(context).scale(20) > 28;
                        final width = singleColumn
                            ? constraints.maxWidth
                            : (constraints.maxWidth - 24) / 3;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: width,
                              child: _ResultStat(
                                value: result.answered,
                                label: 'Respondidas',
                                semanticsLabel: 'Respostas: ${result.answered}',
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: _ResultStat(
                                value: result.correct,
                                label: 'Acertos',
                                semanticsLabel: 'Acertos: ${result.correct}',
                                color: const Color(0xff31d780),
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: _ResultStat(
                                value: result.answered - result.correct,
                                label: 'Erros',
                                semanticsLabel:
                                    'Erros: ${result.answered - result.correct}',
                                color: const Color(0xffff5188),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Pontos: ${result.score}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xffffcf38),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (result.answered == 0)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                          'Nenhuma resposta foi registrada nesta partida.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xffd4caee)),
                        ),
                      ),
                    const SizedBox(height: 24),
                    if (replayBuilder != null) ...[
                      _resultButton(
                        'Jogar de novo',
                        const Color(0xff31d780),
                        const Color(0xff1b9255),
                        () {
                          Navigator.pushReplacement<void, void>(
                            context,
                            MaterialPageRoute(builder: replayBuilder!),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    _resultButton(
                      'Voltar ao menu',
                      Colors.white,
                      const Color(0xffaaa4c5),
                      () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultButton(
    String label,
    Color color,
    Color shadow,
    VoidCallback onPressed,
  ) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(36),
      boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 6))],
    ),
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: const Color(0xff2c2068),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
      ),
    ),
  );
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({
    required this.value,
    required this.label,
    required this.semanticsLabel,
    required this.color,
  });
  final int value;
  final String label;
  final String semanticsLabel;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticsLabel,
    excludeSemantics: true,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xff4d38a6),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Color(0xff1c1549), offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xffd4caee),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
