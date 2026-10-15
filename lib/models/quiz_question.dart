import 'country.dart';

class QuizQuestion {
  QuizQuestion({required this.country, required List<Country> options})
    : options = List.unmodifiable(options);

  final Country country;
  final List<Country> options;
}
