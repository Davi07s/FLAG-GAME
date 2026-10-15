import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:quizzbandeira_app/models/country.dart';
import 'package:quizzbandeira_app/models/game_result.dart';
import 'package:quizzbandeira_app/services/quiz_session.dart';

// Dados sintéticos apenas para testar regras, sem adicionar países ao catálogo.
List<Country> sample() => List.generate(
  10,
  (i) => Country(
    code: 'test$i',
    name: 'País de teste $i',
    continent: i < 5 ? Continent.africa : Continent.america,
    flagAsset: 'teste/$i.svg',
  ),
);

void main() {
  test(
    'Cada ciclo cobre o conjunto sem repetir; alternativas têm uma correta',
    () {
      final session = QuizSession(countries: sample(), random: Random(42));
      for (var cycle = 0; cycle < 3; cycle++) {
        final codes = <String>{};
        for (var i = 0; i < session.countryCount; i++) {
          final question = session.nextQuestion()!;
          expect(codes.add(question.country.code), isTrue);
          expect(question.options, hasLength(4));
          expect(question.options.map((c) => c.code).toSet(), hasLength(4));
          expect(
            question.options.where((c) => c.code == question.country.code),
            hasLength(1),
          );
          expect(
            question.options.every(
              (c) => sample().any((s) => s.code == c.code),
            ),
            isTrue,
          );
          session.submitAnswer(question.country.code);
        }
        expect(codes, sample().map((c) => c.code).toSet());
      }
    },
  );

  test('Filtra perguntas e alternativas pelo continente', () {
    final session = QuizSession(
      countries: sample(),
      continent: Continent.africa,
      random: Random(5),
    );
    expect(session.countryCount, 5);
    for (var i = 0; i < 15; i++) {
      final question = session.nextQuestion()!;
      expect(question.country.continent, Continent.africa);
      expect(
        question.options.every((c) => c.continent == Continent.africa),
        isTrue,
      );
      session.submitAnswer(question.country.code);
    }
  });

  test('Sem continente, ambos os continentes participam do ciclo', () {
    final session = QuizSession(countries: sample(), random: Random(8));
    final continents = <Continent>{};
    for (var i = 0; i < 10; i++) {
      final question = session.nextQuestion()!;
      continents.add(question.country.continent);
      session.submitAnswer(question.country.code);
    }
    expect(continents, {Continent.africa, Continent.america});
  });

  test('Bloqueia respostas duplicadas e ignora opções inexistentes', () {
    final session = QuizSession(countries: sample());
    expect(session.submitAnswer('test0'), isNull);
    final first = session.nextQuestion()!;
    expect(session.nextQuestion(), same(first));
    expect(session.submitAnswer('ausente'), isNull);
    expect(session.result.answered, 0);
    expect(session.submitAnswer(first.country.code), isTrue);
    expect(session.submitAnswer(first.country.code), isNull);
    final second = session.nextQuestion()!;
    final wrong = second.options.firstWhere(
      (c) => c.code != second.country.code,
    );
    expect(session.submitAnswer(wrong.code), isFalse);
    expect(session.result.answered, 2);
    expect(session.result.correct, 1);
    expect(session.result.score, 1);
    expect(session.result.accuracy, 50);
  });

  test('Conjuntos de zero a três países não geram pergunta', () {
    for (var size = 0; size < 4; size++) {
      final session = QuizSession(countries: sample().take(size).toList());
      expect(session.canPlay, isFalse);
      expect(session.nextQuestion(), isNull);
      expect(session.result.accuracy, 0);
    }
    final emptyContinent = QuizSession(
      countries: sample(),
      continent: Continent.oceania,
    );
    expect(emptyContinent.canPlay, isFalse);
    expect(emptyContinent.nextQuestion(), isNull);
  });

  test('Quatro países permitem jogar com quatro alternativas', () {
    final session = QuizSession(countries: sample().take(4).toList());
    expect(session.canPlay, isTrue);
    expect(session.nextQuestion()!.options, hasLength(4));
  });

  test('Finalizar bloqueia perguntas e respostas e preserva o resultado', () {
    final session = QuizSession(countries: sample());
    final first = session.nextQuestion()!;
    session.submitAnswer(first.country.code);
    final snapshot = session.result;
    final pending = session.nextQuestion()!;
    final result = session.finish();
    expect(session.isFinished, isTrue);
    expect(session.submitAnswer(pending.country.code), isNull);
    expect(session.nextQuestion(), isNull);
    expect(result.answered, 1);
    expect(result.correct, 1);
    expect(session.finish().score, 1);
    expect(snapshot.answered, 1);
    final empty = QuizSession(countries: sample()).finish();
    expect(empty.accuracy, 0);
  });

  test('Não altera a lista de entrada e protege as alternativas', () {
    final countries = sample();
    final codes = countries.map((c) => c.code).toList();
    final session = QuizSession(countries: countries);
    countries.clear();
    final question = session.nextQuestion()!;
    expect(session.countryCount, codes.length);
    expect(() => question.options.clear(), throwsUnsupportedError);
    final original = sample();
    QuizSession(countries: original).nextQuestion();
    expect(original.map((c) => c.code), codes);
  });

  test('Rejeita países duplicados na entrada', () {
    final countries = sample();
    expect(
      () => QuizSession(countries: [...countries, countries.first]),
      throwsArgumentError,
    );
  });

  test('Resultado calcula percentuais e rejeita contagens inválidas', () {
    expect(GameResult(answered: 0, correct: 0).accuracy, 0);
    expect(
      GameResult(answered: 3, correct: 1).accuracy,
      closeTo(100 / 3, 0.0001),
    );
    expect(GameResult(answered: 4, correct: 4).accuracy, 100);
    expect(() => GameResult(answered: -1, correct: 0), throwsArgumentError);
    expect(() => GameResult(answered: 1, correct: -1), throwsArgumentError);
    expect(() => GameResult(answered: 1, correct: 2), throwsArgumentError);
  });
}
