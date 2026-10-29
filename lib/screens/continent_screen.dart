import 'package:flutter/material.dart';

import '../models/country.dart';

class ContinentScreen extends StatelessWidget {
  const ContinentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff4d38a6),
          brightness: Brightness.dark,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xff2c2068),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: -55,
              top: 150,
              child: Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: Color(0xff713174),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -65,
              bottom: 160,
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: Color(0xff305793),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            IconButton.filled(
                              onPressed: () => Navigator.pop(context),
                              tooltip: 'Voltar ao menu',
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xff4d38a6),
                              ),
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Escolha o continente',
                                style: TextStyle(
                                  color: Color(0xffffcf38),
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final singleColumn =
                                constraints.maxWidth < 280 ||
                                MediaQuery.textScalerOf(context).scale(20) > 28;
                            final cardWidth = singleColumn
                                ? constraints.maxWidth
                                : (constraints.maxWidth - 16) / 2;
                            return Wrap(
                              spacing: 16,
                              runSpacing: 22,
                              children: [
                                for (final continent in Continent.values)
                                  SizedBox(
                                    width: continent == Continent.oceania
                                        ? constraints.maxWidth
                                        : cardWidth,
                                    child: _ContinentCard(continent: continent),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'As bandeiras serão sorteadas só do continente escolhido',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xffd4caee),
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinentCard extends StatelessWidget {
  const _ContinentCard({required this.continent});

  final Continent continent;

  @override
  Widget build(BuildContext context) {
    final (color, shadow, icon) = switch (continent) {
      Continent.africa => (
        const Color(0xffff8b36),
        const Color(0xffb95a25),
        Icons.wb_sunny,
      ),
      Continent.america => (
        const Color(0xff31d780),
        const Color(0xff1b9255),
        Icons.landscape,
      ),
      Continent.asia => (
        const Color(0xffff5188),
        const Color(0xffb82d66),
        Icons.temple_buddhist,
      ),
      Continent.europe => (
        const Color(0xff6ba3ff),
        const Color(0xff3e64b8),
        Icons.location_city,
      ),
      Continent.oceania => (
        const Color(0xff22cddd),
        const Color(0xff1392a7),
        Icons.beach_access,
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 7))],
      ),
      child: FilledButton(
        onPressed: () => Navigator.pop(context, continent),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: const Color(0xff2c2068),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          minimumSize: const Size(0, 152),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(icon, color: color, size: 36),
            ),
            const SizedBox(height: 14),
            Text(
              continent.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
