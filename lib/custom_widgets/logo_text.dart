import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class LogoText extends StatelessWidget {

  final double fontSize;
  LogoText({this.fontSize:30.0});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Tic Tac Go",
      style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          foreground: Paint()
            ..shader = ui.Gradient.linear(
              const Offset(0, 20),
              const Offset(150, 200),
              <Color>[
                Color(0xFF6F35A5),
                Color(0xFF1A237E),
              ],
            )
      ),
    );
  }
}