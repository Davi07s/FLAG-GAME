import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:quizzbandeira_app/componentes/alternativa_resposta.dart';
import 'package:quizzbandeira_app/componentes/imagem_bandeira.dart';
import 'package:quizzbandeira_app/dados/repositorio_paises.dart';
import 'package:quizzbandeira_app/modelos/modo_pergunta.dart';
import 'package:quizzbandeira_app/modelos/pais.dart';
import 'package:quizzbandeira_app/telas/tela_jogo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<Pais> paises;
  setUpAll(() async {
    paises = await RepositorioPaises().carregarPaises();
  });

  Future<void> abrir(
    WidgetTester testador,
    ModoPergunta modo, {
    int segundos = 30,
  }) async {
    if (testador.view.physicalSize.width != 320) {
      testador.view.physicalSize = const Size(400, 1200);
      testador.view.devicePixelRatio = 1;
      addTearDown(testador.view.resetPhysicalSize);
      addTearDown(testador.view.resetDevicePixelRatio);
    }
    await testador.pumpWidget(
      MaterialApp(
        home: TelaJogo(
          paises: paises,
          continente: Continente.america,
          modo: modo,
          segundos: segundos,
        ),
      ),
    );
    await testador.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await testador.pump();
  }

  for (final modo in ModoPergunta.values) {
    testWidgets(
      '${modo.rotulo}: fonte ampliada, alternativas e indicadores de resposta',
      (testador) async {
        testador.view.physicalSize = const Size(320, 480);
        testador.view.devicePixelRatio = 1;
        testador.platformDispatcher.textScaleFactorTestValue = 1.6;
        addTearDown(testador.view.resetPhysicalSize);
        addTearDown(testador.view.resetDevicePixelRatio);
        addTearDown(testador.platformDispatcher.clearTextScaleFactorTestValue);
        await abrir(testador, modo);
        final alternativa = find.byType(AlternativaResposta).last;
        await testador.ensureVisible(alternativa);
        await testador.tap(alternativa);
        await testador.pump();
        final alternativas = testador.widgetList<AlternativaResposta>(
          find.byType(AlternativaResposta),
        );
        expect(alternativas.where((opcao) => opcao.estaCorreta), hasLength(1));
        expect(
          alternativas.every((opcao) => opcao.aoPressionar == null),
          isTrue,
        );
        expect(testador.takeException(), isNull);
        await testador.pumpWidget(const SizedBox());
        await testador.pump(const Duration(seconds: 2));
        expect(testador.takeException(), isNull);
      },
    );

    testWidgets(
      '${modo.rotulo}: resposta, bloqueio de toque e avanço automático',
      (testador) async {
        await abrir(testador, modo);
        expect(find.byType(AlternativaResposta), findsNWidgets(4));
        expect(
          find.byType(ImagemBandeira),
          findsNWidgets(modo == ModoPergunta.bandeiraParaPais ? 1 : 4),
        );
        final tela = testador.widget<TelaJogo>(find.byType(TelaJogo));
        expect(tela.continente, Continente.america);
        final imagem = testador.widget<ImagemBandeira>(
          find.byType(ImagemBandeira).first,
        );
        final paisPergunta = modo == ModoPergunta.bandeiraParaPais
            ? paises.firstWhere(
                (candidato) => candidato.caminhoBandeira == imagem.arquivo,
              )
            : paises.firstWhere(
                (candidato) => find
                    .text('Qual é a bandeira de ${candidato.nome}?')
                    .evaluate()
                    .isNotEmpty,
              );
        final alternativa = find.byKey(ValueKey(paisPergunta.codigo));
        await testador.ensureVisible(alternativa);
        await testador.tap(alternativa);
        await testador.pump();
        expect(find.text('Acertou!'), findsOneWidget);
        expect(find.bySemanticsLabel('Pontos: 1'), findsOneWidget);
        expect(
          testador
              .widgetList<AlternativaResposta>(find.byType(AlternativaResposta))
              .every((opcao) => opcao.aoPressionar == null),
          isTrue,
        );
        await testador.tap(alternativa);
        await testador.pump(const Duration(milliseconds: 800));
        expect(find.text('Acertou!'), findsNothing);
        expect(find.bySemanticsLabel('Pontos: 1'), findsOneWidget);
        expect(
          testador
              .widgetList<AlternativaResposta>(find.byType(AlternativaResposta))
              .every((opcao) => opcao.aoPressionar != null),
          isTrue,
        );
        await testador.pumpWidget(const SizedBox());
        await testador.pump(const Duration(seconds: 40));
        expect(testador.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Barra e relógio acompanham o tempo total sem reiniciar na resposta',
    (testador) async {
      await abrir(testador, ModoPergunta.paisParaBandeira);
      expect(find.text('0:30'), findsOneWidget);
      expect(
        testador
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        1,
      );
      await testador.pump(const Duration(seconds: 5));
      expect(find.text('0:25'), findsOneWidget);
      expect(
        testador
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        closeTo(25 / 30, .001),
      );
      final alternativa = find.byType(AlternativaResposta).first;
      await testador.ensureVisible(alternativa);
      await testador.tap(alternativa);
      await testador.pump(const Duration(seconds: 1));
      expect(find.text('0:24'), findsOneWidget);
      await testador.pumpWidget(const SizedBox());
    },
  );

  testWidgets('Erro não soma ponto e informa a resposta correta', (
    testador,
  ) async {
    await abrir(testador, ModoPergunta.bandeiraParaPais);
    final imagem = testador.widget<ImagemBandeira>(find.byType(ImagemBandeira));
    final incorreta = testador
        .widgetList<AlternativaResposta>(find.byType(AlternativaResposta))
        .firstWhere((opcao) => opcao.pais.caminhoBandeira != imagem.arquivo);
    final alternativa = find.byKey(ValueKey(incorreta.pais.codigo));
    await testador.ensureVisible(alternativa);
    await testador.tap(alternativa);
    await testador.pump();
    expect(find.textContaining('Errou! Resposta correta:'), findsOneWidget);
    expect(find.bySemanticsLabel('Pontos: 0'), findsOneWidget);
    await testador.pumpWidget(const SizedBox());
  });

  testWidgets(
    'Fim do tempo durante indicação de resposta não avança outra pergunta',
    (testador) async {
      await abrir(testador, ModoPergunta.paisParaBandeira, segundos: 2);
      await testador.pump(const Duration(milliseconds: 1500));
      final alternativa = find.byType(AlternativaResposta).first;
      await testador.ensureVisible(alternativa);
      await testador.tap(alternativa);
      await testador.pump();
      await testador.pump(const Duration(milliseconds: 500));
      await testador.pumpAndSettle();
      expect(find.text('Tempo esgotado!'), findsOneWidget);
      expect(find.bySemanticsLabel('Respostas: 1'), findsOneWidget);
      await testador.pump(const Duration(seconds: 3));
      expect(find.byType(AlternativaResposta), findsNothing);
      expect(find.text('Tempo esgotado!'), findsOneWidget);
    },
  );

  testWidgets('Sem respostas o tempo termina e bloqueia toque pendente', (
    testador,
  ) async {
    await abrir(testador, ModoPergunta.bandeiraParaPais, segundos: 1);
    final acao = testador
        .widget<AlternativaResposta>(find.byType(AlternativaResposta).first)
        .aoPressionar!;
    await testador.pump(const Duration(seconds: 1));
    acao();
    await testador.pumpAndSettle();
    expect(find.text('Resultado'), findsOneWidget);
    expect(find.bySemanticsLabel('Respostas: 0'), findsOneWidget);
    expect(find.bySemanticsLabel('Pontos: 0'), findsOneWidget);
    expect(find.text('Percentual de acertos: 0,0%'), findsOneWidget);
  });

  testWidgets('País para bandeira cabe em tela pequena após responder', (
    testador,
  ) async {
    testador.view.physicalSize = const Size(320, 480);
    testador.view.devicePixelRatio = 1;
    addTearDown(testador.view.resetPhysicalSize);
    addTearDown(testador.view.resetDevicePixelRatio);
    await abrir(testador, ModoPergunta.paisParaBandeira);
    final alternativa = find.byType(AlternativaResposta).first;
    await testador.ensureVisible(alternativa);
    await testador.tap(alternativa);
    await testador.pump();
    expect(testador.takeException(), isNull);
    await testador.pumpWidget(const SizedBox());
  });

  testWidgets('Conjunto insuficiente exibe aviso e não inicia timer', (
    testador,
  ) async {
    await testador.pumpWidget(
      MaterialApp(
        home: TelaJogo(
          paises: paises.take(3).toList(),
          continente: null,
          modo: ModoPergunta.bandeiraParaPais,
          segundos: 30,
        ),
      ),
    );
    expect(
      find.text('São necessários pelo menos quatro países para jogar.'),
      findsOneWidget,
    );
    expect(find.byType(AlternativaResposta), findsNothing);
  });

  testWidgets('Jogar de novo preserva configuração e começa outra sessão', (
    testador,
  ) async {
    await abrir(testador, ModoPergunta.paisParaBandeira, segundos: 2);
    final alternativa = find.byType(AlternativaResposta).first;
    await testador.ensureVisible(alternativa);
    await testador.tap(alternativa);
    await testador.pump(const Duration(seconds: 2));
    await testador.pumpAndSettle();
    expect(find.bySemanticsLabel('Respostas: 1'), findsOneWidget);
    final novaPartida = find.text('Jogar de novo');
    await testador.ensureVisible(novaPartida);
    await testador.tap(novaPartida);
    await testador.pumpAndSettle();
    final jogo = testador.widget<TelaJogo>(find.byType(TelaJogo));
    expect(jogo.modo, ModoPergunta.paisParaBandeira);
    expect(jogo.continente, Continente.america);
    expect(jogo.segundos, 2);
    expect(jogo.paises, hasLength(paises.length));
    expect(find.bySemanticsLabel('Pontos: 0'), findsOneWidget);
    expect(find.text('Resultado'), findsNothing);
    await testador.pump(const Duration(seconds: 2));
    await testador.pumpAndSettle();
    expect(find.bySemanticsLabel('Respostas: 0'), findsOneWidget);
    expect(find.text('Percentual de acertos: 0,0%'), findsOneWidget);
  });
}
