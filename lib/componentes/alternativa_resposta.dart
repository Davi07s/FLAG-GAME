import 'package:flutter/material.dart';

import '../modelos/pais.dart';
import 'imagem_bandeira.dart';

class AlternativaResposta extends StatelessWidget {
  const AlternativaResposta({
    super.key,
    required this.pais,
    required this.indice,
    required this.mostrarBandeira,
    required this.aoPressionar,
    this.estaCorreta = false,
    this.estaErrada = false,
    this.altura,
    this.tamanhoFonte = 20,
  });

  final Pais pais;
  final int indice;
  final bool mostrarBandeira;
  final VoidCallback? aoPressionar;
  final bool estaCorreta;
  final bool estaErrada;
  final double? altura;
  final double tamanhoFonte;

  @override
  Widget build(BuildContext contexto) {
    const corTexto = Color(0xff2c2068);
    Color cor = Colors.white;
    Color corSombra = const Color(0xff6e649c);
    if (estaCorreta) {
      //cor do botão da alternaticva correta selecionada
      cor = const Color(0xff31d780);
      corSombra = const Color(0xff1b9255);
    } else if (estaErrada) {
      //cor do botão da alternativa errada selecionada
      cor = const Color(0xffff5188);
      corSombra = const Color(0xffb82d66);
    } else if (aoPressionar == null) {
      cor = const Color(0xffaaa4c5);
    }
    final situacao = estaCorreta
        ? 'Resposta correta' //mensagem exibida ao acertar a questão
        : 'Sua resposta: incorreta'; //mensagem exibida ao errar a questão
    final indicador = CircleAvatar(
      radius: 18,
      backgroundColor: Colors.white,
      child: Icon(
        estaCorreta ? Icons.check : Icons.close,
        color: estaCorreta
            ? const Color(0xff178d52)
            : const Color(0xffcf234d), //icone muda de cor ao ser precionado
      ),
    );
    final imagem = ImagemBandeira(
      arquivo: pais.caminhoBandeira,
      rotulo: 'Bandeira da alternativa ${indice + 1}',
    );
    final imagemRecortada = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imagem,
    );
    return SizedBox(
      height: altura,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(mostrarBandeira ? 20 : 30),
          boxShadow: [BoxShadow(color: corSombra, offset: const Offset(0, 6))],
        ),
        child: FilledButton(
          onPressed: aoPressionar,
          style: FilledButton.styleFrom(
            minimumSize: Size.fromHeight(altura == null ? 64 : 48),
            padding: EdgeInsets.symmetric(
              horizontal: mostrarBandeira ? 8 : 20,
              vertical: mostrarBandeira
                  ? 8
                  : altura == null
                  ? 16
                  : 8,
            ),
            backgroundColor: cor,
            disabledBackgroundColor: cor,
            foregroundColor: corTexto,
            disabledForegroundColor: corTexto,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(mostrarBandeira ? 20 : 30),
            ),
          ),
          child: mostrarBandeira
              ? Column(
                  mainAxisSize: altura == null
                      ? MainAxisSize.min
                      : MainAxisSize.max,
                  children: [
                    if (altura == null)
                      imagemRecortada
                    else
                      Expanded(child: Center(child: imagemRecortada)),
                    if (estaCorreta || estaErrada) ...[
                      const SizedBox(height: 8),
                      if (altura != null &&
                          altura! < 180 &&
                          MediaQuery.textScalerOf(contexto).scale(16) <= 20)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            indicador,
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                situacao,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        )
                      else ...[
                        indicador,
                        Text(
                          situacao,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, height: 1.2),
                        ),
                      ],
                    ],
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Text(
                        pais.nome,
                        style: TextStyle(
                          fontSize: tamanhoFonte,
                          height: 1.2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (estaCorreta || estaErrada) ...[
                      const SizedBox(width: 12),
                      Semantics(label: situacao, child: indicador),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
