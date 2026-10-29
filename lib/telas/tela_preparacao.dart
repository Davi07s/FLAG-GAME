import 'package:flutter/material.dart';

import '../componentes/tema_jogo.dart';
import '../modelos/modo_pergunta.dart';
import '../modelos/pais.dart';
import 'tela_jogo.dart';

class TelaPreparacao extends StatefulWidget {
  const TelaPreparacao({
    super.key,
    required this.paises,
    required this.continente,
    required this.segundos,
  });

  final List<Pais> paises;
  final Continente? continente;
  final int segundos;

  @override
  State<TelaPreparacao> createState() => _EstadoTelaPreparacao();
}

class _EstadoTelaPreparacao extends State<TelaPreparacao> {
  ModoPergunta _modo = ModoPergunta.bandeiraParaPais;

  @override
  Widget build(BuildContext contexto) {
    final quantidade = widget.paises
        .where(
          (pais) =>
              widget.continente == null || pais.continente == widget.continente,
        )
        .length;

    return Theme(
      data: temaJogo,
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
                            widget.continente?.rotulo ?? 'Jogo aleatório',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Tempo total: ${widget.segundos} segundos'),
                          const SizedBox(height: 6),
                          Text('$quantidade países disponíveis'),
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
                    for (final modo in ModoPergunta.values) _cartaoModo(modo),
                    const SizedBox(height: 16),
                    Text(
                      'Modo selecionado: ${_modo.rotulo}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xffd4caee),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (quantidade < 4)
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
                      onPressed: quantidade < 4
                          ? null
                          : () => Navigator.pushReplacement<void, void>(
                              contexto,
                              MaterialPageRoute(
                                builder: (_) => TelaJogo(
                                  paises: widget.paises,
                                  continente: widget.continente,
                                  modo: _modo,
                                  segundos: widget.segundos,
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

  Widget _cartaoModo(ModoPergunta modo) {
    final selecionado = _modo == modo;
    final cor = modo == ModoPergunta.bandeiraParaPais
        ? const Color(0xff22cddd)
        : const Color(0xffff5188);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Semantics(
        selected: selecionado,
        child: Material(
          color: selecionado ? cor : const Color(0xff4d38a6),
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            onTap: () => setState(() => _modo = modo),
            borderRadius: BorderRadius.circular(28),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: cor, width: 2),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      modo == ModoPergunta.bandeiraParaPais
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
                          modo.rotulo,
                          style: TextStyle(
                            color: selecionado
                                ? const Color(0xff2c2068)
                                : Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          modo.descricao,
                          style: TextStyle(
                            color: selecionado
                                ? const Color(0xff2c2068)
                                : const Color(0xffd4caee),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    selecionado
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: selecionado ? const Color(0xff2c2068) : Colors.white,
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
