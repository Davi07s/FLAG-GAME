import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizzbandeira_app/data/country_repository.dart';
import 'package:quizzbandeira_app/models/country.dart';
import 'package:quizzbandeira_app/services/quiz_session.dart';
import 'package:quizzbandeira_app/widgets/flag_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Todos os 271 SVGs estão inventariados, sem duplicados ou exclusões silenciosas', () async {
    final countries = await CountryRepository().loadCountries();
    final others = jsonDecode(
      await rootBundle.loadString('assets/data/other_flags.json'),
    ) as List;
    final records = [
      ...countries.map((c) => {'code': c.code, 'flagAsset': c.flagAsset}),
      ...others.cast<Map<String, dynamic>>(),
    ];
    expect(records, hasLength(271));
    expect(records.map((r) => r['code']).toSet(), hasLength(271));
    expect(others, hasLength(76));
    final diskAssets = Directory('assets/flags')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.svg'))
        .map((f) => f.path.replaceAll('\\', '/'))
        .toSet();
    expect(records.map((r) => r['flagAsset']).toSet(), diskAssets);
    final codes = countries.map((c) => c.code).toSet();
    for (final record in records) {
      expect(record['flagAsset'], 'assets/flags/${record['code']}.svg');
      expect(
        (await rootBundle.load(record['flagAsset'] as String)).lengthInBytes,
        greaterThan(0),
      );
    }
    for (final code in [
      'eu',
      'un',
      'xx',
      'pc',
      'xk',
      'tw',
      'gb-eng',
      'aq',
      'pr',
      'ck',
      'nu',
    ]) {
      expect(codes.contains(code), isFalse, reason: code);
    }
    expect(codes.contains('ps'), isTrue);
    expect(codes.contains('va'), isTrue);
  });

  test(
    'Correspondências de nomes e continentes, incluindo transcontinentais',
    () async {
      final countries = await CountryRepository().loadCountries();
      final reference = {
        'br': ['Brasil', Continent.america],
        'ca': ['Canadá', Continent.america],
        'eg': ['Egito', Continent.africa],
        'za': ['África do Sul', Continent.africa],
        'cd': ['República Democrática do Congo', Continent.africa],
        'cg': ['República do Congo', Continent.africa],
        'ru': ['Rússia', Continent.europe],
        'gb': ['Reino Unido', Continent.europe],
        'va': ['Vaticano', Continent.europe],
        'tr': ['Turquia', Continent.asia],
        'cy': ['Chipre', Continent.asia],
        'ge': ['Geórgia', Continent.asia],
        'am': ['Armênia', Continent.asia],
        'az': ['Azerbaijão', Continent.asia],
        'kz': ['Cazaquistão', Continent.asia],
        'id': ['Indonésia', Continent.asia],
        'tl': ['Timor-Leste', Continent.asia],
        'ps': ['Palestina', Continent.asia],
        'au': ['Austrália', Continent.oceania],
        'fm': ['Micronésia', Continent.oceania],
      };
      for (final entry in reference.entries) {
        final country = countries.singleWhere((c) => c.code == entry.key);
        expect(country.name, entry.value[0]);
        expect(country.continent, entry.value[1]);
        expect(country.flagAsset, 'assets/flags/${entry.key}.svg');
      }
    },
  );

  test(
    'Cada continente percorre todos os seus países e restringe alternativas',
    () async {
      final countries = await CountryRepository().loadCountries();
      for (final continent in [null, ...Continent.values]) {
        final eligible = countries
            .where((c) => continent == null || c.continent == continent)
            .map((c) => c.code)
            .toSet();
        final session = QuizSession(
          countries: countries,
          continent: continent,
          random: Random(42),
        );
        final seen = <String>{};
        for (var i = 0; i < eligible.length; i++) {
          final question = session.nextQuestion()!;
          expect(seen.add(question.country.code), isTrue);
          expect(question.options.map((c) => c.code).toSet(), hasLength(4));
          expect(
            question.options.every((c) => eligible.contains(c.code)),
            isTrue,
          );
          expect(
            question.options.where((c) => c.code == question.country.code),
            hasLength(1),
          );
          session.submitAnswer(question.country.code);
        }
        expect(seen, eligible);
      }
    },
  );

  test(
    'flutter_svg consegue decodificar todas as 195 bandeiras do jogo',
    () async {
      final countries = await CountryRepository().loadCountries();
      for (final country in countries) {
        final bytes = await SvgAssetLoader(
          FlagImage.renderAsset(country.flagAsset),
        ).loadBytes(null);
        expect(bytes.lengthInBytes, greaterThan(0), reason: country.code);
      }
    },
  );
}
