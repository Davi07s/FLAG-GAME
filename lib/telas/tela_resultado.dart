import 'package:flutter/material.dart';

import '../componentes/tema_jogo.dart';
import '../modelos/resultado_partida.dart';

class TelaResultado extends StatelessWidget {
  const TelaResultado({
    super.key,
    required this.resultado,
    this.construirNovaPartida,
  });

  final ResultadoPartida resultado;
  final WidgetBuilder? construirNovaPartida;

  @override
  Widget build(BuildContext contexto) {
    final percentual = resultado.percentualAcertos
        .toStringAsFixed(1)
        .replaceAll('.', ',');
    return Theme(
      data: temaJogo,
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
                                  value: resultado.percentualAcertos / 100,
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
                                        '$percentual%',
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
                      'Percentual de acertos: $percentual%',
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
                      builder: (contexto, constraints) {
                        final colunaUnica =
                            constraints.maxWidth < 280 ||
                            MediaQuery.textScalerOf(contexto).scale(20) > 28;
                        final largura = colunaUnica
                            ? constraints.maxWidth
                            : (constraints.maxWidth - 24) / 3;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: largura,
                              child: _EstatisticaResultado(
                                valor: resultado.respondidas,
                                rotulo: 'Respondidas',
                                descricaoAcessivel:
                                    'Respostas: ${resultado.respondidas}',
                                cor: Colors.white,
                              ),
                            ),
                            SizedBox(
                              width: largura,
                              child: _EstatisticaResultado(
                                valor: resultado.acertos,
                                rotulo: 'Acertos',
                                descricaoAcessivel:
                                    'Acertos: ${resultado.acertos}',
                                cor: const Color(0xff31d780),
                              ),
                            ),
                            SizedBox(
                              width: largura,
                              child: _EstatisticaResultado(
                                valor:
                                    resultado.respondidas - resultado.acertos,
                                rotulo: 'Erros',
                                descricaoAcessivel:
                                    'Erros: ${resultado.respondidas - resultado.acertos}',
                                cor: const Color(0xffff5188),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Pontos: ${resultado.pontos}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xffffcf38),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (resultado.respondidas == 0)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                          'Nenhuma resposta foi registrada nesta partida.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xffd4caee)),
                        ),
                      ),
                    const SizedBox(height: 24),
                    if (construirNovaPartida != null) ...[
                      _botaoResultado(
                        'Jogar de novo',
                        const Color(0xff31d780),
                        const Color(0xff1b9255),
                        () {
                          Navigator.pushReplacement<void, void>(
                            contexto,
                            MaterialPageRoute(builder: construirNovaPartida!),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    _botaoResultado(
                      'Voltar ao menu',
                      Colors.white,
                      const Color(0xffaaa4c5),
                      () => Navigator.popUntil(
                        contexto,
                        (route) => route.isFirst,
                      ),
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

  Widget _botaoResultado(
    String rotulo,
    Color cor,
    Color sombra,
    VoidCallback aoPressionar,
  ) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(36),
      boxShadow: [BoxShadow(color: sombra, offset: const Offset(0, 6))],
    ),
    child: FilledButton(
      onPressed: aoPressionar,
      style: FilledButton.styleFrom(
        backgroundColor: cor,
        foregroundColor: const Color(0xff2c2068),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
      ),
      child: Text(
        rotulo,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
      ),
    ),
  );
}

class _EstatisticaResultado extends StatelessWidget {
  const _EstatisticaResultado({
    required this.valor,
    required this.rotulo,
    required this.descricaoAcessivel,
    required this.cor,
  });
  final int valor;
  final String rotulo;
  final String descricaoAcessivel;
  final Color cor;

  @override
  Widget build(BuildContext contexto) => Semantics(
    label: descricaoAcessivel,
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
            '$valor',
            style: TextStyle(
              color: cor,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            rotulo,
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
