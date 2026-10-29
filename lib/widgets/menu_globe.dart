import 'package:flutter/material.dart';

/// Ilustração decorativa em widgets; não representa uma bandeira do catálogo.
class MenuGlobe extends StatelessWidget {
  const MenuGlobe({super.key});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: 140,
      height: 145,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 10,
            child: Container(
              width: 136,
              height: 136,
              decoration: const BoxDecoration(
                color: Color(0xff22cddd),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 30,
            top: 42,
            child: Transform.rotate(
              angle: -.3,
              child: Container(
                width: 43,
                height: 52,
                decoration: BorderRadiusDecoration.green,
              ),
            ),
          ),
          Positioned(
            left: 80,
            top: 83,
            child: Transform.rotate(
              angle: .3,
              child: Container(
                width: 30,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xffffcf38),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Positioned(
            left: 28,
            top: 30,
            child: Container(
              width: 36,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xff8ee9e8),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            right: 22,
            top: 13,
            child: Container(
              width: 5,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const Positioned(
            right: 0,
            top: 2,
            child: Icon(Icons.flag, color: Color(0xffff5188), size: 38),
          ),
        ],
      ),
    ),
  );
}

class BorderRadiusDecoration {
  static final green = BoxDecoration(
    color: const Color(0xff31d780),
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(28),
      topRight: Radius.circular(24),
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(32),
    ),
  );
}
