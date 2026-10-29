import 'dart:convert';

import 'package:flutter/services.dart';

import '../modelos/pais.dart';

class RepositorioPaises {
  Future<List<Pais>> carregarPaises({AssetBundle? pacote}) async {
    final arquivos = pacote ?? rootBundle;
    final conteudo = jsonDecode(
      await arquivos.loadString('assets/data/countries.json'),
    );
    if (conteudo is! List || conteudo.isEmpty) {
      throw const FormatException('O catálogo deve ser uma lista não vazia.');
    }
    final paises = <Pais>[];
    final codigos = <String>{};
    for (final item in conteudo) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Registro de país inválido.');
      }
      final pais = Pais.deJson(item);
      if (!codigos.add(pais.codigo)) {
        throw FormatException('Código repetido: ${pais.codigo}.');
      }
      // Confere se cada bandeira foi incluída no pacote de assets.
      final dadosBytes = await arquivos.load(pais.caminhoBandeira);
      if (dadosBytes.lengthInBytes == 0) {
        throw FormatException('Bandeira vazia: ${pais.caminhoBandeira}.');
      }
      paises.add(pais);
    }
    return List.unmodifiable(paises);
  }
}
