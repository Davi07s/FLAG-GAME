import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizzbandeira_app/models/game_result.dart';
import 'package:quizzbandeira_app/screens/result_screen.dart';

void main() {
  testWidgets('Exibe respostas, acertos, pontos e percentual arredondado', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ResultScreen(result: GameResult(answered: 3, correct: 2)),
      ),
    );
    expect(find.bySemanticsLabel('Respostas: 3'), findsOneWidget);
    expect(find.bySemanticsLabel('Acertos: 2'), findsOneWidget);
    expect(find.text('Pontos: 2'), findsOneWidget);
    expect(find.text('Percentual de acertos: 66,7%'), findsOneWidget);
    expect(find.bySemanticsLabel('Erros: 1'), findsOneWidget);
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .value,
      closeTo(2 / 3, .001),
    );
  });

  testWidgets(
    'Sem respostas mostra zero e permite rolagem com fonte ampliada',
    (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.6)),
            child: child!,
          ),
          home: ResultScreen(result: GameResult(answered: 0, correct: 0)),
        ),
      );
      expect(find.text('Percentual de acertos: 0,0%'), findsOneWidget);
      expect(
        tester
            .widget<CircularProgressIndicator>(
              find.byType(CircularProgressIndicator),
            )
            .value,
        0,
      );
      await tester.scrollUntilVisible(find.text('Voltar ao menu'), 100);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Acerto total mostra círculo completo sem erros', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ResultScreen(result: GameResult(answered: 10, correct: 10)),
      ),
    );
    expect(find.bySemanticsLabel('Erros: 0'), findsOneWidget);
    expect(find.text('Percentual de acertos: 100,0%'), findsOneWidget);
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .value,
      1,
    );
  });
}
