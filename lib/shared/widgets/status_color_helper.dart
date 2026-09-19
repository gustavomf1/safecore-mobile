import 'package:flutter/material.dart';
import '../theme/tokens.dart';

typedef StatusColors = ({Color bg, Color fg});

class StatusColorHelper {
  // Was hard-coded to SafeCoreColors.dark, so status pills never adapted to
  // light mode. Both methods now take the active theme's colors explicitly
  // — call as StatusColorHelper.ncColors(context.c, status).
  static StatusColors ncColors(SafeCoreColors c, String status, {bool vencida = false}) {
    if (vencida) {
      return (bg: c.statusRedBg, fg: c.statusRedFg);
    }
    return switch (status) {
      'CONCLUIDA' || 'FECHADA' || 'APROVADA' => (bg: c.statusGreenBg, fg: c.statusGreenFg),
      'EM_EXECUCAO' => (bg: c.statusIndigoBg, fg: c.statusIndigoFg),
      'AGUARDANDO_TRATATIVA' => (bg: c.statusBlueBg, fg: c.statusBlueFg),
      _ => (bg: c.statusYellowBg, fg: c.statusYellowFg),
    };
  }

  static StatusColors desvioColors(SafeCoreColors c, String status) {
    return switch (status) {
      'CONCLUIDO' || 'FECHADO' || 'APROVADO' => (bg: c.statusGreenBg, fg: c.statusGreenFg),
      'EM_ANALISE' => (bg: c.statusYellowBg, fg: c.statusYellowFg),
      _ => (bg: c.bgMuted, fg: c.fg2),
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
