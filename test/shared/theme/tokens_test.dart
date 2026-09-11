import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecore_mobile/shared/theme/tokens.dart';

void main() {
  group('SafeCoreColors.dark', () {
    test('bgBase corresponde ao ProtoColors.bg original', () {
      expect(SafeCoreColors.dark.bgBase, const Color(0xFF0B1118));
    });
    test('bgSurface corresponde ao ProtoColors.surface original', () {
      expect(SafeCoreColors.dark.bgSurface, const Color(0xFF151A21));
    });
    test('accent corresponde ao ProtoColors.blue original', () {
      expect(SafeCoreColors.dark.accent, const Color(0xFF58A6FF));
    });
    test('fg0 corresponde ao ProtoColors.text original', () {
      expect(SafeCoreColors.dark.fg0, const Color(0xFFF8FBFF));
    });
  });

  group('SafeCoreMotion', () {
    test('fast é 180ms', () {
      expect(SafeCoreMotion.fast, const Duration(milliseconds: 180));
    });
    test('base é 240ms', () {
      expect(SafeCoreMotion.base, const Duration(milliseconds: 240));
    });
  });
}
