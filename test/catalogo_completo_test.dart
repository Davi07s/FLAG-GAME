import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:quizzbandeira_app/componentes/imagem_bandeira.dart';
import 'package:quizzbandeira_app/dados/repositorio_paises.dart';
import 'package:quizzbandeira_app/modelos/pais.dart';
import 'package:quizzbandeira_app/servicos/sessao_quiz.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Todos os 271 SVGs estão inventariados, sem duplicados ou exclusões silenciosas', () async {
    final paises = await RepositorioPaises().carregarPaises();
    final outros = jsonDecode(
      await rootBundle.loadString('assets/data/other_flags.json'),
    ) as List;
    final registros = [
      ...paises.map(
        (candidato) => {
          'code': candidato.codigo,
          'flagAsset': candidato.caminhoBandeira,
        },
      ),
      ...outros.cast<Map<String, dynamic>>(),
    ];
    expect(registros, hasLength(271));
    expect(registros.map((r) => r['code']).toSet(), hasLength(271));
    expect(outros, hasLength(76));
    final arquivosDisco = Directory('assets/flags')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.svg'))
        .map((f) => f.path.replaceAll('\\', '/'))
        .toSet();
    expect(registros.map((r) => r['flagAsset']).toSet(), arquivosDisco);
    final codigos = paises.map((candidato) => candidato.codigo).toSet();
    for (final registro in registros) {
      expect(registro['flagAsset'], 'assets/flags/${registro['code']}.svg');
      expect(
        (await rootBundle.load(registro['flagAsset'] as String)).lengthInBytes,
        greaterThan(0),
      );
    }
    for (final codigo in [
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
      expect(codigos.contains(codigo), isFalse, reason: codigo);
    }
    expect(codigos.contains('ps'), isTrue);
    expect(codigos.contains('va'), isTrue);
  });

  test(
    'Correspondências de nomes e continentes, incluindo transcontinentais',
    () async {
      final paises = await RepositorioPaises().carregarPaises();
      final referencia = {
        'br': ['Brasil', Continente.america],
        'ca': ['Canadá', Continente.america],
        'eg': ['Egito', Continente.africa],
        'za': ['África do Sul', Continente.africa],
        'cd': ['República Democrática do Congo', Continente.africa],
        'cg': ['República do Congo', Continente.africa],
        'ru': ['Rússia', Continente.europa],
        'gb': ['Reino Unido', Continente.europa],
        'va': ['Vaticano', Continente.europa],
        'tr': ['Turquia', Continente.asia],
        'cy': ['Chipre', Continente.asia],
        'ge': ['Geórgia', Continente.asia],
        'am': ['Armênia', Continente.asia],
        'az': ['Azerbaijão', Continente.asia],
        'kz': ['Cazaquistão', Continente.asia],
        'id': ['Indonésia', Continente.asia],
        'tl': ['Timor-Leste', Continente.asia],
        'ps': ['Palestina', Continente.asia],
        'au': ['Austrália', Continente.oceania],
        'fm': ['Micronésia', Continente.oceania],
      };
      for (final entrada in referencia.entries) {
        final pais = paises.singleWhere(
          (candidato) => candidato.codigo == entrada.key,
        );
        expect(pais.nome, entrada.value[0]);
        expect(pais.continente, entrada.value[1]);
        expect(pais.caminhoBandeira, 'assets/flags/${entrada.key}.svg');
      }
    },
  );

  test(
    'Cada continente percorre todos os seus países e restringe alternativas',
    () async {
      final paises = await RepositorioPaises().carregarPaises();
      for (final continente in [null, ...Continente.values]) {
        final elegiveis = paises
            .where(
              (candidato) =>
                  continente == null || candidato.continente == continente,
            )
            .map((candidato) => candidato.codigo)
            .toSet();
        final sessao = SessaoQuiz(
          paises: paises,
          continente: continente,
          sorteador: Random(42),
        );
        final vistos = <String>{};
        for (var i = 0; i < elegiveis.length; i++) {
          final pergunta = sessao.proximaPergunta()!;
          expect(vistos.add(pergunta.pais.codigo), isTrue);
          expect(
            pergunta.alternativas.map((candidato) => candidato.codigo).toSet(),
            hasLength(4),
          );
          expect(
            pergunta.alternativas.every(
              (candidato) => elegiveis.contains(candidato.codigo),
            ),
            isTrue,
          );
          expect(
            pergunta.alternativas.where(
              (candidato) => candidato.codigo == pergunta.pais.codigo,
            ),
            hasLength(1),
          );
          sessao.responder(pergunta.pais.codigo);
        }
        expect(vistos, elegiveis);
      }
    },
  );

  test(
    'flutter_svg consegue decodificar todas as 195 bandeiras do jogo',
    () async {
      final paises = await RepositorioPaises().carregarPaises();
      for (final pais in paises) {
        final dadosBytes = await SvgAssetLoader(
          ImagemBandeira.caminhoRenderizacao(pais.caminhoBandeira),
        ).loadBytes(null);
        expect(dadosBytes.lengthInBytes, greaterThan(0), reason: pais.codigo);
      }
    },
  );
}
