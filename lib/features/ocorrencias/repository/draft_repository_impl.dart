import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/rascunho_local.dart';
import 'draft_repository.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/rascunhos_dao.dart';

final draftRepositoryProvider = Provider<DraftRepository>((ref) {
  return DraftRepositoryImpl(dao: ref.watch(appDatabaseProvider).rascunhosDao);
});

final draftsProvider = StreamProvider.family<List<RascunhoLocal>, String>((ref, usuarioId) {
  return ref.watch(draftRepositoryProvider).watchPendentes(usuarioId);
});

class DraftRepositoryImpl implements DraftRepository {
  final RascunhosDao dao;

  DraftRepositoryImpl({required this.dao});

  @override
  Stream<List<RascunhoLocal>> watchPendentes(String usuarioId) {
    return dao.watchPendentes(usuarioId).map(
          (list) => list.map(_toModel).toList(),
        );
  }

  @override
  Future<void> salvar(RascunhoLocal rascunho) async {
    await dao.salvar(RascunhosCompanion.insert(
      id: rascunho.id,
      usuarioId: rascunho.usuarioId,
      tipo: rascunho.tipo,
      titulo: rascunho.titulo,
      descricao: Value(rascunho.descricao),
      severidade: Value(rascunho.severidade),
      latitude: Value(rascunho.latitude),
      longitude: Value(rascunho.longitude),
      capturedAt: Value(rascunho.capturedAt),
      cidade: Value(rascunho.cidade),
      dadosJson: Value(rascunho.dadosJsonEncoded),
      criadoEm: rascunho.criadoEm,
      status: Value(rascunho.status),
    ));
  }

  @override
  Future<void> atualizarStatus(
    String id, {
    required String status,
    String? serverId,
    String? erroMensagem,
  }) =>
      dao.atualizarStatus(id, status: status, serverId: serverId, erroMensagem: erroMensagem);

  @override
  Future<void> deletar(String id) => dao.deletar(id);

  RascunhoLocal _toModel(Rascunho row) => RascunhoLocal(
        id: row.id,
        usuarioId: row.usuarioId,
        tipo: row.tipo,
        titulo: row.titulo,
        descricao: row.descricao,
        severidade: row.severidade,
        latitude: row.latitude,
        longitude: row.longitude,
        capturedAt: row.capturedAt,
        cidade: row.cidade,
        dadosJson: row.dadosJson == null
            ? const {}
            : jsonDecode(row.dadosJson!) as Map<String, dynamic>,
        criadoEm: row.criadoEm,
        status: row.status,
        erroMensagem: row.erroMensagem,
        serverId: row.serverId,
      );
}
