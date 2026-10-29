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
        appBar: AppBar(
          backgroundColor: const Color(0xff2c2068),
          foregroundColor: Colors.white,
          title: const Text(
            'Preparar partida',
            style: TextStyle(
              color: Color(0xffffcf38),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xff4d38a6),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xff1c1549),
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.public,
                            color: Color(0xffffcf38),
                            size: 36,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.continent?.label ?? 'Jogo aleatório',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Tempo total: ${widget.seconds} segundos'),
                          const SizedBox(height: 6),
                          Text('$count países disponíveis'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Formato da pergunta',
                      style: TextStyle(
                        color: Color(0xffffcf38),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final mode in QuizMode.values) _modeCard(mode),
                    const SizedBox(height: 16),
                    Text(
                      'Modo selecionado: ${_mode.label}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xffd4caee),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (count < 4)
                      const Text(
                        'Este conjunto precisa de pelo menos quatro países para jogar.',
                      ),
                    const SizedBox(height: 16),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xff31d780),
                        foregroundColor: const Color(0xff2c2068),
                        disabledBackgroundColor: const Color(0xffaaa4c5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 22,
                        ),
                        elevation: 5,
                        shadowColor: const Color(0xff1b9255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(36),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeCard(QuizMode mode) {
    final selected = _mode == mode;
    final color = mode == QuizMode.flagToCountry
        ? const Color(0xff22cddd)
        : const Color(0xffff5188);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Semantics(
        selected: selected,
        child: Material(
          color: selected ? color : const Color(0xff4d38a6),
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            onTap: () => setState(() => _mode = mode),
            borderRadius: BorderRadius.circular(28),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: color, width: 2),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      mode == QuizMode.flagToCountry
                          ? Icons.flag_outlined
                          : Icons.image_outlined,
                      color: const Color(0xff2c2068),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mode.label,
                          style: TextStyle(
                            color: selected
                                ? const Color(0xff2c2068)
                                : Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          mode.description,
                          style: TextStyle(
                            color: selected
                                ? const Color(0xff2c2068)
                                : const Color(0xffd4caee),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: selected ? const Color(0xff2c2068) : Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
