// lib/core/database/rascunhos_dao.dart
import 'package:drift/drift.dart';
import 'app_database.dart';

part 'rascunhos_dao.g.dart';

@DriftAccessor(tables: [Rascunhos])
class RascunhosDao extends DatabaseAccessor<AppDatabase>
    with _$RascunhosDaoMixin {
  RascunhosDao(super.db);

  Future<void> salvar(RascunhosCompanion companion) =>
      into(rascunhos).insertOnConflictUpdate(companion);

  Future<List<Rascunho>> listarPendentes(String usuarioId) =>
      (select(rascunhos)
            ..where((t) => t.usuarioId.equals(usuarioId) & t.status.equals('sincronizado').not()))
          .get();

  Stream<List<Rascunho>> watchPendentes(String usuarioId) =>
      (select(rascunhos)
            ..where((t) => t.usuarioId.equals(usuarioId) & t.status.equals('sincronizado').not())
            ..orderBy([(t) => OrderingTerm.desc(t.criadoEm)]))
          .watch();

  // Alias de watchPendentes: o brief não define esse método no Step 2, mas
  // a seção "Interfaces" o lista como produto desta task. Como o filtro já
  // usado em watchPendentes (status != 'sincronizado') inclui tanto
  // 'pendente' quanto 'erro', delega para não duplicar a query e divergir
  // dela no futuro.
  Stream<List<Rascunho>> watchTodosPendentesOuErro(String usuarioId) =>
      watchPendentes(usuarioId);

  Future<void> atualizarStatus(
    String id, {
    required String status,
    String? serverId,
    String? erroMensagem,
  }) =>
      (update(rascunhos)..where((t) => t.id.equals(id))).write(
        RascunhosCompanion(
          status: Value(status),
          serverId: serverId != null ? Value(serverId) : const Value.absent(),
          erroMensagem: Value(erroMensagem),
        ),
      );

  Future<void> deletar(String id) =>
      (delete(rascunhos)..where((t) => t.id.equals(id))).go();
}
