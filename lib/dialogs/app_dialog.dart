import 'dart:math';
import 'package:flutter/material.dart';

class AppDialog extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final ShapeBorder? shape;
  final EdgeInsets? insetPadding;

  const AppDialog({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.shape,
    this.insetPadding,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxH = height ?? screenSize.height * 0.8;
    final maxW = width ?? min(screenSize.width * 0.8, 520.0);

    return Dialog(
      shape: shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: insetPadding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxH,
          maxWidth: maxW,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: child,
        ),
      ),
    );
  }
}
