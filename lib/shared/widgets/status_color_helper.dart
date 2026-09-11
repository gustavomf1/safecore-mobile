import 'package:flutter/material.dart';
import '../theme/tokens.dart';

typedef StatusColors = ({Color bg, Color fg});

class StatusColorHelper {
  static StatusColors ncColors(String status, {bool vencida = false}) {
    if (vencida) {
      return (bg: const Color(0xFF4A1017), fg: SafeCoreColors.dark.statusRedFg);
    }
    return switch (status) {
      'CONCLUIDA' || 'FECHADA' || 'APROVADA' => (
          bg: SafeCoreColors.dark.statusGreenBg,
          fg: SafeCoreColors.dark.statusGreenFg,
        ),
      'EM_EXECUCAO' => (
          bg: SafeCoreColors.dark.statusIndigoBg,
          fg: SafeCoreColors.dark.statusIndigoFg,
        ),
      'AGUARDANDO_TRATATIVA' => (
          bg: SafeCoreColors.dark.statusBlueBg,
          fg: SafeCoreColors.dark.statusBlueFg,
        ),
      _ => (
          bg: SafeCoreColors.dark.statusYellowBg,
          fg: SafeCoreColors.dark.statusYellowFg,
        ),
    };
  }

  static StatusColors desvioColors(String status) {
    return switch (status) {
      'CONCLUIDO' || 'FECHADO' || 'APROVADO' => (
          bg: SafeCoreColors.dark.statusGreenBg,
          fg: SafeCoreColors.dark.statusGreenFg,
        ),
      'EM_ANALISE' => (
          bg: SafeCoreColors.dark.statusYellowBg,
          fg: SafeCoreColors.dark.statusYellowFg,
        ),
      _ => (
          bg: SafeCoreColors.dark.bgMuted,
          fg: SafeCoreColors.dark.fg2,
        ),
    };
  }

  static String ncLabel(String status) => const {
        'ABERTA': 'Aberta',
        'EM_EXECUCAO': 'Em Execução',
        'AGUARDANDO_TRATATIVA': 'Aguardando',
        'CONCLUIDA': 'Concluída',
        'FECHADA': 'Fechada',
        'APROVADA': 'Aprovada',
        'REPROVADA': 'Reprovada',
      }[status] ??
      status;

  static String desvioLabel(String status) => const {
        'ABERTO': 'Aberto',
        'EM_ANALISE': 'Em Análise',
        'CONCLUIDO': 'Concluído',
        'FECHADO': 'Fechado',
      }[status] ??
      status;
}
