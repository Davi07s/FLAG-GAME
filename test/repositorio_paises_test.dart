import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:quizzbandeira_app/dados/repositorio_paises.dart';
import 'package:quizzbandeira_app/modelos/pais.dart';

Map<String, dynamic> registro() => {
  'code': 'br',
  'name': 'Brasil',
  'continent': 'América',
  'flagAsset': 'assets/flags/br.svg',
};

class PacoteCatalogo extends CachingAssetBundle {
  PacoteCatalogo(this.catalogo, {this.bandeiraAusente = false});
  final Object catalogo;
  final bool bandeiraAusente;

  @override
  Future<ByteData> load(String chave) async {
    if (chave == 'assets/data/countries.json') {
      return ByteData.sublistView(
        Uint8List.fromList(utf8.encode(jsonEncode(catalogo))),
      );
    }
    if (bandeiraAusente) throw FlutterError('Asset ausente: $chave');
    return ByteData.sublistView(Uint8List.fromList([1]));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Converte o JSON para um país tipado', () {
    final pais = Pais.deJson(registro());
    expect(pais.codigo, 'br');
    expect(pais.nome, 'Brasil');
    expect(pais.continente, Continente.america);
    expect(pais.caminhoBandeira, 'assets/flags/br.svg');
  });

  test('Rejeita campos, candidatoódigos, continentes e caminhos inválidos', () {
    for (final alteracao in [
      {'name': ''},
      {'code': 'BRA'},
      {'continent': 'Antártida'},
      {'flagAsset': 'https://example.com/br.svg'},
    ]) {
      expect(
        () => Pais.deJson({...registro(), ...alteracao}),
        throwsFormatException,
      );
    }
  });

  test('Carrega o catálogo real e confere todos os assets locais', () async {
    final paises = await RepositorioPaises().carregarPaises();
    expect(paises, hasLength(195));
    final contagens = {
      Continente.africa: 54,
      Continente.america: 35,
      Continente.asia: 48,
      Continente.europa: 44,
      Continente.oceania: 14,
    };
    for (final entrada in contagens.entries) {
      expect(
        paises.where((candidato) => candidato.continente == entrada.key),
        hasLength(entrada.value),
      );
    }
  });

  test(
    'Rejeita candidatoódigos duplicados e catálogo vazio ou malformado',
    () async {
      for (final catalogo in [
        [],
        {},
        [1],
        [registro(), registro()],
      ]) {
        await expectLater(
          RepositorioPaises().carregarPaises(pacote: PacoteCatalogo(catalogo)),
          throwsFormatException,
        );
      }
    },
  );

  test('Informa falha quando uma bandeira não existe', () async {
    await expectLater(
      RepositorioPaises().carregarPaises(
        pacote: PacoteCatalogo([registro()], bandeiraAusente: true),
      ),
      throwsA(isA<FlutterError>()),
    );
  });
}
