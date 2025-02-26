import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'cdk_theme_notifier.dart';
import 'cdk_theme.dart';

// Copyright © 2023 Albert Palacios. All Rights Reserved.
// Licensed under the BSD 3-clause license, see LICENSE file for details.
/// The [CDKPicker360] class is a Flutter stateful widget representing a circular picker
/// for selecting values within a 360-degree range.
///
/// <img src="/flutter_cupertino_desktop_kit/gh-pages/doc-images/CDKPicker_360_0.png" alt="CDKButton Example" style="max-width: 500px; width: 100%;">
///
/// Example usage:
/// ```dart
/// CDKPicker360(
///   value: 180.0,
///   size: 24.0,
///   enabled: true,
///   onChanged: (double value) {
///     // Handle the value change event.
///   },
/// )
/// ```

///
/// Parameters:
/// * `value`: The initial value of the picker within the 360-degree range.
/// * `size`: The size of the picker. Defaults to `16`.
/// * `enabled`: Indicates whether the picker is enabled for user interaction. Defaults to `true`.
/// * `onChanged`: Callback function called when the value in the picker changes. Must not be null.

class CDKPicker360 extends StatefulWidget {
  final double value;
  final double size;
  final bool enabled;
  final Function(double)? onChanged;

  const CDKPicker360(
      {Key? key,
      required this.value,
      this.enabled = true,
      this.size = 16,
      required this.onChanged})
      : super(key: key);

  @override
  CDKPicker360State createState() => CDKPicker360State();
}

class CDKPicker360State extends State<CDKPicker360> {
  void _onPanUpdate(DragUpdateDetails details) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final halfSize = widget.size / 2;
    final position = renderBox.globalToLocal(details.globalPosition);
    final double angle =
        (math.atan2(position.dy - halfSize, position.dx - halfSize) *
                180 /
                math.pi) %
            360;

    widget.onChanged?.call(angle);
  }

  @override
  Widget build(BuildContext context) {
    CDKTheme theme = CDKThemeNotifier.of(context)!.changeNotifier;

    return GestureDetector(
      onPanUpdate: !widget.enabled ? null : _onPanUpdate,
      child: CustomPaint(
        painter: CDKPicker360Painter(
            theme.backgroundSecondary0,
            widget.value,
            widget.enabled ? theme.colorText : CDKTheme.grey,
            theme.isLight ? CDKTheme.grey100 : CDKTheme.grey),
        size: Size(widget.size, widget.size),
      ),
    );
  }
}

class CDKPicker360Painter extends CustomPainter {
  final Color colorBackgroundSecondary0;
  final double angle;
  final Color borderColor;
  final Color pickerColor;

  CDKPicker360Painter(this.colorBackgroundSecondary0, this.angle,
      this.pickerColor, this.borderColor);

  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final angleInRadians = (math.pi / 180) * angle;

    // Dibuixar la sombra
    final shadowPaint = Paint()
      ..color = CDKTheme.grey50
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);
    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.drawShadow(circlePath, shadowPaint.color, 1, false);

    // Dibuixar el cercle principal
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = colorBackgroundSecondary0;
    canvas.drawCircle(center, radius, paint);

    final paintBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..color = borderColor;
    canvas.drawCircle(center, radius, paintBorder);

    // Dibuixar el punt que indica l'angle
    radius = radius - 3;
    final markerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = pickerColor;
    final markerPosition = Offset(
      center.dx + radius * math.cos(angleInRadians),
      center.dy + radius * math.sin(angleInRadians),
    );
    canvas.drawCircle(markerPosition, 3, markerPaint);
  }

  @override
  bool shouldRepaint(covariant CDKPicker360Painter oldDelegate) {
    return oldDelegate.angle != angle ||
        oldDelegate.colorBackgroundSecondary0 != colorBackgroundSecondary0 ||
        oldDelegate.pickerColor != pickerColor ||
        oldDelegate.borderColor != borderColor;
  }
}
