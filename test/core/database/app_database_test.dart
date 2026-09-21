// test/core/database/app_database_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecore_mobile/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  test('insert and list rascunho pendente', () async {
    await db.rascunhosDao.salvar(RascunhosCompanion.insert(
      id: '550e8400-e29b-41d4-a716-446655440000',
      usuarioId: 'u1',
      tipo: 'NC',
      titulo: 'Teste NC',
      criadoEm: DateTime.now().millisecondsSinceEpoch,
    ));

    final pendentes = await db.rascunhosDao.listarPendentes('u1');
    expect(pendentes.length, 1);
    expect(pendentes.first.titulo, 'Teste NC');
    expect(pendentes.first.status, 'pendente');
  });

  test('listarPendentes não retorna rascunho de outro usuário', () async {
    await db.rascunhosDao.salvar(RascunhosCompanion.insert(
      id: 'r1', usuarioId: 'u1', tipo: 'NC', titulo: 'De u1',
      criadoEm: DateTime.now().millisecondsSinceEpoch,
    ));
    await db.rascunhosDao.salvar(RascunhosCompanion.insert(
      id: 'r2', usuarioId: 'u2', tipo: 'NC', titulo: 'De u2',
      criadoEm: DateTime.now().millisecondsSinceEpoch,
    ));

    final pendentesU1 = await db.rascunhosDao.listarPendentes('u1');
    expect(pendentesU1.length, 1);
    expect(pendentesU1.first.titulo, 'De u1');
  });

  test('atualizarStatus para sincronizado remove da lista de pendentes', () async {
    await db.rascunhosDao.salvar(RascunhosCompanion.insert(
      id: 'test-id', usuarioId: 'u1', tipo: 'DESVIO', titulo: 'Desvio X',
      criadoEm: DateTime.now().millisecondsSinceEpoch,
    ));

    await db.rascunhosDao.atualizarStatus('test-id', status: 'sincronizado', serverId: 'server-uuid-123');
    final pendentes = await db.rascunhosDao.listarPendentes('u1');
    expect(pendentes, isEmpty);
  });

  test('atualizarStatus para erro mantém erroMensagem', () async {
    await db.rascunhosDao.salvar(RascunhosCompanion.insert(
      id: 'r-erro', usuarioId: 'u1', tipo: 'NC', titulo: 'Falhou',
      criadoEm: DateTime.now().millisecondsSinceEpoch,
    ));
    await db.rascunhosDao.atualizarStatus('r-erro', status: 'erro', erroMensagem: 'falha X');

    final pendentes = await db.rascunhosDao.listarPendentes('u1');
    expect(pendentes.single.status, 'erro');
    expect(pendentes.single.erroMensagem, 'falha X');
  });

  test('RascunhoNormasDao salvar and listarDoRascunho', () async {
    await db.rascunhosDao.salvar(RascunhosCompanion.insert(
      id: 'r1', usuarioId: 'u1', tipo: 'NC', titulo: 'T',
      criadoEm: DateTime.now().millisecondsSinceEpoch,
    ));
    await db.rascunhoNormasDao.salvar(RascunhoNormasCompanion.insert(
      rascunhoId: 'r1', normaId: 'norma-1', textoEditado: 'texto',
    ));

    final normas = await db.rascunhoNormasDao.listarDoRascunho('r1');
    expect(normas.length, 1);
    expect(normas.first.status, 'pendente');
  });

  test('RascunhoFotosDao salvar and marcarEnviado', () async {
    await db.rascunhosDao.salvar(RascunhosCompanion.insert(
      id: 'r1', usuarioId: 'u1', tipo: 'NC', titulo: 'T',
      criadoEm: DateTime.now().millisecondsSinceEpoch,
    ));
    await db.rascunhoFotosDao.salvar(RascunhoFotosCompanion.insert(
      rascunhoId: 'r1', path: '/tmp/foto.jpg', ordem: 0,
    ));

    final fotos = await db.rascunhoFotosDao.listarDoRascunho('r1');
    await db.rascunhoFotosDao.marcarEnviado(fotos.first.id, 'ev-server-1');

    final atualizado = await db.rascunhoFotosDao.listarDoRascunho('r1');
    expect(atualizado.first.status, 'enviado');
    expect(atualizado.first.evidenciaServerId, 'ev-server-1');
  });

  test('ReferenceCacheDao salvar and buscar', () async {
    await db.referenceCacheDao.salvar('normas', '[{"id":"n1"}]');
    final cached = await db.referenceCacheDao.buscar('normas');
    expect(cached, isNotNull);
    expect(cached!.dadosJson, '[{"id":"n1"}]');
  });

  test('ReferenceCacheDao buscar chave inexistente retorna null', () async {
    final cached = await db.referenceCacheDao.buscar('nao-existe');
    expect(cached, isNull);
  });

  test('OcorrenciasCacheDao salvar SUMMARY e DETAIL do mesmo id não colidem', () async {
    await db.ocorrenciasCacheDao.salvar(OcorrenciasCacheCompanion.insert(
      id: 'nc-001', tipo: 'NC', nivel: 'SUMMARY',
      dadosJson: '{"titulo":"resumo"}', usuarioId: 'u1',
      cachedEm: DateTime.now().millisecondsSinceEpoch,
    ));
    await db.ocorrenciasCacheDao.salvar(OcorrenciasCacheCompanion.insert(
      id: 'nc-001', tipo: 'NC', nivel: 'DETAIL',
      dadosJson: '{"titulo":"completo"}', usuarioId: 'u1',
      cachedEm: DateTime.now().millisecondsSinceEpoch,
    ));

    final summary = await db.ocorrenciasCacheDao.buscar('nc-001', 'SUMMARY');
    final detail = await db.ocorrenciasCacheDao.buscar('nc-001', 'DETAIL');
    expect(summary!.dadosJson, '{"titulo":"resumo"}');
    expect(detail!.dadosJson, '{"titulo":"completo"}');
  });

  test('OcorrenciasCacheDao limparTudo esvazia tudo', () async {
    await db.ocorrenciasCacheDao.salvar(OcorrenciasCacheCompanion.insert(
      id: 'nc-001', tipo: 'NC', nivel: 'SUMMARY', dadosJson: '{}',
      usuarioId: 'u1', cachedEm: 0,
    ));
    await db.ocorrenciasCacheDao.limparTudo();
    final restante = await db.ocorrenciasCacheDao.listarPorTipoENivel('NC', 'SUMMARY', 'u1');
    expect(restante, isEmpty);
  });
}
