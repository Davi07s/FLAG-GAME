import 'package:flutter/material.dart';

import '../data/country_repository.dart';
import '../models/country.dart';
import 'game_setup_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Country>? _countries;
  String? _error;
  int _seconds = 60;

  Future<void> _configureTime() async {
    final seconds = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(initialSeconds: _seconds),
      ),
    );
    if (!mounted || seconds == null) return;
    setState(() => _seconds = seconds);
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
      content = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${_countries!.length} países carregados',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text('Tempo total: $_seconds segundos'),
          const Text('Bandeiras locais. Escolha como jogar.'),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _configureTime,
            icon: const Icon(Icons.timer_outlined),
            label: const Text('Configuração de tempo'),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _prepareGame(null),
            icon: const Icon(Icons.shuffle),
            label: const Text('Jogo aleatório'),
          ),
          const SizedBox(height: 24),
          Text(
            'Jogar por continente',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          for (final continent in Continent.values)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton(
                onPressed: () => _prepareGame(continent),
                child: Text(continent.label),
              ),
            ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Flag Game')),
      body: SafeArea(child: content),
    );
  }
}
