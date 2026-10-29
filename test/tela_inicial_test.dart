import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:quizzbandeira_app/main.dart';

Future<void> carregarMenu(WidgetTester testador) async {
  await testador.runAsync(() async {
    await testador.pumpWidget(const AplicativoBandeiras());
    for (var tentativa = 0; tentativa < 100; tentativa++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await testador.pump();
      if (find.text('195 bandeiras').evaluate().isNotEmpty) break;
    }
  });
  await testador.pumpAndSettle();
}

Future<void> tocarTexto(WidgetTester testador, String texto) async {
  if (['África', 'América', 'Ásia', 'Europa', 'Oceania'].contains(texto) &&
      find.text(texto).evaluate().isEmpty) {
    await tocarTexto(testador, 'Jogar por Continente');
  }
  final localizador = find.text(texto);
  await testador.ensureVisible(localizador);
  await testador.tap(localizador);
  await testador.pumpAndSettle();
}

void main() {
  testWidgets(
    'Menu lateral oferece ranking e gerenciamento sem alterar o tempo',
    (testador) async {
      await carregarMenu(testador);
      await tocarTexto(testador, '3 min');
      await testador.ensureVisible(find.byTooltip('Abrir menu'));
      await testador.tap(find.byTooltip('Abrir menu'));
      await testador.pumpAndSettle();
      expect(find.byType(Drawer), findsOneWidget);
      expect(find.text('Ranking'), findsOneWidget);
      expect(find.text('Gerenciar ranking'), findsOneWidget);
      expect(find.text('Configurações'), findsNothing);
      Navigator.pop(testador.element(find.byType(Drawer)));
      await testador.pumpAndSettle();
      expect(find.text('Tempo total: 180 segundos'), findsOneWidget);
    },
  );
  testWidgets(
    'Cada cartão abre a preparação com seu continente e tempo escolhido',
    (testador) async {
      await carregarMenu(testador);
      await tocarTexto(testador, '3 min');
      for (final entrada in {
        'África': 54,
        'América': 35,
        'Ásia': 48,
        'Europa': 44,
        'Oceania': 14,
      }.entries) {
        await tocarTexto(testador, 'Jogar por Continente');
        expect(find.text('Escolha o continente'), findsOneWidget);
        await tocarTexto(testador, entrada.key);
        expect(
          find.text('${entrada.value} países disponíveis'),
          findsOneWidget,
        );
        expect(find.text('Tempo total: 180 segundos'), findsOneWidget);
        expect(find.text(entrada.key), findsOneWidget);
        await testador.pageBack();
        await testador.pumpAndSettle();
        expect(find.text('FLAG'), findsOneWidget);
      }
    },
  );

  testWidgets('Voltar da seleção preserva menu e tempo sem iniciar partida', (
    testador,
  ) async {
    await carregarMenu(testador);
    await tocarTexto(testador, '30s');
    await tocarTexto(testador, 'Jogar por Continente');
    await testador.tap(find.byTooltip('Voltar ao menu'));
    await testador.pumpAndSettle();
    expect(find.text('FLAG'), findsOneWidget);
    expect(find.text('Tempo total: 30 segundos'), findsOneWidget);
    expect(find.text('Preparar partida'), findsNothing);
  });

  testWidgets('Cartões permitem seleção em tela pequena e fonte ampliada', (
    testador,
  ) async {
    testador.view.physicalSize = const Size(320, 480);
    testador.view.devicePixelRatio = 1;
    testador.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(testador.view.resetPhysicalSize);
    addTearDown(testador.view.resetDevicePixelRatio);
    addTearDown(testador.platformDispatcher.clearTextScaleFactorTestValue);
    await carregarMenu(testador);
    await tocarTexto(testador, 'Jogar por Continente');
    for (final rotulo in ['África', 'América', 'Ásia', 'Europa', 'Oceania']) {
      await testador.ensureVisible(find.text(rotulo));
      await testador.pumpAndSettle();
      expect(testador.takeException(), isNull);
    }
    await tocarTexto(testador, 'Oceania');
    expect(find.text('14 países disponíveis'), findsOneWidget);
    expect(testador.takeException(), isNull);
  });

  testWidgets(
    'Menu seleciona os quatro tempos sem overflow com fonte ampliada',
    (testador) async {
      testador.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(testador.platformDispatcher.clearTextScaleFactorTestValue);
      testador.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(testador.platformDispatcher.clearTextScaleFactorTestValue);
      testador.view.physicalSize = const Size(320, 480);
      testador.view.devicePixelRatio = 1;
      addTearDown(testador.view.resetPhysicalSize);
      addTearDown(testador.view.resetDevicePixelRatio);
      await carregarMenu(testador);
      for (final entrada in {
        '30s': 30,
        '60s': 60,
        '3 min': 180,
        '5 min': 300,
      }.entries) {
        await tocarTexto(testador, entrada.key);
        expect(
          find.text('Tempo total: ${entrada.value} segundos'),
          findsOneWidget,
        );
      }
      expect(testador.takeException(), isNull);
    },
  );
  testWidgets('Menu inicia partida e volta ao menu ao terminar o tempo', (
    testador,
  ) async {
    await carregarMenu(testador);
    await tocarTexto(testador, 'Jogo aleatório');
    await tocarTexto(testador, 'País → bandeira');
    await tocarTexto(testador, 'Iniciar partida');
    expect(find.text('País → bandeira'), findsOneWidget);
    await testador.pump(const Duration(seconds: 60));
    await testador.pumpAndSettle();
    expect(find.text('Tempo esgotado!'), findsOneWidget);
    await tocarTexto(testador, 'Voltar ao menu');
    expect(find.text('FLAG'), findsOneWidget);
    expect(find.text('Preparar partida'), findsNothing);
    expect(find.text('Tempo total: 60 segundos'), findsOneWidget);
    await tocarTexto(testador, 'Jogo aleatório');
    await tocarTexto(testador, 'Iniciar partida');
    expect(find.bySemanticsLabel('Pontos: 0'), findsOneWidget);
    expect(find.text('Resultado'), findsNothing);
    await testador.ensureVisible(find.byTooltip('Sair da partida'));
    await testador.tap(find.byTooltip('Sair da partida'));
    await testador.pumpAndSettle();
    await testador.pump(const Duration(seconds: 61));
    expect(find.text('FLAG'), findsOneWidget);
    expect(find.text('Resultado'), findsNothing);
  });

  testWidgets('Carrega o catálogo e oferece os cinco continentes', (
    testador,
  ) async {
    await carregarMenu(testador);
    expect(find.text('FLAG'), findsOneWidget);
    expect(find.text('195 bandeiras'), findsOneWidget);
    await tocarTexto(testador, 'Jogar por Continente');
    for (final rotulo in ['África', 'América', 'Ásia', 'Europa', 'Oceania']) {
      await testador.scrollUntilVisible(find.text(rotulo), 100);
      expect(find.text(rotulo), findsOneWidget);
    }
  });

  testWidgets(
    'Escolhe tempo no menu, prepara continente e seleciona ambos os modos',
    (testador) async {
      await carregarMenu(testador);
      await tocarTexto(testador, '3 min');
      expect(find.text('Tempo total: 180 segundos'), findsOneWidget);
      await tocarTexto(testador, 'África');
      expect(find.text('54 países disponíveis'), findsOneWidget);
      expect(find.text('Tempo total: 180 segundos'), findsOneWidget);
      expect(find.text('Modo selecionado: Bandeira → país'), findsOneWidget);
      await tocarTexto(testador, 'País → bandeira');
      expect(find.text('Modo selecionado: País → bandeira'), findsOneWidget);
      await tocarTexto(testador, 'Bandeira → país');
      expect(find.text('Modo selecionado: Bandeira → país'), findsOneWidget);
      final iniciar = testador.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Iniciar partida'),
      );
      expect(iniciar.onPressed, isNotNull);
      await testador.pageBack();
      await testador.pumpAndSettle();
      expect(find.text('Tempo total: 180 segundos'), findsOneWidget);
    },
  );

  testWidgets('Tempo escolhido no menu é aplicado ao jogo aleatório', (
    testador,
  ) async {
    await carregarMenu(testador);
    await tocarTexto(testador, '5 min');
    expect(find.text('Tempo total: 300 segundos'), findsOneWidget);
    await tocarTexto(testador, 'Jogo aleatório');
    expect(find.text('195 países disponíveis'), findsOneWidget);
    expect(find.text('Tempo total: 300 segundos'), findsOneWidget);
  });

  testWidgets('Menu e preparação permitem rolagem em tela pequena', (
    testador,
  ) async {
    testador.view.physicalSize = const Size(320, 480);
    testador.view.devicePixelRatio = 1;
    addTearDown(testador.view.resetPhysicalSize);
    addTearDown(testador.view.resetDevicePixelRatio);
    await carregarMenu(testador);
    await tocarTexto(testador, 'Oceania');
    await tocarTexto(testador, 'País → bandeira');
    await testador.scrollUntilVisible(find.text('14 países disponíveis'), -150);
    expect(find.text('14 países disponíveis'), findsOneWidget);
    expect(testador.takeException(), isNull);
  });
}
