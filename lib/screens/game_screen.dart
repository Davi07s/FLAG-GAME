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
    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.mode.label)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(widget.continent?.label ?? 'Jogo aleatório'),
            Text('Tempo restante: $_remaining s'),
            Text('Pontos: ${_session.result.score}'),
            const SizedBox(height: 16),
            if (!_session.canPlay)
              const Text('São necessários pelo menos quatro países para jogar.')
            else if (question != null) ...[
              Text(
                flagAnswers
                    ? 'Qual é a bandeira de ${question.country.name}?'
                    : 'A qual país pertence esta bandeira?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (!flagAnswers)
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: FlagImage(
                      asset: question.country.flagAsset,
                      label: 'Bandeira do país da pergunta',
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              if (_correct != null)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _correct!
                        ? 'Acertou!'
                        : 'Errou! Resposta correta: ${question.country.name}.',
                  ),
                ),
              if (flagAnswers)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                  children: [
                    for (var i = 0; i < question.options.length; i++)
                      _option(question, i, true),
                  ],
                )
              else
                for (var i = 0; i < question.options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _option(question, i, false),
                  ),
            ],
          ],
        ),
      ),
    );
  }

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
