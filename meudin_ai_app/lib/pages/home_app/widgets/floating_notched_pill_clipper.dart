import 'package:flutter/material.dart';

/// Floating pill clipper: rounded stadium shape intersected with the Material
/// [CircularNotchedRectangle] notch around the docked FAB.
class FloatingNotchedPillClipper extends CustomClipper<Path> {
  const FloatingNotchedPillClipper({
    this.cornerRadius = 28,
    this.fabSize = 56,
    this.notchMargin = 4,
  });

  final double cornerRadius;
  final double fabSize;
  final double notchMargin;

  @override
  Path getClip(Size size) {
    final host = Offset.zero & size;
    final guest = Rect.fromCenter(
      center: Offset(size.width / 2, host.top),
      width: fabSize,
      height: fabSize,
    ).inflate(notchMargin);

    const notchShape = CircularNotchedRectangle();
    final notchedRect = notchShape.getOuterPath(host, guest);

    final pill = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          host,
          Radius.circular(cornerRadius.clamp(0, size.height / 2)),
        ),
      );

    return Path.combine(PathOperation.intersect, pill, notchedRect);
  }

  @override
  bool shouldReclip(covariant FloatingNotchedPillClipper oldClipper) {
    return oldClipper.cornerRadius != cornerRadius ||
        oldClipper.fabSize != fabSize ||
        oldClipper.notchMargin != notchMargin;
  }
}

/// Paints fill, elevation shadow, and subtle border following the pill path.
class FloatingBottomBarPainter extends CustomPainter {
  FloatingBottomBarPainter({
    required this.clipper,
    required this.color,
    required this.borderColor,
    required this.shadowColor,
    required this.elevation,
  });

  final FloatingNotchedPillClipper clipper;
  final Color color;
  final Color borderColor;
  final Color shadowColor;
  final double elevation;

  @override
  void paint(Canvas canvas, Size size) {
    final path = clipper.getClip(size);

    canvas.drawShadow(path, shadowColor, elevation, true);

    canvas.drawPath(path, Paint()..color = color);

    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant FloatingBottomBarPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.elevation != elevation ||
        oldDelegate.clipper != clipper;
  }
}
