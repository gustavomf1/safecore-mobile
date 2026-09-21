import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../ocorrencias/model/rascunho_local.dart';
import '../ocorrencias/repository/draft_repository_impl.dart';

const _uuid = Uuid();

Future<void> salvarRascunhoOffline({
  required ProviderContainer container,
  required String usuarioId,
  required String tipo, // 'NC' | 'DESVIO'
  required Map<String, dynamic> dadosJson,
  required List<File> fotos,
  required Map<String, ({String? clausulaReferencia, String textoEditado})> normaTrechos,
  double? latitude,
  double? longitude,
  int? capturedAt,
}) async {
  final rascunhoId = _uuid.v4();
  final titulo = dadosJson['titulo'] as String? ?? '';

  await container.read(draftRepositoryProvider).salvar(RascunhoLocal(
        id: rascunhoId,
        usuarioId: usuarioId,
        tipo: tipo,
        titulo: titulo,
        latitude: latitude,
        longitude: longitude,
        capturedAt: capturedAt,
        dadosJson: dadosJson,
        criadoEm: DateTime.now().millisecondsSinceEpoch,
      ));

  final db = container.read(appDatabaseProvider);

  for (final entry in normaTrechos.entries) {
    await db.rascunhoNormasDao.salvar(RascunhoNormasCompanion.insert(
      rascunhoId: rascunhoId,
      normaId: entry.key,
      clausulaReferencia: Value(entry.value.clausulaReferencia),
      textoEditado: entry.value.textoEditado,
    ));
  }

  final docsDir = await getApplicationDocumentsDirectory();
  final rascunhoDir = Directory(p.join(docsDir.path, 'rascunhos', rascunhoId));
  await rascunhoDir.create(recursive: true);

  for (var i = 0; i < fotos.length; i++) {
    final destino = File(p.join(rascunhoDir.path, 'foto_$i.jpg'));
    await fotos[i].copy(destino.path);
    await db.rascunhoFotosDao.salvar(RascunhoFotosCompanion.insert(
      rascunhoId: rascunhoId,
      path: destino.path,
      ordem: i,
    ));
  }
}
