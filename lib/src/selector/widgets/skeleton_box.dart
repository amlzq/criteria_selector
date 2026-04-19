import 'dart:math';

import 'package:flutter/material.dart';

import '../selector_theme.dart';

/// A shimmering wrapper used for loading skeleton UIs.
///
/// The shimmer is applied to [child] via a moving linear gradient shader.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
    this.interval = Duration.zero,
    this.colors,
  });

  final Widget child;
  final Duration duration;
  final Duration interval;
  final List<Color>? colors;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  Animation? gradientPosition;

  CurvedAnimation? curvedAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    curvedAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.linear,
    );
    gradientPosition = Tween<double>(
      begin: -3,
      end: 10,
    ).animate(curvedAnimation!);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.interval != Duration.zero) {
          Future.delayed(widget.interval, () {
            if (mounted) {
              controller.forward(from: 0);
            }
          });
        } else {
          if (mounted) {
            controller.forward(from: 0);
          }
        }
      }
    });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    curvedAnimation?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(gradientPosition?.value ?? 0, 0),
              end: const Alignment(-1, 0),
              colors: widget.colors ??
                  const [
                    Color(0x05FFFFFF),
                    Color(0x80FFFFFF),
                    Color(0x05FFFFFF),
                  ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A rectangular placeholder used inside [SkeletonBox].
class SkeletonTile extends StatelessWidget {
  final double? height;
  final double? width;
  final Color? color;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  final Random? random;
  final double widthUsed;

  const SkeletonTile({
    super.key,
    this.height,
    this.width,
    this.color,
    this.border,
    this.borderRadius,
    this.random,
    this.widthUsed = 0,
  });

  @override
  Widget build(BuildContext context) {
    var effectiveWidth = width;
    if (random != null) {
      final screenHalfWidth = (MediaQuery.of(context).size.width ~/ 2).toInt();
      effectiveWidth = (random!.nextInt(screenHalfWidth - widthUsed.toInt()) +
              screenHalfWidth)
          .toDouble();
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: effectiveWidth?.toDouble(),
        height: height,
        decoration: BoxDecoration(
          border: border,
          borderRadius: borderRadius,
          color: color ?? SelectorTheme.of(context).backgroundColorHigh,
        ),
      ),
    );
  }
}
