import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../componentes/alternativa_resposta.dart';
import '../componentes/imagem_bandeira.dart';
import '../componentes/tema_jogo.dart';
import '../modelos/modo_pergunta.dart';
import '../modelos/pais.dart';
import '../modelos/pergunta.dart';
import '../servicos/sessao_quiz.dart';
import 'tela_resultado.dart';

class TelaJogo extends StatefulWidget {
  const TelaJogo({
    super.key,
    required this.paises,
    required this.continente,
    required this.modo,
    required this.segundos,
  }) : assert(segundos > 0);

  final List<Pais> paises;
  final Continente? continente;
  final ModoPergunta modo;
  final int segundos;

  @override
  State<TelaJogo> createState() => _EstadoTelaJogo();
}

class _EstadoTelaJogo extends State<TelaJogo> with WidgetsBindingObserver {
  late final SessaoQuiz _sessao;
  late final DateTime _prazoFinal;
  late int _segundosRestantes;
  Pergunta? _pergunta;
  Timer? _cronometro;
  Timer? _temporizadorAvanco;
  String? _codigoSelecionado;
  bool? _acertou;
  bool _encerrada = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessao = SessaoQuiz(paises: widget.paises, continente: widget.continente);
    _pergunta = _sessao.proximaPergunta();
    _segundosRestantes = widget.segundos;
    _prazoFinal = DateTime.now().add(Duration(seconds: widget.segundos));
    if (_sessao.podeJogar) {
      _cronometro = Timer.periodic(const Duration(seconds: 1), (temporizador) {
        if (!mounted || _encerrada) return;
        // O prazo real também cobre atrasos do timer e tempo em segundo plano.
        final segundosRestantes =
            (_prazoFinal.difference(DateTime.now()).inMilliseconds / 1000)
                .ceil();
        _segundosRestantes = max(
          0,
          min(widget.segundos - temporizador.tick, segundosRestantes),
        );
        if (_segundosRestantes == 0) {
          _encerrar();
        } else {
          setState(() {});
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    if (estado != AppLifecycleState.resumed ||
        _encerrada ||
        !_sessao.podeJogar) {
      return;
    }
    final segundos =
        (_prazoFinal.difference(DateTime.now()).inMilliseconds / 1000).ceil();
    _segundosRestantes = max(0, min(_segundosRestantes, segundos));
    if (_segundosRestantes == 0) {
      _encerrar();
    } else {
      setState(() {});
    }
  }

  bool get _tempoEsgotado =>
      _segundosRestantes <= 0 || !DateTime.now().isBefore(_prazoFinal);

  void _responder(String codigo) {
    if (_encerrada || _codigoSelecionado != null) return;
    if (_tempoEsgotado) {
      _encerrar();
      return;
    }
    final acertou = _sessao.responder(codigo);
    if (acertou == null) return;
    setState(() {
      _codigoSelecionado = codigo;
      _acertou = acertou;
    });
    _temporizadorAvanco = Timer(const Duration(milliseconds: 800), () {
      if (!mounted || _encerrada) return;
      if (_tempoEsgotado) {
        _encerrar();
        return;
      }
      setState(() {
        _pergunta = _sessao.proximaPergunta();
        _codigoSelecionado = null;
        _acertou = null;
      });
    });
  }

  void _encerrar() {
    if (!mounted || _encerrada) return;
    _cronometro?.cancel();
    _temporizadorAvanco?.cancel();
    final resultado = _sessao.encerrar();
    _segundosRestantes = 0;
    // Marcar antes de navegar impede que dois callbacks abram resultados.
    _encerrada = true;
    final novaPartida = TelaJogo(
      paises: widget.paises,
      continente: widget.continente,
      modo: widget.modo,
      segundos: widget.segundos,
    );
    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute(
        builder: (_) => TelaResultado(
          resultado: resultado,
          modoJogo: widget.modo,
          continente: widget.continente,
          duracaoPartida: widget.segundos,
          construirNovaPartida: (_) => novaPartida,
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cronometro?.cancel();
    _temporizadorAvanco?.cancel();
    super.dispose();
  }

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
              top: 160,
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
              right: -60,
              bottom: 180,
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _cabecalho(contexto),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _segundosRestantes / widget.segundos,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(12),
                          backgroundColor: const Color(0xff4d38a6),
                          color: const Color(0xff31d780),
                          semanticsLabel: 'Tempo restante da partida',
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.modo.rotulo,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xffd4caee),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          widget.continente?.rotulo ?? 'Jogo aleatório',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xffd4caee),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _pergunta == null
                              ? const Center(
                                  child: Text(
                                    'São necessários pelo menos quatro países para jogar.',
                                  ),
                                )
                              : LayoutBuilder(
                                  builder: (contexto, limites) => _areaPergunta(
                                    contexto,
                                    limites,
                                    _pergunta!,
                                  ),
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

  Widget _cabecalho(BuildContext contexto) {
    final relogio =
        '${_segundosRestantes ~/ 60}:${(_segundosRestantes % 60).toString().padLeft(2, '0')}';
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        IconButton.filled(
          onPressed: () => Navigator.maybePop(contexto),
          tooltip: 'Sair da partida',
          style: IconButton.styleFrom(backgroundColor: const Color(0xff4d38a6)),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        Semantics(
          label: 'Pontos: ${_sessao.resultado.pontos}',
          excludeSemantics: true,
          child: _indicador(
            Icons.star,
            '${_sessao.resultado.pontos}',
            const Color(0xffffcf38),
          ),
        ),
        Semantics(
          label: 'Tempo restante: $_segundosRestantes segundos',
          child: _indicador(Icons.schedule, relogio, const Color(0xffff5188)),
        ),
      ],
    );
  }

  // Medir o texto permite manter nomes completos e respeitar a escala acessível.
  double _alturaTexto(
    BuildContext contexto,
    String texto,
    double largura,
    TextStyle estilo,
  ) {
    final medidor = TextPainter(
      text: TextSpan(text: texto, style: estilo),
      textDirection: Directionality.of(contexto),
      textScaler: MediaQuery.textScalerOf(contexto),
    )..layout(maxWidth: largura);
    final altura = medidor.height;
    medidor.dispose();
    return altura;
  }

  Widget _areaPergunta(
    BuildContext contexto,
    BoxConstraints limites,
    Pergunta pergunta,
  ) {
    final inverso = widget.modo == ModoPergunta.paisParaBandeira;
    final enunciado = inverso
        ? 'Qual é a bandeira de ${pergunta.pais.nome}?'
        : 'A qual país pertence esta bandeira?';
    const estiloEnunciado = TextStyle(
      fontSize: 16,
      height: 1.2,
      fontWeight: FontWeight.w900,
      color: Colors.white,
    );
    final retorno = _acertou == null
        ? ''
        : _acertou!
        ? 'Acertou!'
        : 'Errou! Resposta correta: ${pergunta.pais.nome}.';
    final alturaEnunciado = _alturaTexto(
      contexto,
      enunciado,
      limites.maxWidth,
      estiloEnunciado,
    );
    // Reserva espaço para o retorno, evitando que o último botão saia da tela após o toque.
    final alturaRetorno = max(
      28.0,
      _alturaTexto(
        contexto,
        'Errou! Resposta correta: ${pergunta.pais.nome}.',
        limites.maxWidth,
        const TextStyle(fontSize: 14, height: 1.2, fontWeight: FontWeight.bold),
      ),
    );
    double medirBotao(double fonte) => pergunta.alternativas
        .map(
          (pais) => max(
            48.0,
            _alturaTexto(
                  contexto,
                  pais.nome,
                  limites.maxWidth - 88,
                  TextStyle(
                    fontSize: fonte,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ) +
                18,
          ),
        )
        .reduce(max);
    // Mantém a tipografia original quando cabe; compacta apenas o necessário.
    double tamanhoFonte = 20;
    for (final fonte in [20.0, 18.0, 16.0]) {
      tamanhoFonte = fonte;
      final alturaNecessaria =
          medirBotao(fonte) * 4 +
          24 +
          alturaEnunciado +
          alturaRetorno +
          24 +
          64;
      if (alturaNecessaria <= limites.maxHeight) break;
    }
    final alturaBotao = medirBotao(tamanhoFonte);
    final alturaAlternativas = inverso ? 224.0 : alturaBotao * 4 + 24;
    final alturaLivre =
        limites.maxHeight -
        alturaEnunciado -
        alturaRetorno -
        24 -
        alturaAlternativas;
    final fonteAmpliada = MediaQuery.textScalerOf(contexto).scale(16) > 20;
    final precisaRolar =
        fonteAmpliada ||
        limites.maxWidth < 260 ||
        alturaLivre < (inverso ? 0 : 64);

    Widget titulo() =>
        Text(enunciado, textAlign: TextAlign.center, style: estiloEnunciado);
    Widget mensagem() => SizedBox(
      height: alturaRetorno,
      child: Semantics(
        liveRegion: true,
        child: Text(
          retorno,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    if (precisaRolar) {
      return SingleChildScrollView(
        key: const ValueKey('rolagemPergunta'),
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!inverso)
              _cartaoBandeira(pergunta, min(180, limites.maxWidth * .5)),
            const SizedBox(height: 8),
            titulo(),
            const SizedBox(height: 8),
            mensagem(),
            const SizedBox(height: 8),
            if (inverso)
              _gradeBandeiras(
                pergunta,
                max(128, (limites.maxWidth - 12) * .5 * .75 + 24) +
                    (fonteAmpliada ? 180 : 0),
              )
            else
              for (var indice = 0; indice < 4; indice++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _alternativa(
                    pergunta,
                    indice,
                    false,
                    tamanhoFonte: precisaRolar ? 20 : tamanhoFonte,
                  ),
                ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!inverso) ...[
          _cartaoBandeira(pergunta, min(180, alturaLivre)),
          const SizedBox(height: 8),
        ],
        titulo(),
        const SizedBox(height: 8),
        mensagem(),
        const SizedBox(height: 8),
        Expanded(
          child: inverso
              ? LayoutBuilder(
                  builder: (contexto, areaGrade) => Center(
                    child: _gradeBandeiras(
                      pergunta,
                      (areaGrade.maxHeight - 12) / 2,
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (var indice = 0; indice < 4; indice++) ...[
                      if (indice > 0) const SizedBox(height: 8),
                      Expanded(child: _alternativa(pergunta, indice, false)),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _cartaoBandeira(Pergunta pergunta, double altura) => Center(
    child: Container(
      height: altura,
      width: altura * 4 / 3,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(color: Color(0xff1c1549), offset: Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ImagemBandeira(
          arquivo: pergunta.pais.caminhoBandeira,
          rotulo: 'Bandeira do país da pergunta',
        ),
      ),
    ),
  );

  Widget _gradeBandeiras(
    Pergunta pergunta,
    double alturaCelula,
  ) => LayoutBuilder(
    builder: (contexto, limites) {
      final larguraCelula = (limites.maxWidth - 12) / 2;
      final fonteAmpliada = MediaQuery.textScalerOf(contexto).scale(16) > 20;
      // A célula acompanha a proporção da imagem, sem esticar a moldura branca.
      final alturaImagem = (larguraCelula - 16) * 3 / 4;
      final alturaCartao = fonteAmpliada
          ? alturaCelula
          : min(
              alturaCelula,
              alturaImagem + 16 + (_codigoSelecionado == null ? 0 : 76),
            );
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var linha = 0; linha < 2; linha++) ...[
            if (linha > 0) const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _alternativa(
                    pergunta,
                    linha * 2,
                    true,
                    altura: alturaCartao,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _alternativa(
                    pergunta,
                    linha * 2 + 1,
                    true,
                    altura: alturaCartao,
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    },
  );

  Widget _indicador(IconData icone, String texto, Color cor) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: cor,
      borderRadius: BorderRadius.circular(32),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, color: const Color(0xff2c2068), size: 20),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            texto,
            style: const TextStyle(
              color: Color(0xff2c2068),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _alternativa(
    Pergunta pergunta,
    int indice,
    bool mostrarBandeira, {
    double? altura,
    double tamanhoFonte = 20,
  }) {
    final pais = pergunta.alternativas[indice];
    return AlternativaResposta(
      key: ValueKey(pais.codigo),
      pais: pais,
      indice: indice,
      mostrarBandeira: mostrarBandeira,
      altura: altura,
      tamanhoFonte: tamanhoFonte,
      aoPressionar: !_encerrada && _codigoSelecionado == null
          ? () => _responder(pais.codigo)
          : null,
      estaCorreta:
          _codigoSelecionado != null && pais.codigo == pergunta.pais.codigo,
      estaErrada: _codigoSelecionado == pais.codigo && _acertou == false,
    );
  }
}
