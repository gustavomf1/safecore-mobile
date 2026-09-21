// lib/core/database/reference_cache_dao.dart
import 'package:drift/drift.dart';
import 'app_database.dart';

part 'reference_cache_dao.g.dart';

@DriftAccessor(tables: [ReferenceCache])
class ReferenceCacheDao extends DatabaseAccessor<AppDatabase>
    with _$ReferenceCacheDaoMixin {
  ReferenceCacheDao(super.db);

  Future<void> salvar(String chave, String dadosJson) =>
      into(referenceCache).insertOnConflictUpdate(ReferenceCacheCompanion.insert(
        chave: chave,
        dadosJson: dadosJson,
        atualizadoEm: DateTime.now().millisecondsSinceEpoch,
      ));

  Future<ReferenceCacheData?> buscar(String chave) =>
      (select(referenceCache)..where((t) => t.chave.equals(chave))).getSingleOrNull();
}
