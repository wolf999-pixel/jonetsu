import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class NeonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;

  const NeonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: const Color.fromRGBO(229, 57, 53, 0.35),
          width: 1.2,
        ),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(229, 57, 53, 0.16),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}
