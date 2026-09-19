// lib/core/database/ocorrencias_cache_dao.dart
import 'package:drift/drift.dart';
import 'app_database.dart';

part 'ocorrencias_cache_dao.g.dart';

@DriftAccessor(tables: [OcorrenciasCache])
class OcorrenciasCacheDao extends DatabaseAccessor<AppDatabase>
    with _$OcorrenciasCacheDaoMixin {
  OcorrenciasCacheDao(super.db);

  Future<void> salvar(OcorrenciasCacheCompanion companion) =>
      into(ocorrenciasCache).insertOnConflictUpdate(companion);

  Future<OcorrenciasCacheData?> buscar(String id, String nivel) =>
      (select(ocorrenciasCache)
            ..where((t) => t.id.equals(id) & t.nivel.equals(nivel)))
          .getSingleOrNull();

  Future<List<OcorrenciasCacheData>> listarPorTipoENivel(
    String tipo,
    String nivel,
    String usuarioId,
  ) =>
      (select(ocorrenciasCache)
            ..where((t) =>
                t.tipo.equals(tipo) & t.nivel.equals(nivel) & t.usuarioId.equals(usuarioId)))
          .get();

  Future<void> limpar(String tipo) =>
      (delete(ocorrenciasCache)..where((t) => t.tipo.equals(tipo))).go();

  Future<void> limparTudo() => delete(ocorrenciasCache).go();
}
