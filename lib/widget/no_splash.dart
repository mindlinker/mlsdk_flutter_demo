

import 'package:flutter/material.dart';

class NoSplash extends InteractiveInkFeature {
  /// Create an [InteractiveInkFeature] that doesn't paint a splash.
  NoSplash({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Color color,
    VoidCallback? onRemoved,
  }) : super(controller: controller, referenceBox: referenceBox, color: color, onRemoved: onRemoved);

  /// Used to specify this type of ink splash for an [InkWell], [InkResponse]
  /// material [Theme], or [ButtonStyle].
  static const InteractiveInkFeatureFactory splashFactory = _NoSplashFactory();

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {
  }
}

class _NoSplashFactory extends InteractiveInkFeatureFactory {
  const _NoSplashFactory();

  @override
  InteractiveInkFeature create({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Offset position,
    required Color color,
    required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  }) {
    return NoSplash(
      controller: controller,
      referenceBox: referenceBox,
      color: color,
    );
  }
}