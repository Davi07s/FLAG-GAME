import 'package:flutter/material.dart';

class MenuAction extends StatelessWidget {
  const MenuAction({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.shadowColor,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color shadowColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: shadowColor,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [BoxShadow(color: shadowColor, offset: const Offset(0, 7))],
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
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
              child: Icon(icon, color: const Color(0xff2c2068), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
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
