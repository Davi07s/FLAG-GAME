import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quizzbandeira_app/modelos/modo_pergunta.dart';
import 'package:quizzbandeira_app/modelos/pais.dart';
import 'package:quizzbandeira_app/modelos/registro_pontuacao.dart';
import 'package:quizzbandeira_app/servicos/armazenamento_ranking.dart';

import 'apoio/preferencias_em_memoria.dart';

RegistroPontuacao registro({
  String id = 'partida-1',
  String nome = '  Ana  ',
  int pontos = 4,
  int total = 5,
  int dia = 1,
  ModoPergunta modo = ModoPergunta.bandeiraParaPais,
  Continente? continente = Continente.america,
}) => RegistroPontuacao(
  id: id,
  nomeJogador: nome,
  pontuacao: pontos,
  totalPerguntas: total,
  modoJogo: modo,
  continente: continente,
  duracaoPartida: 180,
  dataPartida: DateTime.utc(2026, 10, dia, 12),
);

void main() {
  late Map<String, String> dados;
  late ArmazenamentoRanking armazenamento;
  setUp(() {
    dados = {};
    armazenamento = ArmazenamentoRanking(
      preferencias: PreferenciasEmMemoria(dados),
    );
  });

  test('JSON preserva todos os dados, nome aparado e os dois modos', () {
    for (final modo in ModoPergunta.values) {
      final original = registro(modo: modo, continente: null);
      final recuperado = RegistroPontuacao.deJson(
        jsonDecode(jsonEncode(original.paraJson())) as Map<String, dynamic>,
      );
      expect(recuperado.paraJson(), original.paraJson());
      expect(recuperado.nomeJogador, 'Ana');
      expect(recuperado.percentualAcertos, 80);
      expect(recuperado.modoJogo, modo);
      expect(recuperado.continente, isNull);
    }
    expect(registro(pontos: 0, total: 0).percentualAcertos, 0);
    expect(
      List.generate(1000, (_) => RegistroPontuacao.gerarId()).toSet(),
      hasLength(1000),
    );
  });

  test('Rejeita nomes vazios, longos, pontuação e JSON inconsistentes', () {
    expect(() => registro(nome: '  '), throwsFormatException);
    expect(
      () => registro(nome: '123456789012345678901'),
      throwsFormatException,
    );
    expect(() => registro(pontos: 6), throwsFormatException);
    expect(
      () => RegistroPontuacao.deJson({
        ...registro().paraJson(),
        'percentualAcertos': 99,
      }),
      throwsFormatException,
    );
  });

  test('Recupera registros com novas instâncias sem limpar os dados', () async {
    await armazenamento.salvarPontuacao(registro());
    final reaberto = ArmazenamentoRanking(
      preferencias: PreferenciasEmMemoria(dados),
    );
    final pontuacoes = await reaberto.listarPontuacoes();
    expect(pontuacoes.single.paraJson(), registro().paraJson());
    expect(dados[ArmazenamentoRanking.chaveRanking], isNotNull);
  });

  test('Impede duplicados e preserva gravações simultâneas', () async {
    final resultados = await Future.wait([
      armazenamento.salvarPontuacao(registro()),
      armazenamento.salvarPontuacao(registro()),
      armazenamento.salvarPontuacao(registro(id: 'outra')),
    ]);
    expect(resultados, [true, false, true]);
    expect(await armazenamento.listarPontuacoes(), hasLength(2));
  });

  test('Ordena por acertos, percentual e data mais recente', () async {
    for (final item in [
      registro(id: 'antiga', pontos: 4, total: 4),
      registro(id: 'nova', pontos: 4, total: 4, dia: 2),
      registro(id: 'percentual-menor'),
      registro(id: 'mais-acertos', pontos: 5, total: 10),
    ]) {
      await armazenamento.salvarPontuacao(item);
    }
    expect((await armazenamento.listarPontuacoes()).map((item) => item.id), [
      'mais-acertos',
      'nova',
      'antiga',
      'percentual-menor',
    ]);
  });

  test('Lista vazia e dados inválidos não derrubam leitura; preserva registros válidos', () async {
    expect(await armazenamento.listarPontuacoes(), isEmpty);
    for (final conteudo in ['invalido', '{}', 'null', '[3, null, {}]']) {
      dados[ArmazenamentoRanking.chaveRanking] = conteudo;
      expect(await armazenamento.listarPontuacoes(), isEmpty);
      expect(dados[ArmazenamentoRanking.chaveRanking], conteudo);
    }
    dados[ArmazenamentoRanking.chaveRanking] = jsonEncode([
      registro().paraJson(),
      {},
      registro().paraJson(),
    ]);
    expect(await armazenamento.listarPontuacoes(), hasLength(1));
  });

  test(
    'Exclui apenas o ID escolhido e limpa somente a chave do ranking',
    () async {
      await armazenamento.salvarPontuacao(registro());
      await armazenamento.salvarPontuacao(registro(id: 'outra'));
      await armazenamento.excluirPontuacao('partida-1');
      expect((await armazenamento.listarPontuacoes()).single.id, 'outra');
      dados['outra_preferencia'] = 'preservar';
      await armazenamento.limparRanking();
      expect(await armazenamento.listarPontuacoes(), isEmpty);
      expect(dados['outra_preferencia'], 'preservar');
    },
  );

  test('Falha de escrita não bloqueia operações futuras', () async {
    final preferencias = PreferenciasEmMemoria(dados, falharGravacao: true);
    final servico = ArmazenamentoRanking(preferencias: preferencias);
    await expectLater(servico.salvarPontuacao(registro()), throwsStateError);
    final saudavel = ArmazenamentoRanking(
      preferencias: PreferenciasEmMemoria(dados),
    );
    expect(await saudavel.salvarPontuacao(registro()), isTrue);
  });
}
