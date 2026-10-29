import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:quizzbandeira_app/modelos/pais.dart';
import 'package:quizzbandeira_app/modelos/resultado_partida.dart';
import 'package:quizzbandeira_app/servicos/sessao_quiz.dart';

// Dados sintéticos apenas para testar regras, sem adicionar países ao catálogo.
List<Pais> amostra() => List.generate(
  10,
  (i) => Pais(
    codigo: 'test$i',
    nome: 'País de teste $i',
    continente: i < 5 ? Continente.africa : Continente.america,
    caminhoBandeira: 'teste/$i.svg',
  ),
);

void main() {
  test(
    'Cada ciclo cobre o conjunto sem repetir; alternativas têm uma correta',
    () {
      final sessao = SessaoQuiz(paises: amostra(), sorteador: Random(42));
      for (var ciclo = 0; ciclo < 3; ciclo++) {
        final codigos = <String>{};
        for (var i = 0; i < sessao.quantidadePaises; i++) {
          final pergunta = sessao.proximaPergunta()!;
          expect(codigos.add(pergunta.pais.codigo), isTrue);
          expect(pergunta.alternativas, hasLength(4));
          expect(
            pergunta.alternativas.map((candidato) => candidato.codigo).toSet(),
            hasLength(4),
          );
          expect(
            pergunta.alternativas.where(
              (candidato) => candidato.codigo == pergunta.pais.codigo,
            ),
            hasLength(1),
          );
          expect(
            pergunta.alternativas.every(
              (candidato) => amostra().any((s) => s.codigo == candidato.codigo),
            ),
            isTrue,
          );
          sessao.responder(pergunta.pais.codigo);
        }
        expect(codigos, amostra().map((candidato) => candidato.codigo).toSet());
      }
    },
  );

  test('Filtra perguntas e alternativas pelo continente', () {
    final sessao = SessaoQuiz(
      paises: amostra(),
      continente: Continente.africa,
      sorteador: Random(5),
    );
    expect(sessao.quantidadePaises, 5);
    for (var i = 0; i < 15; i++) {
      final pergunta = sessao.proximaPergunta()!;
      expect(pergunta.pais.continente, Continente.africa);
      expect(
        pergunta.alternativas.every(
          (candidato) => candidato.continente == Continente.africa,
        ),
        isTrue,
      );
      sessao.responder(pergunta.pais.codigo);
    }
  });

  test('Sem continente, ambos os continentes participam do ciclo', () {
    final sessao = SessaoQuiz(paises: amostra(), sorteador: Random(8));
    final continentes = <Continente>{};
    for (var i = 0; i < 10; i++) {
      final pergunta = sessao.proximaPergunta()!;
      continentes.add(pergunta.pais.continente);
      sessao.responder(pergunta.pais.codigo);
    }
    expect(continentes, {Continente.africa, Continente.america});
  });

  test('Bloqueia respostas duplicadas e ignora opções inexistentes', () {
    final sessao = SessaoQuiz(paises: amostra());
    expect(sessao.responder('test0'), isNull);
    final primeira = sessao.proximaPergunta()!;
    expect(sessao.proximaPergunta(), same(primeira));
    expect(sessao.responder('ausente'), isNull);
    expect(sessao.resultado.respondidas, 0);
    expect(sessao.responder(primeira.pais.codigo), isTrue);
    expect(sessao.responder(primeira.pais.codigo), isNull);
    final segunda = sessao.proximaPergunta()!;
    final incorreta = segunda.alternativas.firstWhere(
      (candidato) => candidato.codigo != segunda.pais.codigo,
    );
    expect(sessao.responder(incorreta.codigo), isFalse);
    expect(sessao.resultado.respondidas, 2);
    expect(sessao.resultado.acertos, 1);
    expect(sessao.resultado.pontos, 1);
    expect(sessao.resultado.percentualAcertos, 50);
  });

  test('Conjuntos de zero a três países não geram pergunta', () {
    for (var tamanho = 0; tamanho < 4; tamanho++) {
      final sessao = SessaoQuiz(paises: amostra().take(tamanho).toList());
      expect(sessao.podeJogar, isFalse);
      expect(sessao.proximaPergunta(), isNull);
      expect(sessao.resultado.percentualAcertos, 0);
    }
    final continenteVazio = SessaoQuiz(
      paises: amostra(),
      continente: Continente.oceania,
    );
    expect(continenteVazio.podeJogar, isFalse);
    expect(continenteVazio.proximaPergunta(), isNull);
  });

  test('Quatro países permitem jogar com quatro alternativas', () {
    final sessao = SessaoQuiz(paises: amostra().take(4).toList());
    expect(sessao.podeJogar, isTrue);
    expect(sessao.proximaPergunta()!.alternativas, hasLength(4));
  });

  test('Finalizar bloqueia perguntas e respostas e preserva o resultado', () {
    final sessao = SessaoQuiz(paises: amostra());
    final primeira = sessao.proximaPergunta()!;
    sessao.responder(primeira.pais.codigo);
    final resultadoAnterior = sessao.resultado;
    final pendente = sessao.proximaPergunta()!;
    final resultado = sessao.encerrar();
    expect(sessao.estaEncerrada, isTrue);
    expect(sessao.responder(pendente.pais.codigo), isNull);
    expect(sessao.proximaPergunta(), isNull);
    expect(resultado.respondidas, 1);
    expect(resultado.acertos, 1);
    expect(sessao.encerrar().pontos, 1);
    expect(resultadoAnterior.respondidas, 1);
    final vazio = SessaoQuiz(paises: amostra()).encerrar();
    expect(vazio.percentualAcertos, 0);
  });

  test('Não altera a lista de entrada e protege as alternativas', () {
    final paises = amostra();
    final codigos = paises.map((candidato) => candidato.codigo).toList();
    final sessao = SessaoQuiz(paises: paises);
    paises.clear();
    final pergunta = sessao.proximaPergunta()!;
    expect(sessao.quantidadePaises, codigos.length);
    expect(() => pergunta.alternativas.clear(), throwsUnsupportedError);
    final originais = amostra();
    SessaoQuiz(paises: originais).proximaPergunta();
    expect(originais.map((candidato) => candidato.codigo), codigos);
  });

  test('Rejeita países duplicados na entrada', () {
    final paises = amostra();
    expect(
      () => SessaoQuiz(paises: [...paises, paises.first]),
      throwsArgumentError,
    );
  });

  test('Resultado calcula percentuais e rejeita contagens inválidas', () {
    expect(ResultadoPartida(respondidas: 0, acertos: 0).percentualAcertos, 0);
    expect(
      ResultadoPartida(respondidas: 3, acertos: 1).percentualAcertos,
      closeTo(100 / 3, 0.0001),
    );
    expect(ResultadoPartida(respondidas: 4, acertos: 4).percentualAcertos, 100);
    expect(
      () => ResultadoPartida(respondidas: -1, acertos: 0),
      throwsArgumentError,
    );
    expect(
      () => ResultadoPartida(respondidas: 1, acertos: -1),
      throwsArgumentError,
    );
    expect(
      () => ResultadoPartida(respondidas: 1, acertos: 2),
      throwsArgumentError,
    );
  });
}
