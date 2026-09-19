// lib/core/database/rascunho_fotos_dao.dart
import 'package:drift/drift.dart';
import 'app_database.dart';

part 'rascunho_fotos_dao.g.dart';

@DriftAccessor(tables: [RascunhoFotos])
class RascunhoFotosDao extends DatabaseAccessor<AppDatabase>
    with _$RascunhoFotosDaoMixin {
  RascunhoFotosDao(super.db);

  Future<void> salvar(RascunhoFotosCompanion companion) =>
      into(rascunhoFotos).insert(companion);

  Future<List<RascunhoFoto>> listarDoRascunho(String rascunhoId) =>
      (select(rascunhoFotos)..where((t) => t.rascunhoId.equals(rascunhoId))).get();

  Future<void> marcarEnviado(int id, String evidenciaServerId) =>
      (update(rascunhoFotos)..where((t) => t.id.equals(id))).write(
        RascunhoFotosCompanion(
          status: const Value('enviado'),
          evidenciaServerId: Value(evidenciaServerId),
        ),
      );

  Future<void> marcarErro(int id, String mensagem) =>
      (update(rascunhoFotos)..where((t) => t.id.equals(id))).write(
        RascunhoFotosCompanion(status: const Value('erro'), erroMensagem: Value(mensagem)),
      );
}
