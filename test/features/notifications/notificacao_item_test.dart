import 'package:flutter_test/flutter_test.dart';
import 'package:engseg_mobile/features/notifications/model/notificacao_item.dart';

void main() {
  test('fromJson parseia ncId e desvioId como nullable', () {
    final json = {
      'id': 'notif-1',
      'ncId': 'nc-1',
      'desvioId': 'dev-1',
      'tipo': 'DESVIO_ATIVADO',
      'titulo': 'Titulo',
      'corpo': 'Corpo',
      'lida': false,
      'criadoEm': '2026-06-19T10:00:00',
    };

    final item = NotificacaoItem.fromJson(json);

    expect(item.ncId, 'nc-1');
    expect(item.desvioId, 'dev-1');
  });

  test('fromJson aceita ncId null e desvioId null', () {
    final json = {
      'id': 'notif-2',
      'ncId': null,
      'desvioId': null,
      'tipo': 'NC_ATIVADA',
      'titulo': 'Titulo',
      'corpo': 'Corpo',
      'lida': true,
      'criadoEm': '2026-06-19T10:00:00',
    };

    final item = NotificacaoItem.fromJson(json);

    expect(item.ncId, isNull);
    expect(item.desvioId, isNull);
  });

  test('fromJson aceita ausencia de desvioId no JSON (campo ausente)', () {
    final json = {
      'id': 'notif-3',
      'ncId': 'nc-3',
      'tipo': 'NC_ATIVADA',
      'titulo': 'Titulo',
      'corpo': 'Corpo',
      'lida': false,
      'criadoEm': '2026-06-19T10:00:00',
    };

    final item = NotificacaoItem.fromJson(json);

    expect(item.ncId, 'nc-3');
    expect(item.desvioId, isNull);
  });

  test('fromJson aceita ausencia de ncId no JSON (campo ausente)', () {
    final json = {
      'id': 'notif-4',
      'desvioId': 'dev-4',
      'tipo': 'DESVIO_ATIVADO',
      'titulo': 'Titulo',
      'corpo': 'Corpo',
      'lida': false,
      'criadoEm': '2026-06-19T10:00:00',
    };

    final item = NotificacaoItem.fromJson(json);

    expect(item.ncId, isNull);
    expect(item.desvioId, 'dev-4');
  });
}
