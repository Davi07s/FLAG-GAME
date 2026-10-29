import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/country.dart';
import '../models/quiz_mode.dart';
import '../models/quiz_question.dart';
import '../services/quiz_session.dart';
import '../widgets/answer_option.dart';
import '../widgets/flag_image.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.countries,
    required this.continent,
    required this.mode,
    required this.seconds,
  }) : assert(seconds > 0);

  final List<Country> countries;
  final Continent? continent;
  final QuizMode mode;
  final int seconds;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late final QuizSession _session;
  late final DateTime _deadline;
  late int _remaining;
  QuizQuestion? _question;
  Timer? _timer;
  Timer? _advanceTimer;
  String? _selectedCode;
  bool? _correct;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session = QuizSession(
      countries: widget.countries,
      continent: widget.continent,
    );
    _question = _session.nextQuestion();
    _remaining = widget.seconds;
    _deadline = DateTime.now().add(Duration(seconds: widget.seconds));
    if (_session.canPlay) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || _finished) return;
        // O prazo real também cobre atrasos do timer e tempo em segundo plano.
        final wallSeconds =
            (_deadline.difference(DateTime.now()).inMilliseconds / 1000).ceil();
        _remaining = max(0, min(widget.seconds - timer.tick, wallSeconds));
        if (_remaining == 0) {
          _finish();
        } else {
          setState(() {});
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || _finished || !_session.canPlay) {
      return;
    }
    final seconds = (_deadline.difference(DateTime.now()).inMilliseconds / 1000)
        .ceil();
    _remaining = max(0, min(_remaining, seconds));
    if (_remaining == 0) {
      _finish();
    } else {
      setState(() {});
    }
  }

  bool get _expired => _remaining <= 0 || !DateTime.now().isBefore(_deadline);

  void _answer(String code) {
    if (_finished || _selectedCode != null) return;
    if (_expired) {
      _finish();
      return;
    }
    final correct = _session.submitAnswer(code);
    if (correct == null) return;
    setState(() {
      _selectedCode = code;
      _correct = correct;
    });
    _advanceTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted || _finished) return;
      if (_expired) {
        _finish();
        return;
      }
      setState(() {
        _question = _session.nextQuestion();
        _selectedCode = null;
        _correct = null;
      });
    });
  }

  void _finish() {
    if (!mounted || _finished) return;
    _timer?.cancel();
    _advanceTimer?.cancel();
    final result = _session.finish();
    _remaining = 0;
    // Marcar antes de navegar impede que dois callbacks abram resultados.
    _finished = true;
    final replay = GameScreen(
      countries: widget.countries,
      continent: widget.continent,
      mode: widget.mode,
      seconds: widget.seconds,
    );
    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ResultScreen(result: result, replayBuilder: (_) => replay),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _advanceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = _question;
    final flagAnswers = widget.mode == QuizMode.countryToFlag;
    final clock =
        '${_remaining ~/ 60}:${(_remaining % 60).toString().padLeft(2, '0')}';
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
              top: 160,
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
              right: -60,
              bottom: 180,
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
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            IconButton.filled(
                              onPressed: () => Navigator.maybePop(context),
                              tooltip: 'Sair da partida',
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xff4d38a6),
                              ),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                            _statusPill(
                              Icons.star,
                              'Pontos: ${_session.result.score}',
                              const Color(0xffffcf38),
                            ),
                            Semantics(
                              label: 'Tempo restante: $_remaining segundos',
                              child: _statusPill(
                                Icons.schedule,
                                clock,
                                const Color(0xffff5188),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: _remaining / widget.seconds,
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(12),
                          backgroundColor: const Color(0xff4d38a6),
                          color: const Color(0xff31d780),
                          semanticsLabel: 'Tempo restante da partida',
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.mode.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xffd4caee)),
                        ),
                        Text(
                          widget.continent?.label ?? 'Jogo aleatório',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xffd4caee)),
                        ),
                        const SizedBox(height: 20),
                        if (!_session.canPlay)
                          const Text(
                            'São necessários pelo menos quatro países para jogar.',
                          )
                        else if (question != null) ...[
                          if (!flagAnswers)
                            Center(
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 360,
                                ),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xff1c1549),
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: FlagImage(
                                    asset: question.country.flagAsset,
                                    label: 'Bandeira do país da pergunta',
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 22),
                          Text(
                            flagAnswers
                                ? 'Qual é a bandeira de ${question.country.name}?'
                                : 'A qual país pertence esta bandeira?',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_correct != null)
                            Semantics(
                              liveRegion: true,
                              child: Text(
                                _correct!
                                    ? 'Acertou!'
                                    : 'Errou! Resposta correta: ${question.country.name}.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (flagAnswers)
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final oneColumn =
                                    constraints.maxWidth < 280 ||
                                    MediaQuery.textScalerOf(context).scale(20) >
                                        28;
                                final width = oneColumn
                                    ? constraints.maxWidth
                                    : (constraints.maxWidth - 16) / 2;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Wrap(
                                    spacing: 16,
                                    runSpacing: 18,
                                    children: [
                                      for (
                                        var i = 0;
                                        i < question.options.length;
                                        i++
                                      )
                                        SizedBox(
                                          width: width,
                                          child: _option(question, i, true),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            )
                          else
                            for (var i = 0; i < question.options.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(top: 14),
                                child: _option(question, i, false),
                              ),
                        ],
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

  Widget _statusPill(IconData icon, String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(32),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xff2c2068)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xff2c2068),
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _option(QuizQuestion question, int index, bool showFlag) {
    final country = question.options[index];
    return AnswerOption(
      key: ValueKey(country.code),
      country: country,
      index: index,
      showFlag: showFlag,
      onPressed: !_finished && _selectedCode == null
          ? () => _answer(country.code)
          : null,
      isCorrect: _selectedCode != null && country.code == question.country.code,
      isWrong: _selectedCode == country.code && _correct == false,
    );
  }
}
