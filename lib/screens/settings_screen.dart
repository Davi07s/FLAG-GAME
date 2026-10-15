import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.initialSeconds});

  final int initialSeconds;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _seconds;

  @override
  void initState() {
    super.initState();
    _seconds = widget.initialSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuração de tempo')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Escolha o tempo total da partida.'),
            const SizedBox(height: 16),
            for (final seconds in [30, 60, 180, 300])
              ListTile(
                title: Text('$seconds segundos'),
                selected: _seconds == seconds,
                leading: Icon(
                  _seconds == seconds
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                onTap: () => setState(() => _seconds = seconds),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context, _seconds),
              child: const Text('Salvar tempo'),
            ),
          ],
        ),
      ),
    );
  }
}
