import 'package:flutter/material.dart';

import '../models/country.dart';
import 'flag_image.dart';

class AnswerOption extends StatelessWidget {
  const AnswerOption({
    super.key,
    required this.country,
    required this.index,
    required this.showFlag,
    required this.onPressed,
    this.isCorrect = false,
    this.isWrong = false,
  });

  final Country country;
  final int index;
  final bool showFlag;
  final VoidCallback? onPressed;
  final bool isCorrect;
  final bool isWrong;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xff2c2068);
    final color = isCorrect
        ? const Color(0xff31d780)
        : isWrong
        ? const Color(0xffff5188)
        : onPressed == null
        ? const Color(0xffaaa4c5)
        : Colors.white;
    final status = isCorrect ? 'Resposta correta' : 'Sua resposta: incorreta';
    final indicator = CircleAvatar(
      radius: 18,
      backgroundColor: Colors.white,
      child: Icon(
        isCorrect ? Icons.check : Icons.close,
        color: isCorrect ? const Color(0xff178d52) : const Color(0xffcf234d),
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: isCorrect
                ? const Color(0xff1b9255)
                : isWrong
                ? const Color(0xffb82d66)
                : const Color(0xff6e649c),
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(64),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          backgroundColor: color,
          disabledBackgroundColor: color,
          foregroundColor: ink,
          disabledForegroundColor: ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: showFlag
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FlagImage(
                      asset: country.flagAsset,
                      label: 'Bandeira da alternativa ${index + 1}',
                    ),
                  ),
                  if (isCorrect || isWrong) ...[
                    const SizedBox(height: 8),
                    indicator,
                    Text(status, textAlign: TextAlign.center),
                  ],
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Text(
                      country.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (isCorrect || isWrong) ...[
                    const SizedBox(width: 12),
                    Semantics(label: status, child: indicator),
                  ],
                ],
              ),
      ),
    );
  }
}
