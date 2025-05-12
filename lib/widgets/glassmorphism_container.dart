import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:medimaster/constant/app_constant_colors.dart';

class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius borderRadius;
  final Border? border;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;

  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.2,
    this.borderRadius = const BorderRadius.all(Radius.circular(15)),
    this.border,
    this.gradient,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: AppConstantColors.white.withValues(alpha: (opacity * 255).toDouble()),
          borderRadius: borderRadius,
          border:
              border ??
              Border.all(
                color: AppConstantColors.white.withValues(alpha: 77.0), // 0.3 * 255 ≈ 77
                width: 1.5,
              ),
          boxShadow: [
            BoxShadow(
              color: AppConstantColors.black.withValues(alpha: 51.0), // 0.2 * 255 ≈ 51
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
          gradient:
              gradient ??
              LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppConstantColors.white.withValues(alpha: 128.0), // 0.5 * 255 ≈ 128
                  AppConstantColors.white.withValues(alpha: 51.0), // 0.2 * 255 ≈ 51
                ],
              ),
        ),
        child: child,
      ),
    );
  }
}
