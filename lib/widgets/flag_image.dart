import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlagImage extends StatelessWidget {
  const FlagImage({super.key, required this.asset, required this.label});

  final String asset;
  final String label;

  // Os originais usam markers, não suportados pelo renderizador SVG.
  static String renderAsset(String asset) {
    if (asset == 'assets/flags/us.svg' || asset == 'assets/flags/um.svg') {
      return asset.replaceFirst('assets/flags/', 'assets/flags/compatible/');
    }
    return asset;
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 4 / 3,
    child: SvgPicture.asset(
      renderAsset(asset),
      fit: BoxFit.contain,
      semanticsLabel: label,
      placeholderBuilder: (_) =>
          const Center(child: Text('Carregando bandeira…')),
      errorBuilder: (_, error, stackTrace) =>
          const Center(child: Text('Não foi possível exibir a bandeira.')),
    ),
  );
}
