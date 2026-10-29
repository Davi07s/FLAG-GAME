import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class ImagemBandeira extends StatelessWidget {
  const ImagemBandeira({
    super.key,
    required this.arquivo,
    required this.rotulo,
  });

  final String arquivo;
  final String rotulo;

  // Os originais usam markers, não suportados pelo renderizador SVG.
  static String caminhoRenderizacao(String arquivo) {
    if (arquivo == 'assets/flags/us.svg' || arquivo == 'assets/flags/um.svg') {
      return arquivo.replaceFirst('assets/flags/', 'assets/flags/compatible/');
    }
    return arquivo;
  }

  @override
  Widget build(BuildContext contexto) => AspectRatio(
    aspectRatio: 4 / 3,
    child: SvgPicture.asset(
      caminhoRenderizacao(arquivo),
      fit: BoxFit.contain,
      semanticsLabel: rotulo,
      placeholderBuilder: (_) =>
          const Center(child: Text('Carregando bandeira…')),
      errorBuilder: (_, erro, rastroErro) =>
          const Center(child: Text('Não foi possível exibir a bandeira.')),
    ),
  );
}
