// lib/core/database/app_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'rascunhos_dao.dart';
import 'ocorrencias_cache_dao.dart';
import 'rascunho_normas_dao.dart';
import 'rascunho_fotos_dao.dart';
import 'reference_cache_dao.dart';

part 'app_database.g.dart';

class Rascunhos extends Table {
  TextColumn get id => text()();
  TextColumn get usuarioId => text()();
  TextColumn get tipo => text()();
  TextColumn get titulo => text()();
  TextColumn get descricao => text().nullable()();
  IntColumn get severidade => integer().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  IntColumn get capturedAt => integer().nullable()();
  TextColumn get cidade => text().nullable()();
  TextColumn get dadosJson => text().nullable()();
  IntColumn get criadoEm => integer()();
  TextColumn get status => text().withDefault(const Constant('pendente'))();
  TextColumn get erroMensagem => text().nullable()();
  TextColumn get serverId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class RascunhoNormas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rascunhoId => text().references(Rascunhos, #id)();
  TextColumn get normaId => text()();
  TextColumn get clausulaReferencia => text().nullable()();
  TextColumn get textoEditado => text()();
  TextColumn get status => text().withDefault(const Constant('pendente'))();
}

class RascunhoFotos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rascunhoId => text().references(Rascunhos, #id)();
  TextColumn get path => text()();
  IntColumn get ordem => integer()();
  TextColumn get status => text().withDefault(const Constant('pendente'))();
  TextColumn get evidenciaServerId => text().nullable()();
  TextColumn get erroMensagem => text().nullable()();
}

class ReferenceCache extends Table {
  TextColumn get chave => text()();
  TextColumn get dadosJson => text()();
  IntColumn get atualizadoEm => integer()();

  @override
  Set<Column> get primaryKey => {chave};
}

class OcorrenciasCache extends Table {
  TextColumn get id => text()();
  TextColumn get tipo => text()();
  TextColumn get nivel => text()(); // 'SUMMARY' | 'DETAIL'
  TextColumn get dadosJson => text()();
  TextColumn get usuarioId => text()();
  IntColumn get cachedEm => integer()();

  @override
  Set<Column> get primaryKey => {id, nivel};
}

@DriftDatabase(
  tables: [Rascunhos, RascunhoNormas, RascunhoFotos, ReferenceCache, OcorrenciasCache],
  daos: [RascunhosDao, OcorrenciasCacheDao, RascunhoNormasDao, RascunhoFotosDao, ReferenceCacheDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v1 nunca teve gravação real (nada no app escrevia nessas
            // tabelas) — recriar em vez de ALTER é seguro e mais simples
            // que migrar colunas removidas (sincronizado, fotoPath) e a
            // PK composta nova de ocorrencias_cache.
            await m.deleteTable('rascunhos');
            await m.deleteTable('ocorrencias_cache');
            await m.createTable(rascunhos);
            await m.createTable(ocorrenciasCache);
            await m.createTable(rascunhoNormas);
            await m.createTable(rascunhoFotos);
            await m.createTable(referenceCache);
          }
        },
      );
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase(_openConnection());
});

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'engseg.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
