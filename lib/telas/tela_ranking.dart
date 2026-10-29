import 'package:flutter/material.dart';

import '../componentes/tema_jogo.dart';
import '../modelos/registro_pontuacao.dart';
import '../servicos/armazenamento_ranking.dart';

class TelaRanking extends StatefulWidget {
  const TelaRanking({super.key, this.gerenciar = false, this.armazenamento});
  final bool gerenciar;
  final ArmazenamentoRanking? armazenamento;

  @override
  State<TelaRanking> createState() => _EstadoTelaRanking();
}

class _EstadoTelaRanking extends State<TelaRanking> {
  late final ArmazenamentoRanking _armazenamento;
  List<RegistroPontuacao> _registros = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _armazenamento = widget.armazenamento ?? ArmazenamentoRanking();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final registros = await _armazenamento.listarPontuacoes();
      if (!mounted) return;
      setState(() {
        _registros = registros;
        _carregando = false;
        _erro = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _erro = 'Não foi possível acessar o ranking. Tente novamente.';
      });
    }
  }

  Future<void> _excluir({RegistroPontuacao? registro}) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (contexto) => Theme(
        data: temaJogo,
        child: AlertDialog(
          scrollable: true,
          title: Text(
            registro == null ? 'Limpar ranking?' : 'Excluir pontuação?',
          ),
          content: Text(
            registro == null
                ? 'Todas as pontuações salvas serão removidas.'
                : 'Remover a pontuação de ${registro.nomeJogador}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contexto, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(contexto, true),
              child: const Text('Confirmar exclusão'),
            ),
          ],
        ),
      ),
    );
    if (confirmou != true || !mounted) return;
    setState(() => _carregando = true);
    try {
      if (registro == null) {
        await _armazenamento.limparRanking();
      } else {
        await _armazenamento.excluirPontuacao(registro.id);
      }
      await _carregar();
    } catch (_) {
      if (!mounted) return;
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível excluir. Tente novamente.'),
        ),
      );
    }
  }

  String _data(DateTime data) {
    final local = data.toLocal();
    String dois(int valor) => valor.toString().padLeft(2, '0');
    return '${dois(local.day)}/${dois(local.month)}/${local.year} ${dois(local.hour)}:${dois(local.minute)}';
  }

  @override
  Widget build(BuildContext contexto) => Theme(
    data: temaJogo,
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2c2068),
        foregroundColor: Colors.white,
        title: Text(
          widget.gerenciar ? 'Gerenciar ranking' : 'Ranking',
          style: const TextStyle(
            color: Color(0xffffcf38),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      if (_erro != null) ...[
                        Text(_erro!),
                        TextButton(
                          onPressed: _carregar,
                          child: const Text('Tentar novamente'),
                        ),
                      ] else if (_registros.isEmpty)
                        const Text(
                          'Seu ranking está vazio. Jogue e salve sua primeira pontuação!',
                          textAlign: TextAlign.center,
                        )
                      else ...[
                        if (widget.gerenciar) ...[
                          OutlinedButton.icon(
                            onPressed: () => _excluir(),
                            icon: const Icon(Icons.delete_sweep),
                            label: const Text('Limpar ranking'),
                          ),
                          const SizedBox(height: 16),
                        ],
                        for (
                          var indice = 0;
                          indice < _registros.length;
                          indice++
                        )
                          _cartao(_registros[indice], indice + 1),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    ),
  );

  Widget _cartao(RegistroPontuacao registro, int posicao) => Card(
    color: const Color(0xff4d38a6),
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$posicao. ${registro.nomeJogador}',
            style: const TextStyle(
              color: Color(0xffffcf38),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${registro.pontuacao} acertos de ${registro.totalPerguntas} respostas • ${registro.percentualAcertos.toStringAsFixed(1).replaceAll('.', ',')}%',
          ),
          Text(registro.modoJogo.rotulo),
          Text(registro.continente?.rotulo ?? 'Jogo aleatório'),
          Text('Duração: ${registro.duracaoPartida} segundos'),
          Text(_data(registro.dataPartida)),
          if (widget.gerenciar)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: 'Excluir pontuação de ${registro.nomeJogador}',
                onPressed: () => _excluir(registro: registro),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xffff5188),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
