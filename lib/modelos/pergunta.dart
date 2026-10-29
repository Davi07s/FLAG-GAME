import 'pais.dart';

class Pergunta {
  Pergunta({required this.pais, required List<Pais> alternativas})
    : alternativas = List.unmodifiable(alternativas);

  final Pais pais;
  final List<Pais> alternativas;
}
