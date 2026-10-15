import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizzbandeira_app/data/country_repository.dart';
import 'package:quizzbandeira_app/models/country.dart';
import 'package:quizzbandeira_app/models/quiz_mode.dart';
import 'package:quizzbandeira_app/screens/game_screen.dart';
import 'package:quizzbandeira_app/widgets/answer_option.dart';
import 'package:quizzbandeira_app/widgets/flag_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<Country> countries;
  setUpAll(() async {
    countries = await CountryRepository().loadCountries();
  });

  Future<void> open(
    WidgetTester tester,
    QuizMode mode, {
    int seconds = 30,
  }) async {
    if (tester.view.physicalSize.width != 320) {
      tester.view.physicalSize = const Size(400, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }
    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(
          countries: countries,
          continent: Continent.america,
          mode: mode,
          seconds: seconds,
        ),
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
  }

  for (final mode in QuizMode.values) {
    testWidgets(
      '${mode.label}: resposta, bloqueio de toque e avanço automático',
      (tester) async {
        await open(tester, mode);
        expect(find.byType(AnswerOption), findsNWidgets(4));
        expect(
          find.byType(FlagImage),
          findsNWidgets(mode == QuizMode.flagToCountry ? 1 : 4),
        );
        final screen = tester.widget<GameScreen>(find.byType(GameScreen));
        expect(screen.continent, Continent.america);
        final image = tester.widget<FlagImage>(find.byType(FlagImage).first);
        final questionCountry = mode == QuizMode.flagToCountry
            ? countries.firstWhere((c) => c.flagAsset == image.asset)
            : countries.firstWhere(
                (c) => find
                    .text('Qual é a bandeira de ${c.name}?')
                    .evaluate()
                    .isNotEmpty,
              );
        final option = find.byKey(ValueKey(questionCountry.code));
        await tester.ensureVisible(option);
        await tester.tap(option);
        await tester.pump();
        expect(find.text('Acertou!'), findsOneWidget);
        expect(find.text('Pontos: 1'), findsOneWidget);
        expect(
          tester
              .widgetList<AnswerOption>(find.byType(AnswerOption))
              .every((o) => o.onPressed == null),
          isTrue,
        );
        await tester.tap(option);
        await tester.pump(const Duration(milliseconds: 800));
        expect(find.text('Acertou!'), findsNothing);
        expect(find.text('Pontos: 1'), findsOneWidget);
        expect(
          tester
              .widgetList<AnswerOption>(find.byType(AnswerOption))
              .every((o) => o.onPressed != null),
          isTrue,
        );
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 40));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Erro não soma ponto e informa a resposta correta', (
    tester,
  ) async {
    await open(tester, QuizMode.flagToCountry);
    final image = tester.widget<FlagImage>(find.byType(FlagImage));
    final wrong = tester
        .widgetList<AnswerOption>(find.byType(AnswerOption))
        .firstWhere((o) => o.country.flagAsset != image.asset);
    final option = find.byKey(ValueKey(wrong.country.code));
    await tester.ensureVisible(option);
    await tester.tap(option);
    await tester.pump();
    expect(find.textContaining('Errou! Resposta correta:'), findsOneWidget);
    expect(find.text('Pontos: 0'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'Fim do tempo durante indicação de resposta não avança outra pergunta',
    (tester) async {
      await open(tester, QuizMode.countryToFlag, seconds: 2);
      await tester.pump(const Duration(milliseconds: 1500));
      final option = find.byType(AnswerOption).first;
      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.text('Tempo esgotado!'), findsOneWidget);
      expect(find.text('Respostas: 1'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(AnswerOption), findsNothing);
      expect(find.text('Tempo esgotado!'), findsOneWidget);
    },
  );

  testWidgets('Sem respostas o tempo termina e bloqueia toque pendente', (
    tester,
  ) async {
    await open(tester, QuizMode.flagToCountry, seconds: 1);
    final callback = tester
        .widget<AnswerOption>(find.byType(AnswerOption).first)
        .onPressed!;
    await tester.pump(const Duration(seconds: 1));
    callback();
    await tester.pumpAndSettle();
    expect(find.text('Resultado'), findsOneWidget);
    expect(find.text('Respostas: 0'), findsOneWidget);
    expect(find.text('Pontos: 0'), findsOneWidget);
    expect(find.text('Percentual de acertos: 0,0%'), findsOneWidget);
  });

  testWidgets('País para bandeira cabe em tela pequena após responder', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await open(tester, QuizMode.countryToFlag);
    final option = find.byType(AnswerOption).first;
    await tester.ensureVisible(option);
    await tester.tap(option);
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Conjunto insuficiente exibe aviso e não inicia timer', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(
          countries: countries.take(3).toList(),
          continent: null,
          mode: QuizMode.flagToCountry,
          seconds: 30,
        ),
      ),
    );
    expect(
      find.text('São necessários pelo menos quatro países para jogar.'),
      findsOneWidget,
    );
    expect(find.byType(AnswerOption), findsNothing);
  });
}
