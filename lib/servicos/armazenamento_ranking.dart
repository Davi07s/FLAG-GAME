import 'dart:convert';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/registro_pontuacao.dart';

class ArmazenamentoRanking {
  ArmazenamentoRanking({this.preferencias});

  final SharedPreferencesAsync? preferencias;
  SharedPreferencesAsync get _dados => preferencias ?? SharedPreferencesAsync();
  static const chaveRanking = 'ranking_flag_game';
  static Future<void>? _fila;

  Future<List<RegistroPontuacao>> listarPontuacoes() async {
    final registros = <RegistroPontuacao>[];
    final ids = <String>{};
    try {
      final texto = await _dados.getString(chaveRanking);
      if (texto == null) return registros;
      final lista = jsonDecode(texto);
      if (lista is! List) return registros;
      for (final dados in lista) {
        try {
          if (dados is! Map<String, dynamic>) continue;
          final registro = RegistroPontuacao.deJson(dados);
          if (ids.add(registro.id)) registros.add(registro);
        } on FormatException {
          continue;
        } on TypeError {
          continue;
        }
      }
    } on FormatException {
      return registros;
    } on TypeError {
      return registros;
    }
    registros.sort((primeiro, segundo) {
      final pontos = segundo.pontuacao.compareTo(primeiro.pontuacao);
      if (pontos != 0) return pontos;
      final percentual = segundo.percentualAcertos.compareTo(
        primeiro.percentualAcertos,
      );
      if (percentual != 0) return percentual;
      final data = segundo.dataPartida.compareTo(primeiro.dataPartida);
      return data != 0 ? data : primeiro.id.compareTo(segundo.id);
    });
    return registros;
  }

  // Serializa alterações para que dois salvamentos não sobrescrevam um ao outro.
  Future<void> _alterar(Future<void> Function() operacao) async {
    final anterior = _fila;
    final liberacao = Completer<void>();
    _fila = liberacao.future;
    try {
      if (anterior != null) await anterior;
      await operacao();
    } finally {
      if (identical(_fila, liberacao.future)) _fila = null;
      liberacao.complete();
    }
  }

  Future<bool> salvarPontuacao(RegistroPontuacao registro) async {
    var salvo = false;
    await _alterar(() async {
      final registros = await listarPontuacoes();
      if (registros.any((item) => item.id == registro.id)) return;
      registros.add(registro);
      await _dados.setString(
        chaveRanking,
        jsonEncode(registros.map((item) => item.paraJson()).toList()),
      );
      salvo = true;
    });
    return salvo;
  }

  Future<void> excluirPontuacao(String id) => _alterar(() async {
    final registros = await listarPontuacoes();
    registros.removeWhere((item) => item.id == id);
    await _dados.setString(
      chaveRanking,
      jsonEncode(registros.map((item) => item.paraJson()).toList()),
    );
  });

  Future<void> limparRanking() => _alterar(() => _dados.remove(chaveRanking));
}
