// lib/core/database/rascunho_normas_dao.dart
import 'package:drift/drift.dart';
import 'app_database.dart';

part 'rascunho_normas_dao.g.dart';

@DriftAccessor(tables: [RascunhoNormas])
class RascunhoNormasDao extends DatabaseAccessor<AppDatabase>
    with _$RascunhoNormasDaoMixin {
  RascunhoNormasDao(super.db);

  Future<void> salvar(RascunhoNormasCompanion companion) =>
      into(rascunhoNormas).insert(companion);

  Future<List<RascunhoNorma>> listarDoRascunho(String rascunhoId) =>
      (select(rascunhoNormas)..where((t) => t.rascunhoId.equals(rascunhoId))).get();

  Future<void> marcarVinculado(int id) =>
      (update(rascunhoNormas)..where((t) => t.id.equals(id)))
          .write(const RascunhoNormasCompanion(status: Value('vinculado')));

  Future<void> marcarErro(int id) =>
      (update(rascunhoNormas)..where((t) => t.id.equals(id)))
          .write(const RascunhoNormasCompanion(status: Value('erro')));
}
