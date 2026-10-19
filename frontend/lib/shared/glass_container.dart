import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.1,
    this.borderRadius,
    this.padding,
    this.color,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // FIX: On désactive le BackdropFilter temporairement pour éviter le crash sur Pixel 6 Pro
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withOpacity(opacity + 0.05), // On augmente un peu l'opacité pour compenser le flou
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }
}
