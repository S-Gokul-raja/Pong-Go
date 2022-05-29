import 'package:flutter/material.dart';

class Brick extends StatelessWidget {
  final double left, top, height, width;
  final bool shift;
  final Color color;
  const Brick(
      {Key? key,
      required this.left,
      required this.top,
      required this.color,
      required this.height,
      required this.width,
      required this.shift})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      height: height,
      width: width,
      left: left //x
          -
          (width / 2), //width offset
      top: top - (shift ? height : 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 10),
          color: color,
        ),
      ),
    );
  }
}
