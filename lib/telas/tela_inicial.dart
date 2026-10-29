import 'package:flutter/material.dart';

import '../componentes/acao_menu.dart';
import '../componentes/globo_menu.dart';
import '../componentes/tema_jogo.dart';
import '../dados/repositorio_paises.dart';
import '../modelos/pais.dart';
import 'tela_continentes.dart';
import 'tela_preparacao.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _EstadoTelaInicial();
}

class _EstadoTelaInicial extends State<TelaInicial> {
  List<Pais>? _paises;
  String? _erro;
  int _segundos = 60;
  Future<void> _escolherContinente() async {
    final continente = await Navigator.push<Continente>(
      context,
      MaterialPageRoute(builder: (_) => const TelaContinentes()),
    );
    if (!mounted || continente == null) return;
    _prepararPartida(continente);
  }

  void _prepararPartida(Continente? continente) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => TelaPreparacao(
          paises: _paises!,
          continente: continente,
          segundos: _segundos,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _carregarPaises();
  }

  Future<void> _carregarPaises() async {
    setState(() {
      _paises = null;
      _erro = null;
    });
    try {
      final paises = await RepositorioPaises().carregarPaises();
      if (!mounted) return;
      setState(() => _paises = paises);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro =
            'Não foi possível carregar o catálogo local. '
            'Confira o JSON e os arquivos de bandeiras.';
      });
    }
  }

  @override
  Widget build(BuildContext contexto) {
    Widget conteudoTela;
    if (_erro != null) {
      conteudoTela = ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(_erro!),
          FilledButton(
            onPressed: _carregarPaises,
            child: const Text('Tentar novamente'),
          ),
        ],
      );
    } else if (_paises == null) {
      conteudoTela = const Center(child: CircularProgressIndicator());
    } else {
      conteudoTela = SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'PT-BR',
                style: TextStyle(
                  color: Color(0xffd4caee),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(child: GloboMenu()),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'FLAG',
                style: TextStyle(
                  fontSize: 60,
                  height: 1,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w900,
                  color: Color(0xffffcf38),
                  shadows: [
                    Shadow(color: Color(0xff1c1549), offset: Offset(0, 5)),
                  ],
                ),
              ),
            ),
            const Center(
              child: Text(
                'GAME',
                style: TextStyle(
                  fontSize: 60,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  color: Color(0xffff5188),
                  shadows: [
                    Shadow(color: Color(0xff1c1549), offset: Offset(0, 5)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Quanto você sabe sobre bandeiras?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            AcaoMenu(
              rotulo: 'Jogar por Continente',
              icone: Icons.explore_outlined,
              cor: const Color(0xff22cddd),
              corSombra: const Color(0xff1392a7),
              aoPressionar: _escolherContinente,
            ),
            const SizedBox(height: 16),
            AcaoMenu(
              aoPressionar: () => _prepararPartida(null),
              icone: Icons.casino_outlined,
              rotulo: 'Jogo aleatório',
              cor: const Color(0xffff5188),
              corSombra: const Color(0xffb82d66),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: Color(0xffffcf38)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Tempo de jogo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 12,
              children: [
                for (final segundos in [30, 60, 180, 300])
                  ChoiceChip(
                    label: Text(switch (segundos) {
                      180 => '3 min',
                      300 => '5 min',
                      _ => '${segundos}s',
                    }),
                    selected: _segundos == segundos,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _segundos = segundos),
                    selectedColor: const Color(0xffffcf38),
                    backgroundColor: const Color(0xff4d38a6),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    shape: const StadiumBorder(),
                    labelStyle: TextStyle(
                      color: _segundos == segundos
                          ? const Color(0xff2c2068)
                          : Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Tempo total: $_segundos segundos',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${_paises!.length} países carregados',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }
    return Theme(
      data: temaJogo,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: -55,
              top: 150,
              child: IgnorePointer(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    color: Color(0xff713174),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -65,
              bottom: 160,
              child: IgnorePointer(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    color: Color(0xff305793),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Semantics(
              label: 'Flag Game',
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: conteudoTela,
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
