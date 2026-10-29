import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:quizzbandeira_app/modelos/resultado_partida.dart';
import 'package:quizzbandeira_app/telas/tela_resultado.dart';

void main() {
  testWidgets('Exibe respostas, acertos, pontos e percentual arredondado', (
    testador,
  ) async {
    await testador.pumpWidget(
      MaterialApp(
        home: TelaResultado(
          resultado: ResultadoPartida(respondidas: 3, acertos: 2),
        ),
      ),
    );
    expect(find.bySemanticsLabel('Respostas: 3'), findsOneWidget);
    expect(find.bySemanticsLabel('Acertos: 2'), findsOneWidget);
    expect(find.bySemanticsLabel('Pontos: 2'), findsOneWidget);
    expect(find.text('Percentual de acertos: 66,7%'), findsOneWidget);
    expect(find.bySemanticsLabel('Erros: 1'), findsOneWidget);
    expect(
      testador
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .value,
      closeTo(2 / 3, .001),
    );
  });

  testWidgets(
    'Sem respostas mostra zero e permite rolagem com fonte ampliada',
    (testador) async {
      testador.view.physicalSize = const Size(320, 480);
      testador.view.devicePixelRatio = 1;
      addTearDown(testador.view.resetPhysicalSize);
      addTearDown(testador.view.resetDevicePixelRatio);
      await testador.pumpWidget(
        MaterialApp(
          builder: (contexto, child) => MediaQuery(
            data: MediaQuery.of(contexto)
                .copyWith(textScaler: const TextScaler.linear(1.6)),
            child: child!,
          ),
          home: TelaResultado(
            resultado: ResultadoPartida(respondidas: 0, acertos: 0),
          ),
        ),
      );
      expect(find.text('Percentual de acertos: 0,0%'), findsOneWidget);
      expect(
        testador
            .widget<CircularProgressIndicator>(
              find.byType(CircularProgressIndicator),
            )
            .value,
        0,
      );
      await testador.scrollUntilVisible(find.text('Voltar ao menu'), 100);
      expect(testador.takeException(), isNull);
    },
  );

  testWidgets('Acerto total mostra candidatoírculo completo sem erros', (
    testador,
  ) async {
    await testador.pumpWidget(
      MaterialApp(
        home: TelaResultado(
          resultado: ResultadoPartida(respondidas: 10, acertos: 10),
        ),
      ),
    );
    expect(find.bySemanticsLabel('Erros: 0'), findsOneWidget);
    expect(find.text('Percentual de acertos: 100,0%'), findsOneWidget);
    expect(
      testador
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .value,
      1,
    );
  });
}
