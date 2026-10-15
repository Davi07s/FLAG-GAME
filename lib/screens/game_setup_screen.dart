import 'package:flutter/material.dart';

import '../models/country.dart';
import '../models/quiz_mode.dart';
import 'game_screen.dart';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({
    super.key,
    required this.countries,
    required this.continent,
    required this.seconds,
  });

  final List<Country> countries;
  final Continent? continent;
  final int seconds;

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  QuizMode _mode = QuizMode.flagToCountry;

  @override
  Widget build(BuildContext context) {
    final count = widget.countries
        .where(
          (country) =>
              widget.continent == null || country.continent == widget.continent,
        )
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Preparar partida')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              widget.continent?.label ?? 'Jogo aleatório',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text('Tempo total: ${widget.seconds} segundos'),
            Text('$count países disponíveis'),
            const SizedBox(height: 24),
            Text(
              'Formato da pergunta',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            for (final mode in QuizMode.values)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(mode.label),
                subtitle: Text(mode.description),
                selected: _mode == mode,
                leading: Icon(
                  _mode == mode
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                onTap: () => setState(() => _mode = mode),
              ),
            const SizedBox(height: 16),
            Text('Modo selecionado: ${_mode.label}'),
            const SizedBox(height: 16),
            if (count < 4)
              const Text(
                'Este conjunto precisa de pelo menos quatro países para jogar.',
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: count < 4
                  ? null
                  : () => Navigator.pushReplacement<void, void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GameScreen(
                          countries: widget.countries,
                          continent: widget.continent,
                          mode: _mode,
                          seconds: widget.seconds,
                        ),
                      ),
                    ),
              child: const Text('Iniciar partida'),
            ),
          ],
        ),
      ),
    );
  }
}
