import 'package:flutter/material.dart';

import '../data/country_repository.dart';
import '../models/country.dart';
import '../widgets/menu_action.dart';
import '../widgets/menu_globe.dart';
import 'game_setup_screen.dart';
import 'continent_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Country>? _countries;
  String? _error;
  int _seconds = 60;
  Future<void> _chooseContinent() async {
    final continent = await Navigator.push<Continent>(
      context,
      MaterialPageRoute(builder: (_) => const ContinentScreen()),
    );
    if (!mounted || continent == null) return;
    _prepareGame(continent);
  }

  void _prepareGame(Continent? continent) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => GameSetupScreen(
          countries: _countries!,
          continent: continent,
          seconds: _seconds,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    setState(() {
      _countries = null;
      _error = null;
    });
    try {
      final countries = await CountryRepository().loadCountries();
      if (!mounted) return;
      setState(() => _countries = countries);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'Não foi possível carregar o catálogo local. '
            'Confira o JSON e os arquivos de bandeiras.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_error != null) {
      content = ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(_error!),
          FilledButton(
            onPressed: _loadCountries,
            child: const Text('Tentar novamente'),
          ),
        ],
      );
    } else if (_countries == null) {
      content = const Center(child: CircularProgressIndicator());
    } else {
      content = SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'PT-BR',
                style: TextStyle(
                  color: Color(0xffd4caee),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(child: MenuGlobe()),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'FLAG',
                style: TextStyle(
                  fontSize: 60,
                  height: 1,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w900,
                  color: Color(0xffffcf38),
                  shadows: [
                    Shadow(color: Color(0xff1c1549), offset: Offset(0, 5)),
                  ],
                ),
              ),
            ),
            const Center(
              child: Text(
                'GAME',
                style: TextStyle(
                  fontSize: 60,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  color: Color(0xffff5188),
                  shadows: [
                    Shadow(color: Color(0xff1c1549), offset: Offset(0, 5)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Quanto você sabe sobre bandeiras?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            MenuAction(
              label: 'Jogar por Continente',
              icon: Icons.explore_outlined,
              color: const Color(0xff22cddd),
              shadowColor: const Color(0xff1392a7),
              onPressed: _chooseContinent,
            ),
            const SizedBox(height: 16),
            MenuAction(
              onPressed: () => _prepareGame(null),
              icon: Icons.casino_outlined,
              label: 'Jogo aleatório',
              color: const Color(0xffff5188),
              shadowColor: const Color(0xffb82d66),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: Color(0xffffcf38)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Tempo de jogo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 12,
              children: [
                for (final seconds in [30, 60, 180, 300])
                  ChoiceChip(
                    label: Text(switch (seconds) {
                      180 => '3 min',
                      300 => '5 min',
                      _ => '${seconds}s',
                    }),
                    selected: _seconds == seconds,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _seconds = seconds),
                    selectedColor: const Color(0xffffcf38),
                    backgroundColor: const Color(0xff4d38a6),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    shape: const StadiumBorder(),
                    labelStyle: TextStyle(
                      color: _seconds == seconds
                          ? const Color(0xff2c2068)
                          : Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Tempo total: $_seconds segundos',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${_countries!.length} países carregados',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }
    final menuTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff4d38a6),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xff2c2068),
    );
    return Theme(
      data: menuTheme,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: -55,
              top: 150,
              child: IgnorePointer(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    color: Color(0xff713174),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -65,
              bottom: 160,
              child: IgnorePointer(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    color: Color(0xff305793),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Semantics(
              label: 'Flag Game',
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: content,
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
