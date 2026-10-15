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
    final colors = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.all(12),
        side: BorderSide(
          width: isCorrect || isWrong ? 3 : 1,
          color: isCorrect
              ? Colors.green
              : isWrong
              ? colors.error
              : colors.outline,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showFlag)
            Expanded(
              child: FlagImage(
                asset: country.flagAsset,
                label: 'Bandeira da alternativa ${index + 1}',
              ),
            )
          else
            Text(country.name),
          if (isCorrect || isWrong)
            Text(isCorrect ? 'Resposta correta' : 'Sua resposta: incorreta'),
        ],
      ),
    );
  }
}
