import 'package:flutter/material.dart';

import '../componentes/tema_jogo.dart';
import '../modelos/pais.dart';

class TelaContinentes extends StatelessWidget {
  const TelaContinentes({super.key});

  @override
  Widget build(BuildContext contexto) {
    return Theme(
      data: temaJogo,
      child: Scaffold(
        backgroundColor: const Color(0xff2c2068),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: -55,
              top: 150,
              child: Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: Color(0xff713174),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -65,
              bottom: 160,
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: Color(0xff305793),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            IconButton.filled(
                              onPressed: () => Navigator.pop(contexto),
                              tooltip: 'Voltar ao menu',
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xff4d38a6),
                              ),
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Escolha o continente',
                                style: TextStyle(
                                  color: Color(0xffffcf38),
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        LayoutBuilder(
                          builder: (contexto, constraints) {
                            final colunaUnica =
                                constraints.maxWidth < 280 ||
                                MediaQuery.textScalerOf(contexto).scale(20) >
                                    28;
                            final larguraCartao = colunaUnica
                                ? constraints.maxWidth
                                : (constraints.maxWidth - 16) / 2;
                            return Wrap(
                              spacing: 16,
                              runSpacing: 22,
                              children: [
                                for (final continente in Continente.values)
                                  SizedBox(
                                    width: continente == Continente.oceania
                                        ? constraints.maxWidth
                                        : larguraCartao,
                                    child: _CartaoContinente(
                                      continente: continente,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'As bandeiras serão sorteadas só do continente escolhido',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xffd4caee),
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartaoContinente extends StatelessWidget {
  const _CartaoContinente({required this.continente});

  final Continente continente;

  @override
  Widget build(BuildContext contexto) {
    final (cor, sombra, icone) = switch (continente) {
      Continente.africa => (
        const Color(0xffff8b36),
        const Color(0xffb95a25),
        Icons.wb_sunny,
      ),
      Continente.america => (
        const Color(0xff31d780),
        const Color(0xff1b9255),
        Icons.landscape,
      ),
      Continente.asia => (
        const Color(0xffff5188),
        const Color(0xffb82d66),
        Icons.temple_buddhist,
      ),
      Continente.europa => (
        const Color(0xff6ba3ff),
        const Color(0xff3e64b8),
        Icons.location_city,
      ),
      Continente.oceania => (
        const Color(0xff22cddd),
        const Color(0xff1392a7),
        Icons.beach_access,
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: sombra, offset: const Offset(0, 7))],
      ),
      child: FilledButton(
        onPressed: () => Navigator.pop(contexto, continente),
        style: FilledButton.styleFrom(
          backgroundColor: cor,
          foregroundColor: const Color(0xff2c2068),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          minimumSize: const Size(0, 152),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(icone, color: cor, size: 36),
            ),
            const SizedBox(height: 14),
            Text(
              continente.rotulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
