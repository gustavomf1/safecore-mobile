import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecore_mobile/shared/widgets/status_color_helper.dart';
import 'package:safecore_mobile/shared/theme/tokens.dart';

void main() {
  group('StatusColorHelper.nc', () {
    test('vencida retorna bg vermelho escuro', () {
      final c = StatusColorHelper.ncColors(SafeCoreColors.dark, 'ABERTA', vencida: true);
      expect(c.bg, const Color(0xFF4A1017));
      expect(c.fg, SafeCoreColors.dark.statusRedFg);
    });
    test('CONCLUIDA retorna verde', () {
      final c = StatusColorHelper.ncColors(SafeCoreColors.dark, 'CONCLUIDA', vencida: false);
      expect(c.bg, SafeCoreColors.dark.statusGreenBg);
      expect(c.fg, SafeCoreColors.dark.statusGreenFg);
    });
    test('EM_EXECUCAO retorna índigo', () {
      final c = StatusColorHelper.ncColors(SafeCoreColors.dark, 'EM_EXECUCAO', vencida: false);
      expect(c.bg, SafeCoreColors.dark.statusIndigoBg);
    });
    test('ABERTA default retorna amarelo', () {
      final c = StatusColorHelper.ncColors(SafeCoreColors.dark, 'ABERTA', vencida: false);
      expect(c.bg, SafeCoreColors.dark.statusYellowBg);
    });
  });

  group('StatusColorHelper.desvio', () {
    test('CONCLUIDO retorna verde', () {
      final c = StatusColorHelper.desvioColors(SafeCoreColors.dark, 'CONCLUIDO');
      expect(c.fg, SafeCoreColors.dark.statusGreenFg);
    });
    test('EM_ANALISE retorna amarelo', () {
      final c = StatusColorHelper.desvioColors(SafeCoreColors.dark, 'EM_ANALISE');
      expect(c.bg, SafeCoreColors.dark.statusYellowBg);
    });
  });

  group('StatusColorHelper labels', () {
    test('ncLabel ABERTA', () => expect(StatusColorHelper.ncLabel('ABERTA'), 'Aberta'));
    test('desvioLabel CONCLUIDO', () => expect(StatusColorHelper.desvioLabel('CONCLUIDO'), 'Concluído'));
  });
}
