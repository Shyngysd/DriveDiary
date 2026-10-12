import 'package:flutter/material.dart';

class TornEdgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height - 10);
    for (var x = 0.0; x < size.width; x += 12) {
      path.lineTo(x + 6, size.height - 4);
      path.lineTo(x + 12, size.height - 10);
    }
    path
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant TornEdgeClipper oldClipper) => false;
}
