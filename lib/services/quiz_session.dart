import 'dart:math';

import '../models/country.dart';
import '../models/game_result.dart';
import '../models/quiz_question.dart';

/// Regras compartilhadas pelos dois formatos de apresentação da pergunta.
class QuizSession {
  QuizSession({
    required List<Country> countries,
    Continent? continent,
    Random? random,
  }) : _random = random ?? Random() {
    final codes = <String>{};
    for (final country in countries) {
      if (!codes.add(country.code)) {
        throw ArgumentError('Código repetido: ${country.code}.');
      }
    }
    _countries = List.unmodifiable(
      countries.where((c) => continent == null || c.continent == continent),
    );
  }

  late final List<Country> _countries;
  final Random _random;
  final List<Country> _remaining = [];
  QuizQuestion? _currentQuestion;
  bool _hasAnswered = false;
  bool _finished = false;
  int _answered = 0;
  int _correct = 0;

  int get countryCount => _countries.length;
  bool get canPlay => countryCount >= 4;
  bool get isFinished => _finished;
  GameResult get result => GameResult(answered: _answered, correct: _correct);

  QuizQuestion? nextQuestion() {
    if (_finished || !canPlay) return null;
    // Pedir novamente a pergunta não permite pular uma resposta pendente.
    if (_currentQuestion != null && !_hasAnswered) return _currentQuestion;
    if (_remaining.isEmpty) {
      _remaining.addAll(_countries);
      _remaining.shuffle(_random);
    }
    final country = _remaining.removeLast();
    final incorrect = _countries.where((c) => c.code != country.code).toList()
      ..shuffle(_random);
    final options = [country, ...incorrect.take(3)]..shuffle(_random);
    _currentQuestion = QuizQuestion(country: country, options: options);
    _hasAnswered = false;
    return _currentQuestion;
  }

  /// Retorna true/false para acerto/erro, ou null se a resposta foi ignorada.
  bool? submitAnswer(String countryCode) {
    final question = _currentQuestion;
    if (_finished || question == null || _hasAnswered) return null;
    if (!question.options.any((c) => c.code == countryCode)) return null;
    final correct = countryCode == question.country.code;
    _hasAnswered = true;
    _answered++;
    if (correct) _correct++;
    return correct;
  }

  // A tela chamará este método quando o tempo total terminar.
  GameResult finish() {
    _finished = true;
    return result;
  }
}
