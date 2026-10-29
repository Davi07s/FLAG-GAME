import 'package:flutter/material.dart';

class AcaoMenu extends StatelessWidget {
  const AcaoMenu({
    super.key,
    required this.rotulo,
    required this.icone,
    required this.cor,
    required this.corSombra,
    required this.aoPressionar,
  });

  final String rotulo;
  final IconData icone;
  final Color cor;
  final Color corSombra;
  final VoidCallback aoPressionar;

  @override
  Widget build(BuildContext contexto) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: corSombra,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [BoxShadow(color: corSombra, offset: const Offset(0, 7))],
      ),
      child: FilledButton(
        onPressed: aoPressionar,
        style: FilledButton.styleFrom(
          backgroundColor: cor,
          foregroundColor: const Color(0xff2c2068),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(36),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Icon(icone, color: const Color(0xff2c2068), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                rotulo,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
