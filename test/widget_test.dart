import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizzbandeira_app/main.dart';

Future<void> loadMenu(WidgetTester tester) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(const MyApp());
    for (var attempt = 0; attempt < 100; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await tester.pump();
      if (find.text('195 países carregados').evaluate().isNotEmpty) break;
    }
  });
  await tester.pumpAndSettle();
}

Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.scrollUntilVisible(finder, 150);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Menu inicia partida e volta ao menu ao terminar o tempo', (
    tester,
  ) async {
    await loadMenu(tester);
    await tapText(tester, 'Jogo aleatório');
    await tapText(tester, 'País → bandeira');
    await tapText(tester, 'Iniciar partida');
    expect(find.text('País → bandeira'), findsOneWidget);
    await tester.pump(const Duration(seconds: 60));
    await tester.pumpAndSettle();
    expect(find.text('Tempo esgotado!'), findsOneWidget);
    await tapText(tester, 'Voltar ao menu');
    expect(find.text('Flag Game'), findsOneWidget);
    expect(find.text('Preparar partida'), findsNothing);
    expect(find.text('Tempo total: 60 segundos'), findsOneWidget);
    await tapText(tester, 'Jogo aleatório');
    await tapText(tester, 'Iniciar partida');
    expect(find.text('Pontos: 0'), findsOneWidget);
    expect(find.text('Resultado'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 61));
    expect(find.text('Flag Game'), findsOneWidget);
    expect(find.text('Resultado'), findsNothing);
  });

  testWidgets('Carrega o catálogo e oferece os cinco continentes', (
    tester,
  ) async {
    await loadMenu(tester);
    expect(find.text('Flag Game'), findsOneWidget);
    expect(find.text('195 países carregados'), findsOneWidget);
    for (final label in ['África', 'América', 'Ásia', 'Europa', 'Oceania']) {
      await tester.scrollUntilVisible(find.text(label), 100);
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('Salva tempo, prepara continente e seleciona ambos os modos', (
    tester,
  ) async {
    await loadMenu(tester);
    await tapText(tester, 'Configuração de tempo');
    for (final seconds in [30, 60, 180, 300]) {
      expect(find.text('$seconds segundos'), findsOneWidget);
    }
    await tapText(tester, '180 segundos');
    await tapText(tester, 'Salvar tempo');
    expect(find.text('Tempo total: 180 segundos'), findsOneWidget);
    await tapText(tester, 'África');
    expect(find.text('54 países disponíveis'), findsOneWidget);
    expect(find.text('Tempo total: 180 segundos'), findsOneWidget);
    expect(find.text('Modo selecionado: Bandeira → país'), findsOneWidget);
    await tapText(tester, 'País → bandeira');
    expect(find.text('Modo selecionado: País → bandeira'), findsOneWidget);
    await tapText(tester, 'Bandeira → país');
    expect(find.text('Modo selecionado: Bandeira → país'), findsOneWidget);
    final start = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Iniciar partida'),
    );
    expect(start.onPressed, isNotNull);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Tempo total: 180 segundos'), findsOneWidget);
  });

  testWidgets(
    'Voltar sem salvar preserva tempo e aleatório inclui todo catálogo',
    (tester) async {
      await loadMenu(tester);
      await tapText(tester, 'Configuração de tempo');
      await tapText(tester, '300 segundos');
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Tempo total: 60 segundos'), findsOneWidget);
      await tapText(tester, 'Jogo aleatório');
      expect(find.text('195 países disponíveis'), findsOneWidget);
    },
  );

  testWidgets('Menu e preparação permitem rolagem em tela pequena', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await loadMenu(tester);
    await tapText(tester, 'Oceania');
    await tapText(tester, 'País → bandeira');
    await tester.scrollUntilVisible(find.text('14 países disponíveis'), -150);
    expect(find.text('14 países disponíveis'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
