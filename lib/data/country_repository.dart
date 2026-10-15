import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/country.dart';

class CountryRepository {
  Future<List<Country>> loadCountries({AssetBundle? bundle}) async {
    final assets = bundle ?? rootBundle;
    final decoded = jsonDecode(
      await assets.loadString('assets/data/countries.json'),
    );
    if (decoded is! List || decoded.isEmpty) {
      throw const FormatException('O catálogo deve ser uma lista não vazia.');
    }
    final countries = <Country>[];
    final codes = <String>{};
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Registro de país inválido.');
      }
      final country = Country.fromJson(item);
      if (!codes.add(country.code)) {
        throw FormatException('Código repetido: ${country.code}.');
      }
      // Confere se cada bandeira foi incluída no pacote de assets.
      final bytes = await assets.load(country.flagAsset);
      if (bytes.lengthInBytes == 0) {
        throw FormatException('Bandeira vazia: ${country.flagAsset}.');
      }
      countries.add(country);
    }
    return List.unmodifiable(countries);
  }
}
