import 'dart:math';

import 'modo_pergunta.dart';
import 'pais.dart';

class RegistroPontuacao {
  RegistroPontuacao({
    required this.id,
    required String nomeJogador,
    required this.pontuacao,
    required this.totalPerguntas,
    required this.modoJogo,
    required this.continente,
    required this.duracaoPartida,
    required this.dataPartida,
  }) : nomeJogador = nomeJogador.trim(),
       percentualAcertos = totalPerguntas == 0
           ? 0
           : pontuacao / totalPerguntas * 100 {
    if (id.trim().isEmpty ||
        this.nomeJogador.isEmpty ||
        this.nomeJogador.runes.length > 20 ||
        pontuacao < 0 ||
        totalPerguntas < pontuacao ||
        totalPerguntas < 0 ||
        duracaoPartida <= 0) {
      throw const FormatException('Registro de pontuação inválido.');
    }
  }

  final String id;
  final String nomeJogador;
  final int pontuacao;
  final int totalPerguntas;
  final double percentualAcertos;
  final ModoPergunta modoJogo;
  final Continente? continente;
  final int duracaoPartida;
  final DateTime dataPartida;

  static String gerarId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';

  Map<String, dynamic> paraJson() => {
    'id': id,
    'nomeJogador': nomeJogador,
    'pontuacao': pontuacao,
    'totalPerguntas': totalPerguntas,
    'percentualAcertos': percentualAcertos,
    'modoJogo': modoJogo == ModoPergunta.bandeiraParaPais
        ? 'tradicional'
        : 'inverso',
    'continente': continente?.name ?? 'aleatorio',
    'duracaoPartida': duracaoPartida,
    'dataPartida': dataPartida.toUtc().toIso8601String(),
  };

  factory RegistroPontuacao.deJson(Map<String, dynamic> dados) {
    final modo = switch (dados['modoJogo']) {
      'tradicional' => ModoPergunta.bandeiraParaPais,
      'inverso' => ModoPergunta.paisParaBandeira,
      _ => throw const FormatException('Modo inválido.'),
    };
    final continente = dados['continente'] == 'aleatorio'
        ? null
        : Continente.values.firstWhere(
            (item) => item.name == dados['continente'],
            orElse: () => throw const FormatException('Continente inválido.'),
          );
    final registro = RegistroPontuacao(
      id: dados['id'] as String,
      nomeJogador: dados['nomeJogador'] as String,
      pontuacao: dados['pontuacao'] as int,
      totalPerguntas: dados['totalPerguntas'] as int,
      modoJogo: modo,
      continente: continente,
      duracaoPartida: dados['duracaoPartida'] as int,
      dataPartida: DateTime.parse(dados['dataPartida'] as String),
    );
    final percentual = dados['percentualAcertos'];
    if (percentual is! num ||
        !percentual.isFinite ||
        (percentual - registro.percentualAcertos).abs() > .001) {
      throw const FormatException('Percentual inválido.');
    }
    return registro;
  }
}
