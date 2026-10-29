import 'dart:math';

import '../modelos/pais.dart';
import '../modelos/pergunta.dart';
import '../modelos/resultado_partida.dart';

/// Regras compartilhadas pelos dois formatos de apresentação da pergunta.
class SessaoQuiz {
  SessaoQuiz({
    required List<Pais> paises,
    Continente? continente,
    Random? sorteador,
  }) : _sorteador = sorteador ?? Random() {
    final codigos = <String>{};
    for (final pais in paises) {
      if (!codigos.add(pais.codigo)) {
        throw ArgumentError('Código repetido: ${pais.codigo}.');
      }
    }
    _paises = List.unmodifiable(
      paises.where(
        (candidato) => continente == null || candidato.continente == continente,
      ),
    );
  }

  late final List<Pais> _paises;
  final Random _sorteador;
  final List<Pais> _restantes = [];
  Pergunta? _perguntaAtual;
  bool _respondeu = false;
  bool _encerrada = false;
  int _respondidas = 0;
  int _acertos = 0;

  int get quantidadePaises => _paises.length;
  bool get podeJogar => quantidadePaises >= 4;
  bool get estaEncerrada => _encerrada;
  ResultadoPartida get resultado =>
      ResultadoPartida(respondidas: _respondidas, acertos: _acertos);

  Pergunta? proximaPergunta() {
    if (_encerrada || !podeJogar) return null;
    // Pedir novamente a pergunta não permite pular uma resposta pendente.
    if (_perguntaAtual != null && !_respondeu) return _perguntaAtual;
    if (_restantes.isEmpty) {
      _restantes.addAll(_paises);
      _restantes.shuffle(_sorteador);
    }
    final pais = _restantes.removeLast();
    final incorretas =
        _paises.where((candidato) => candidato.codigo != pais.codigo).toList()
          ..shuffle(_sorteador);
    final alternativas = [pais, ...incorretas.take(3)]..shuffle(_sorteador);
    _perguntaAtual = Pergunta(pais: pais, alternativas: alternativas);
    _respondeu = false;
    return _perguntaAtual;
  }

  /// Retorna true/false para acerto/erro, ou null se a resposta foi ignorada.
  bool? responder(String codigoPais) {
    final pergunta = _perguntaAtual;
    if (_encerrada || pergunta == null || _respondeu) return null;
    if (!pergunta.alternativas.any(
      (candidato) => candidato.codigo == codigoPais,
    )) {
      return null;
    }
    final acertou = codigoPais == pergunta.pais.codigo;
    _respondeu = true;
    _respondidas++;
    if (acertou) _acertos++;
    return acertou;
  }

  // A tela chamará este método quando o tempo total terminar.
  ResultadoPartida encerrar() {
    _encerrada = true;
    return resultado;
  }
}
