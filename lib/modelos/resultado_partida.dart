class ResultadoPartida {
  ResultadoPartida({required this.respondidas, required this.acertos}) {
    if (respondidas < 0 || acertos < 0 || acertos > respondidas) {
      throw ArgumentError('As contagens de respostas e acertos são inválidas.');
    }
  }

  final int respondidas;
  final int acertos;

  int get pontos => acertos;
  double get percentualAcertos =>
      respondidas == 0 ? 0 : acertos / respondidas * 100;
}
