import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:quizzbandeira_app/componentes/alternativa_resposta.dart';
import 'package:quizzbandeira_app/dados/repositorio_paises.dart';
import 'package:quizzbandeira_app/modelos/modo_pergunta.dart';
import 'package:quizzbandeira_app/modelos/pais.dart';
import 'package:quizzbandeira_app/telas/tela_jogo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<Pais> paises;
  setUpAll(() async {
    final catalogo = await RepositorioPaises().carregarPaises();
    // Nomes longos reais para testar quebra de linha e os SVGs do catálogo.
    paises = catalogo
        .where((pais) => {'ag', 'kn', 'vc', 'tt'}.contains(pais.codigo))
        .toList();
  });

  Future<void> abrir(
    WidgetTester testador,
    Size tamanho,
    ModoPergunta modo, {
    double escala = 1,
  }) async {
    testador.view.physicalSize = tamanho;
    testador.view.devicePixelRatio = 1;
    testador.view.viewPadding = const FakeViewPadding(top: 24, bottom: 24);
    testador.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    testador.platformDispatcher.textScaleFactorTestValue = escala;
    addTearDown(testador.view.resetPhysicalSize);
    addTearDown(testador.view.resetDevicePixelRatio);
    addTearDown(testador.view.resetViewPadding);
    addTearDown(testador.view.resetPadding);
    addTearDown(testador.platformDispatcher.clearTextScaleFactorTestValue);
    await testador.pumpWidget(
      MaterialApp(
        home: TelaJogo(
          paises: paises,
          continente: Continente.america,
          modo: modo,
          segundos: 60,
        ),
      ),
    );
    await testador.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await testador.pump();
  }

  void conferirAlternativas(WidgetTester testador, Size tamanho) {
    final alternativas = find.byType(AlternativaResposta);
    expect(alternativas, findsNWidgets(4));
    for (final elemento in alternativas.evaluate()) {
      final localizador = find.byWidget(elemento.widget);
      final retangulo = testador.getRect(localizador);
      expect(retangulo.top, greaterThanOrEqualTo(24));
      expect(retangulo.bottom, lessThanOrEqualTo(tamanho.height - 24));
      expect(retangulo.left, greaterThanOrEqualTo(0));
      expect(retangulo.right, lessThanOrEqualTo(tamanho.width));
      expect(retangulo.height, greaterThanOrEqualTo(48));
    }
    expect(find.byKey(const ValueKey('rolagemPergunta')), findsNothing);
    expect(testador.takeException(), isNull);
  }

  for (final modo in ModoPergunta.values) {
    for (final tamanho in [
      const Size(360, 640),
      const Size(375, 667),
      const Size(390, 844),
      const Size(412, 915),
    ]) {
      testWidgets(
        '${modo.rotulo} cabe em $tamanho com barras do sistema e nomes longos',
        (testador) async {
          await abrir(testador, tamanho, modo);
          conferirAlternativas(testador, tamanho);
          if (modo == ModoPergunta.paisParaBandeira) {
            final alternativas = find.byType(AlternativaResposta);
            final primeira = testador.getRect(alternativas.at(0));
            final segunda = testador.getRect(alternativas.at(1));
            final terceira = testador.getRect(alternativas.at(2));
            expect(primeira.top, segunda.top);
            expect(segunda.left, greaterThan(primeira.left));
            expect(terceira.top, greaterThan(primeira.bottom));
          }
          await testador.tap(find.byType(AlternativaResposta).last);
          await testador.pump();
          conferirAlternativas(testador, tamanho);
          final placar = testador.getRect(
            find.bySemanticsLabel(RegExp(r'^Pontos:')).first,
          );
          expect(placar.top, greaterThanOrEqualTo(24));
          await testador.pump(const Duration(milliseconds: 800));
          conferirAlternativas(testador, tamanho);
          await testador.pumpWidget(const SizedBox());
        },
      );
    }
    for (final tamanho in [const Size(320, 480), const Size(640, 360)]) {
      testWidgets(
        '${modo.rotulo} permite rolar em $tamanho sem mover o placar',
        (testador) async {
          await abrir(testador, tamanho, modo, escala: 1.6);
          final rolagem = find.byKey(const ValueKey('rolagemPergunta'));
          expect(rolagem, findsOneWidget);
          final posicaoPlacar = testador.getTopLeft(
            find.bySemanticsLabel(RegExp(r'^Pontos:')).first,
          );
          final posicaoRelogio = testador.getTopLeft(find.text('1:00'));
          await testador.drag(rolagem, const Offset(0, -250));
          await testador.pump();
          await Scrollable.ensureVisible(
            testador.element(find.byType(AlternativaResposta).last),
            alignment: 0.5,
          );
          await testador.tap(find.byType(AlternativaResposta).last);
          await testador.pump();
          expect(
            testador
                .widgetList<AlternativaResposta>(
                  find.byType(AlternativaResposta),
                )
                .every((alternativa) => alternativa.aoPressionar == null),
            isTrue,
          );
          expect(
            testador.getTopLeft(
              find.bySemanticsLabel(RegExp(r'^Pontos:')).first,
            ),
            posicaoPlacar,
          );
          expect(testador.getTopLeft(find.text('1:00')), posicaoRelogio);
          expect(testador.takeException(), isNull);
          await testador.pumpWidget(const SizedBox());
        },
      );
    }
  }
}
