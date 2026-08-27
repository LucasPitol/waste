import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meudin_ai_app/pages/home_app/widgets/floating_notched_pill_clipper.dart';

void main() {
  test('pill notch clipper produces valid path with top cutout', () {
    const clipper = FloatingNotchedPillClipper();
    const size = Size(350, 56);
    final path = clipper.getClip(size);

    expect(path.getBounds().isEmpty, isFalse);
    expect(path.contains(const Offset(175, 0)), isFalse);
    expect(path.contains(const Offset(30, 50)), isTrue);
  });
}
