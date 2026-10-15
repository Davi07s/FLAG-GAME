class GameResult {
  GameResult({required this.answered, required this.correct}) {
    if (answered < 0 || correct < 0 || correct > answered) {
      throw ArgumentError('As contagens de respostas e acertos são inválidas.');
    }
  }

  final int answered;
  final int correct;

  int get score => correct;
  double get accuracy => answered == 0 ? 0 : correct / answered * 100;// calcyla a porcentagem de acerto
}
