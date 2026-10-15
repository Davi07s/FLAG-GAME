import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizzbandeira_app/data/country_repository.dart';
import 'package:quizzbandeira_app/models/country.dart';

Map<String, dynamic> record() => {
  'code': 'br',
  'name': 'Brasil',
  'continent': 'América',
  'flagAsset': 'assets/flags/br.svg',
};

class CatalogBundle extends CachingAssetBundle {
  CatalogBundle(this.catalog, {this.missingFlag = false});
  final Object catalog;
  final bool missingFlag;

  @override
  Future<ByteData> load(String key) async {
    if (key == 'assets/data/countries.json') {
      return ByteData.sublistView(
        Uint8List.fromList(utf8.encode(jsonEncode(catalog))),
      );
    }
    if (missingFlag) throw FlutterError('Asset ausente: $key');
    return ByteData.sublistView(Uint8List.fromList([1]));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Converte o JSON para um país tipado', () {
    final country = Country.fromJson(record());
    expect(country.code, 'br');
    expect(country.name, 'Brasil');
    expect(country.continent, Continent.america);
    expect(country.flagAsset, 'assets/flags/br.svg');
  });

  test('Rejeita campos, códigos, continentes e caminhos inválidos', () {
    for (final change in [
      {'name': ''},
      {'code': 'BRA'},
      {'continent': 'Antártida'},
      {'flagAsset': 'https://example.com/br.svg'},
    ]) {
      expect(
        () => Country.fromJson({...record(), ...change}),
        throwsFormatException,
      );
    }
  });

  test('Carrega o catálogo real e confere todos os assets locais', () async {
    final countries = await CountryRepository().loadCountries();
    expect(countries, hasLength(195));
    final counts = {
      Continent.africa: 54,
      Continent.america: 35,
      Continent.asia: 48,
      Continent.europe: 44,
      Continent.oceania: 14,
    };
    for (final entry in counts.entries) {
      expect(
        countries.where((c) => c.continent == entry.key),
        hasLength(entry.value),
      );
    }
  });

  test('Rejeita códigos duplicados e catálogo vazio ou malformado', () async {
    for (final catalog in [
      [],
      {},
      [1],
      [record(), record()],
    ]) {
      await expectLater(
        CountryRepository().loadCountries(bundle: CatalogBundle(catalog)),
        throwsFormatException,
      );
    }
  });

  test('Informa falha quando uma bandeira não existe', () async {
    await expectLater(
      CountryRepository().loadCountries(
        bundle: CatalogBundle([record()], missingFlag: true),
      ),
      throwsA(isA<FlutterError>()),
    );
  });
}
