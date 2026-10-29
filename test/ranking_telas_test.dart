import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizzbandeira_app/modelos/modo_pergunta.dart';
import 'package:quizzbandeira_app/modelos/pais.dart';
import 'package:quizzbandeira_app/modelos/resultado_partida.dart';
import 'package:quizzbandeira_app/servicos/armazenamento_ranking.dart';
import 'package:quizzbandeira_app/telas/tela_ranking.dart';
import 'package:quizzbandeira_app/telas/tela_resultado.dart';

import 'apoio/preferencias_em_memoria.dart';
import 'armazenamento_ranking_test.dart' show registro;

void main() {
  late Map<String, String> dados;
  late ArmazenamentoRanking armazenamento;
  setUp(() {
    dados = {};
    armazenamento = ArmazenamentoRanking(
      preferencias: PreferenciasEmMemoria(dados),
    );
  });

  Future<void> tocar(WidgetTester testador, String texto) async {
    final botao = find.text(texto);
    await testador.ensureVisible(botao);
    await testador.tap(botao);
    await testador.pumpAndSettle();
  }

  Future<void> resultado(WidgetTester testador, ModoPergunta modo) async {
    await testador.pumpWidget(
      MaterialApp(
        home: TelaResultado(
          resultado: ResultadoPartida(respondidas: 5, acertos: 4),
          modoJogo: modo,
          continente: Continente.asia,
          duracaoPartida: 300,
          idPartida: 'unica',
          dataPartida: DateTime.utc(2026, 10, 29),
          armazenamento: armazenamento,
        ),
      ),
    );
  }

  for (final modo in ModoPergunta.values) {
    testWidgets('${modo.rotulo}: salva com nome e metadados uma única vez', (
      testador,
    ) async {
      await resultado(testador, modo);
      await tocar(testador, 'Salvar no ranking');
      await testador.enterText(find.byType(TextFormField), '  Ana  ');
      await tocar(testador, 'Salvar');
      expect(find.text('Pontuação salva'), findsOneWidget);
      final itens = await armazenamento.listarPontuacoes();
      expect(itens, hasLength(1));
      expect(itens.single.nomeJogador, 'Ana');
      expect(itens.single.modoJogo, modo);
      expect(itens.single.continente, Continente.asia);
      expect(itens.single.duracaoPartida, 300);
      expect(itens.single.pontuacao, 4);
      expect(itens.single.totalPerguntas, 5);
      expect(
        testador
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Pontuação salva'),
            )
            .onPressed,
        isNull,
      );
      await testador.pumpWidget(const SizedBox());
      await resultado(testador, modo);
      await tocar(testador, 'Salvar no ranking');
      await testador.enterText(find.byType(TextFormField), 'Outra pessoa');
      await tocar(testador, 'Salvar');
      expect(await armazenamento.listarPontuacoes(), hasLength(1));
    });
  }

  testWidgets(
    'Nome vazio é rejeitado, cancelar não salva e campo limita a 20 caracteres',
    (testador) async {
      await resultado(testador, ModoPergunta.bandeiraParaPais);
      await tocar(testador, 'Salvar no ranking');
      await testador.enterText(find.byType(TextFormField), '   ');
      await tocar(testador, 'Salvar');
      expect(find.text('Informe seu nome.'), findsOneWidget);
      expect(await armazenamento.listarPontuacoes(), isEmpty);
      await tocar(testador, 'Cancelar');
      expect(await armazenamento.listarPontuacoes(), isEmpty);
      await tocar(testador, 'Salvar no ranking');
      await testador.enterText(
        find.byType(TextFormField),
        '123456789012345678901234',
      );
      await tocar(testador, 'Salvar');
      expect(
        (await armazenamento.listarPontuacoes()).single.nomeJogador,
        '12345678901234567890',
      );
    },
  );

  testWidgets('Ranking vazio tem mensagem amigável', (testador) async {
    await testador.pumpWidget(
      MaterialApp(home: TelaRanking(armazenamento: armazenamento)),
    );
    await testador.pumpAndSettle();
    expect(find.textContaining('Seu ranking está vazio'), findsOneWidget);
    expect(testador.takeException(), isNull);
  });

  testWidgets('Gerenciamento confirma/cancela exclusão individual e limpeza', (
    testador,
  ) async {
    await armazenamento.salvarPontuacao(registro(nome: 'Ana'));
    await armazenamento.salvarPontuacao(registro(id: 'outra', nome: 'Bia'));
    await testador.pumpWidget(
      MaterialApp(
        home: TelaRanking(gerenciar: true, armazenamento: armazenamento),
      ),
    );
    await testador.pumpAndSettle();
    final excluir = find.byTooltip('Excluir pontuação de Ana');
    await testador.ensureVisible(excluir);
    await testador.tap(excluir);
    await testador.pumpAndSettle();
    await tocar(testador, 'Cancelar');
    expect(await armazenamento.listarPontuacoes(), hasLength(2));
    await testador.tap(excluir);
    await testador.pumpAndSettle();
    await tocar(testador, 'Confirmar exclusão');
    expect((await armazenamento.listarPontuacoes()).single.nomeJogador, 'Bia');
    expect(find.textContaining('. Ana'), findsNothing);
    await tocar(testador, 'Limpar ranking');
    await tocar(testador, 'Cancelar');
    expect(await armazenamento.listarPontuacoes(), hasLength(1));
    await tocar(testador, 'Limpar ranking');
    await tocar(testador, 'Confirmar exclusão');
    expect(await armazenamento.listarPontuacoes(), isEmpty);
    expect(find.textContaining('Seu ranking está vazio'), findsOneWidget);
  });

  testWidgets(
    'Ranking permite ler e excluir em tela pequena com fonte ampliada',
    (testador) async {
      testador.view.physicalSize = const Size(320, 480);
      testador.view.devicePixelRatio = 1;
      testador.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(testador.view.resetPhysicalSize);
      addTearDown(testador.view.resetDevicePixelRatio);
      addTearDown(testador.platformDispatcher.clearTextScaleFactorTestValue);
      await armazenamento.salvarPontuacao(
        registro(nome: 'Nome com 20 letras!!'),
      );
      await testador.pumpWidget(
        MaterialApp(
          home: TelaRanking(gerenciar: true, armazenamento: armazenamento),
        ),
      );
      await testador.pumpAndSettle();
      final excluir = find.byIcon(Icons.delete_outline);
      await testador.ensureVisible(excluir);
      await testador.pumpAndSettle();
      await testador.tap(excluir);
      await testador.pumpAndSettle();
      await tocar(testador, 'Cancelar');
      expect(testador.takeException(), isNull);
    },
  );
}
