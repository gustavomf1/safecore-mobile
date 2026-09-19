# Modo offline no mobile (registro + visualização) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deixar o app registrar NC/Desvio offline (sincronizando manualmente depois) e ler NC/Desvio já existentes offline, sem alterar nenhuma linha do caminho de criação online.

**Architecture:** Local-first com fila manual. Schema Drift v2 (rascunhos + sub-tabelas de normas/fotos + cache de referência + cache de leitura completo). Wizard ganha uma guarda de conectividade no início de `_submit()`; se offline, desvia pra uma função isolada que grava tudo local. Sincronização é sempre disparada manualmente pela tela "Sincronização" (antes "Rascunhos"); um banner global avisa quando há pendência e a conexão voltou.

**Tech Stack:** Flutter, Riverpod, Drift/SQLite, Dio, go_router, `flutter_test` + `mocktail` (padrão dos testes existentes — ver `feed_smoke_test.dart` pro estilo de `ProviderScope` com overrides).

**Spec:** `docs/superpowers/specs/2026-09-19-offline-mobile-design.md` (depende de `docs/superpowers/specs/2026-09-19-sync-idempotencia-backend-design.md`, implementada no repo `safecore-api`, plano em `safecore-api/docs/superpowers/plans/2026-09-19-sync-idempotencia-backend.md`)

## Global Constraints

- **Caminho de criação online não muda em nenhuma linha.** A única adição em `wizard_page.dart` é uma guarda de conectividade antes do código existente — decisão explícita do usuário, não renegociável durante a implementação.
- Sincronização é **sempre manual** — nada sincroniza sozinho ao reconectar. O listener em `main.dart:63-77` que hoje chama `syncPendentes()` automaticamente precisa ser removido/alterado (Task 8).
- Depois de cada mudança em tabela/DAO Drift: rodar `dart run build_runner build --delete-conflicting-outputs` antes de compilar ou testar.
- `NativeDatabase.memory()` (usado nos testes) sempre cria o schema do zero na versão atual — prova que `onCreate`/`createAll()` funciona, **não** prova que `onUpgrade` funciona num dispositivo com instalação antiga. Isso é uma verificação manual (Task 1, Step 6), não coberta por teste automatizado.
- Repositório: `/home/mag/Documents/mobile/safecore-mobile`. Rodar teste único: `flutter test test/caminho/arquivo_test.dart`.

---

### Task 1: Schema Drift v2 — tabelas, DAOs, migration

**Files:**
- Modify: `lib/core/database/app_database.dart`
- Modify: `lib/core/database/rascunhos_dao.dart`
- Modify: `lib/core/database/ocorrencias_cache_dao.dart`
- Create: `lib/core/database/rascunho_normas_dao.dart`
- Create: `lib/core/database/rascunho_fotos_dao.dart`
- Create: `lib/core/database/reference_cache_dao.dart`
- Modify: `test/core/database/app_database_test.dart`

**Interfaces:**
- Produces: `Rascunhos` (colunas: `id`, `usuarioId`, `tipo`, `titulo`, `descricao?`, `severidade?`, `latitude?`, `longitude?`, `capturedAt?`, `cidade?`, `dadosJson?`, `criadoEm`, `status` default `'pendente'`, `erroMensagem?`, `serverId?`) — sem `fotoPath` nem `sincronizado`.
- Produces: `RascunhoNormas` (`id` autoincrement, `rascunhoId` FK, `normaId`, `clausulaReferencia?`, `textoEditado` não-nulo, `status` default `'pendente'`).
- Produces: `RascunhoFotos` (`id` autoincrement, `rascunhoId` FK, `path`, `ordem`, `status` default `'pendente'`, `evidenciaServerId?`, `erroMensagem?`).
- Produces: `ReferenceCache` (`chave` PK, `dadosJson`, `atualizadoEm`).
- Produces: `OcorrenciasCache` com `nivel` (`'SUMMARY'`|`'DETAIL'`) somado à PK (`{id, nivel}`).
- Produces: `RascunhosDao.listarPendentes()`, `.watchPendentes()`, `.watchTodosPendentesOuErro()`, `.atualizarStatus(id, {status, serverId, erroMensagem})`, `.deletar(id)`, `.salvar(RascunhosCompanion)` — todas filtrando por `status != 'sincronizado'` em vez de `sincronizado == 0`.
- Produces: `RascunhoNormasDao.salvar(...)`, `.listarDoRascunho(rascunhoId)`, `.marcarVinculado(id)`, `.marcarErro(id, msg)`.
- Produces: `RascunhoFotosDao.salvar(...)`, `.listarDoRascunho(rascunhoId)`, `.marcarEnviado(id, evidenciaServerId)`, `.marcarErro(id, msg)`.
- Produces: `ReferenceCacheDao.salvar(chave, dadosJson)`, `.buscar(chave): Future<ReferenceCacheData?>`.
- Produces: `OcorrenciasCacheDao.salvar(...)` (já existente, ganha `nivel` no companion), `.buscar(id, nivel): Future<OcorrenciasCacheData?>`, `.listarPorTipoENivel(tipo, nivel, usuarioId)`, `.limparTudo()` (novo — usado no logout).

- [ ] **Step 1: Reescrever `app_database.dart` com as tabelas novas e `schemaVersion => 2`**

```dart
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
```

Note: mantém o nome de arquivo `engseg.sqlite` — não renomear, senão o
banco de instalações existentes fica órfão.

- [ ] **Step 2: Atualizar `RascunhosDao`**

```dart
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
```

- [ ] **Step 3: Criar `RascunhoNormasDao`, `RascunhoFotosDao`, `ReferenceCacheDao`**

```dart
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
```

```dart
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
```

```dart
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
```

- [ ] **Step 4: Atualizar `OcorrenciasCacheDao`**

```dart
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
```

- [ ] **Step 5: Gerar código, corrigir o teste existente e adicionar testes das tabelas novas**

Run: `dart run build_runner build --delete-conflicting-outputs`

`test/core/database/app_database_test.dart` usava `sincronizado:
const Value(0)` e `listarPendentes()`/`watchPendentes()` sem argumento —
ambos quebram com as mudanças acima. Reescrever:

```dart
// test/core/database/app_database_test.dart
import 'package:drift/drift.dart';
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
```

Run: `flutter test test/core/database/app_database_test.dart`
Expected: PASS (todos os testes acima).

- [ ] **Step 6: Verificação manual da migration (não coberta pelo teste acima)**

`NativeDatabase.memory()` sempre cria do zero — não exercita `onUpgrade`.
Verificar manualmente numa build de dispositivo/emulador que já tem o app
instalado com `engseg.sqlite` na v1: instalar a build nova por cima (não
desinstalar antes) e confirmar nos logs/comportamento que o app abre sem
crash (`MigrationStrategy.onUpgrade` rodou). Se não houver device com
instalação v1 disponível, documentar isso como pendência explícita antes
de liberar a build — não marcar como testado sem essa verificação.

- [ ] **Step 7: Commit**

```bash
git add lib/core/database/ test/core/database/app_database_test.dart
git commit -m "feat: schema Drift v2 (rascunhos com sub-tabelas + cache de referência)"
```

---

### Task 2: Corrigir leitura de rascunho (`DraftRepository`)

**Files:**
- Modify: `lib/features/ocorrencias/model/rascunho_local.dart`
- Modify: `lib/features/ocorrencias/repository/draft_repository.dart`
- Modify: `lib/features/ocorrencias/repository/draft_repository_impl.dart`
- Create: `test/features/ocorrencias/repository/draft_repository_impl_test.dart`

**Interfaces:**
- Consumes: `RascunhosDao` (Task 1) — `salvar`, `listarPendentes(usuarioId)`, `watchPendentes(usuarioId)`, `atualizarStatus`, `deletar`.
- Produces: `RascunhoLocal` com `status: String`, `cidade: String?`, sem `fotoPath` nem `sincronizado: int`. `dadosJson` decodificado de verdade na leitura.
- Produces: `DraftRepository.watchPendentes(String usuarioId)`, `.atualizarStatus(String id, {required String status, String? serverId, String? erroMensagem})` — substitui `marcarSincronizado`.

- [ ] **Step 1: Atualizar o model**

```dart
// lib/features/ocorrencias/model/rascunho_local.dart
import 'dart:convert';

class RascunhoLocal {
  final String id;
  final String usuarioId;
  final String tipo; // "NC" | "DESVIO"
  final String titulo;
  final String? descricao;
  final int? severidade;
  final double? latitude;
  final double? longitude;
  final int? capturedAt;
  final String? cidade;
  final Map<String, dynamic> dadosJson;
  final int criadoEm;
  final String status; // pendente | sincronizando | erro | sincronizado
  final String? erroMensagem;
  final String? serverId;

  const RascunhoLocal({
    required this.id,
    required this.usuarioId,
    required this.tipo,
    required this.titulo,
    this.descricao,
    this.severidade,
    this.latitude,
    this.longitude,
    this.capturedAt,
    this.cidade,
    required this.dadosJson,
    required this.criadoEm,
    this.status = 'pendente',
    this.erroMensagem,
    this.serverId,
  });

  String get dadosJsonEncoded => jsonEncode(dadosJson);
}
```

- [ ] **Step 2: Escrever o teste que falha — `salvar` seguido de `watchPendentes` devolve o `dadosJson` de volta**

```dart
// test/features/ocorrencias/repository/draft_repository_impl_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecore_mobile/core/database/app_database.dart';
import 'package:safecore_mobile/features/ocorrencias/model/rascunho_local.dart';
import 'package:safecore_mobile/features/ocorrencias/repository/draft_repository_impl.dart';

void main() {
  late AppDatabase db;
  late DraftRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DraftRepositoryImpl(dao: db.rascunhosDao);
  });

  tearDown(() async => db.close());

  test('salvar e ler de volta preserva dadosJson', () async {
    await repo.salvar(RascunhoLocal(
      id: 'r1',
      usuarioId: 'u1',
      tipo: 'NC',
      titulo: 'Vazamento',
      dadosJson: const {'estabelecimentoId': 'e1', 'titulo': 'Vazamento'},
      criadoEm: DateTime.now().millisecondsSinceEpoch,
    ));

    final pendentes = await repo.watchPendentes('u1').first;

    expect(pendentes.length, 1);
    expect(pendentes.first.dadosJson['estabelecimentoId'], 'e1');
    expect(pendentes.first.dadosJson['titulo'], 'Vazamento');
  });

  test('rascunho sem dadosJson não quebra a leitura', () async {
    await db.rascunhosDao.salvar(RascunhosCompanion.insert(
      id: 'r2', usuarioId: 'u1', tipo: 'NC', titulo: 'Sem dados',
      criadoEm: DateTime.now().millisecondsSinceEpoch,
    ));

    final pendentes = await repo.watchPendentes('u1').first;
    expect(pendentes.first.dadosJson, isEmpty);
  });
}
```

Run: `flutter test test/features/ocorrencias/repository/draft_repository_impl_test.dart`
Expected: FAIL — `DraftRepositoryImpl` ainda tem a assinatura antiga
(`salvar(RascunhoLocal)` sem `usuarioId`/`status`, `watchPendentes()` sem
argumento, `_toModel` retornando `dadosJson: const {}`).

- [ ] **Step 3: Corrigir `DraftRepository` e `DraftRepositoryImpl`**

```dart
// lib/features/ocorrencias/repository/draft_repository.dart
import '../model/rascunho_local.dart';

abstract class DraftRepository {
  Stream<List<RascunhoLocal>> watchPendentes(String usuarioId);
  Future<void> salvar(RascunhoLocal rascunho);
  Future<void> atualizarStatus(
    String id, {
    required String status,
    String? serverId,
    String? erroMensagem,
  });
  Future<void> deletar(String id);
}
```

```dart
// lib/features/ocorrencias/repository/draft_repository_impl.dart
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
```

- [ ] **Step 4: Rodar os testes e confirmar que passam**

Run: `flutter test test/features/ocorrencias/repository/draft_repository_impl_test.dart`
Expected: PASS.

- [ ] **Step 5: Rodar `flutter analyze` pra achar os call sites que quebraram**

Run: `flutter analyze`
Expected: erros em `sync_service.dart` (usa `draftRepository.marcarSincronizado`)
e possivelmente `drafts_page.dart`/`main.dart`. Esses call sites são
corrigidos nas Tasks 6-8 — não corrigir aqui, só confirmar que os erros
apontados são exatamente esses arquivos (se aparecer erro em outro lugar
inesperado, investigar antes de seguir).

- [ ] **Step 6: Commit**

```bash
git add lib/features/ocorrencias/model/rascunho_local.dart \
        lib/features/ocorrencias/repository/draft_repository.dart \
        lib/features/ocorrencias/repository/draft_repository_impl.dart \
        test/features/ocorrencias/repository/draft_repository_impl_test.dart
git commit -m "fix: DraftRepository decodifica dadosJson de volta na leitura"
```

---

### Task 3: Cache de dados de referência (localizações, normas, empresas contratadas)

**Files:**
- Create: `lib/core/network/reference_cache_helper.dart`
- Modify: `lib/features/ocorrencias/repository/support_repository_impl.dart`
- Create: `test/core/network/reference_cache_helper_test.dart`

**Interfaces:**
- Consumes: `ReferenceCacheDao` (Task 1).
- Consumes: `connectivityProvider` (corrigido na Task 5 — aqui só é lido, ainda não escrito).
- Produces: `Future<List<T>> buscarComCache<T>({required String chave, required bool online, required Future<List<T>> Function() buscarOnline, required T Function(Map<String, dynamic>) fromJson, required Map<String, dynamic> Function(T) toJson})` — usado pelas Tasks 4 e a própria Task 3.

- [ ] **Step 1: Escrever o teste que falha**

```dart
// test/core/network/reference_cache_helper_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecore_mobile/core/database/app_database.dart';
import 'package:safecore_mobile/core/network/reference_cache_helper.dart';

class _Item {
  final String id;
  final String nome;
  const _Item(this.id, this.nome);
  Map<String, dynamic> toJson() => {'id': id, 'nome': nome};
  static _Item fromJson(Map<String, dynamic> j) => _Item(j['id'] as String, j['nome'] as String);
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  test('online com sucesso busca da rede e grava no cache', () async {
    final resultado = await buscarComCache<_Item>(
      dao: db.referenceCacheDao,
      chave: 'normas',
      online: true,
      buscarOnline: () async => [const _Item('n1', 'Norma 1')],
      fromJson: _Item.fromJson,
      toJson: (i) => i.toJson(),
    );

    expect(resultado.single.nome, 'Norma 1');
    final cached = await db.referenceCacheDao.buscar('normas');
    expect(cached, isNotNull);
  });

  test('online mas buscarOnline falha cai pro cache existente', () async {
    await db.referenceCacheDao.salvar('normas', '[{"id":"n1","nome":"Cacheada"}]');

    final resultado = await buscarComCache<_Item>(
      dao: db.referenceCacheDao,
      chave: 'normas',
      online: true,
      buscarOnline: () async => throw Exception('rede caiu'),
      fromJson: _Item.fromJson,
      toJson: (i) => i.toJson(),
    );

    expect(resultado.single.nome, 'Cacheada');
  });

  test('offline lê direto do cache sem chamar buscarOnline', () async {
    await db.referenceCacheDao.salvar('normas', '[{"id":"n1","nome":"Cacheada"}]');
    var chamouOnline = false;

    final resultado = await buscarComCache<_Item>(
      dao: db.referenceCacheDao,
      chave: 'normas',
      online: false,
      buscarOnline: () async {
        chamouOnline = true;
        return [];
      },
      fromJson: _Item.fromJson,
      toJson: (i) => i.toJson(),
    );

    expect(chamouOnline, isFalse);
    expect(resultado.single.nome, 'Cacheada');
  });

  test('offline sem cache retorna lista vazia', () async {
    final resultado = await buscarComCache<_Item>(
      dao: db.referenceCacheDao,
      chave: 'chave-nunca-cacheada',
      online: false,
      buscarOnline: () async => [],
      fromJson: _Item.fromJson,
      toJson: (i) => i.toJson(),
    );

    expect(resultado, isEmpty);
  });
}
```

Run: `flutter test test/core/network/reference_cache_helper_test.dart`
Expected: FAIL — `reference_cache_helper.dart` não existe ainda.

- [ ] **Step 2: Implementar o helper**

```dart
// lib/core/network/reference_cache_helper.dart
import 'dart:convert';
import '../database/reference_cache_dao.dart';

Future<List<T>> buscarComCache<T>({
  required ReferenceCacheDao dao,
  required String chave,
  required bool online,
  required Future<List<T>> Function() buscarOnline,
  required T Function(Map<String, dynamic>) fromJson,
  required Map<String, dynamic> Function(T) toJson,
}) async {
  if (online) {
    try {
      final lista = await buscarOnline();
      await dao.salvar(chave, jsonEncode(lista.map(toJson).toList()));
      return lista;
    } catch (_) {
      // cai pro cache abaixo
    }
  }
  final cached = await dao.buscar(chave);
  if (cached == null) return [];
  return (jsonDecode(cached.dadosJson) as List)
      .map((e) => fromJson(e as Map<String, dynamic>))
      .toList();
}
```

- [ ] **Step 3: Rodar os testes e confirmar que passam**

Run: `flutter test test/core/network/reference_cache_helper_test.dart`
Expected: PASS.

- [ ] **Step 4: Ligar o helper em `support_repository_impl.dart` (localizações, normas, empresas contratadas — não usuários)**

`localizacoesProvider`, `normasProvider`, `empresasDoEstabelecimentoProvider`
passam a checar `connectivityProvider` e usar `buscarComCache`. Modelos
`Localizacao`, `Norma`, `Empresa` precisam de `toJson()` — checar se já
existe em cada (senão, adicionar espelhando o `fromJson` já existente).

```dart
// trecho relevante de lib/features/ocorrencias/repository/support_repository_impl.dart
final localizacoesProvider = FutureProvider.family<List<Localizacao>, String>(
  (ref, estabelecimentoId) async {
    final online = ref.watch(connectivityProvider).valueOrNull ?? true;
    return buscarComCache<Localizacao>(
      dao: ref.watch(appDatabaseProvider).referenceCacheDao,
      chave: 'localizacoes:$estabelecimentoId',
      online: online,
      buscarOnline: () => ref.watch(supportRepositoryProvider).listarLocalizacoes(estabelecimentoId),
      fromJson: Localizacao.fromJson,
      toJson: (l) => l.toJson(),
    );
  },
);

final normasProvider = FutureProvider<List<Norma>>((ref) async {
  final online = ref.watch(connectivityProvider).valueOrNull ?? true;
  return buscarComCache<Norma>(
    dao: ref.watch(appDatabaseProvider).referenceCacheDao,
    chave: 'normas',
    online: online,
    buscarOnline: () => ref.watch(supportRepositoryProvider).listarNormas(),
    fromJson: Norma.fromJson,
    toJson: (n) => n.toJson(),
  );
});

final empresasDoEstabelecimentoProvider =
    FutureProvider.family<List<Empresa>, String>((ref, estabelecimentoId) async {
  final online = ref.watch(connectivityProvider).valueOrNull ?? true;
  return buscarComCache<Empresa>(
    dao: ref.watch(appDatabaseProvider).referenceCacheDao,
    chave: 'empresasContratadas:$estabelecimentoId',
    online: online,
    buscarOnline: () =>
        ref.watch(supportRepositoryProvider).listarEmpresasDoEstabelecimento(estabelecimentoId),
    fromJson: Empresa.fromJson,
    toJson: (e) => e.toJson(),
  );
});
```

`usuariosProvider`/`usuariosPorEmpresaProvider`/`estabelecimentosProvider`/
`empresasMaeProvider`/`dashboardProvider` **não** mudam — responsável fica
online-only por decisão de escopo, e estabelecimento/empresa mãe já vêm do
workspace fixo da sessão.

- [ ] **Step 5: Rodar `flutter analyze` e `flutter test test/features/ocorrencias/`**

Run: `flutter analyze && flutter test test/features/ocorrencias/`
Expected: sem novos erros introduzidos por essa mudança (se `Localizacao`/
`Norma`/`Empresa` não tinham `toJson()`, adicioná-lo é parte deste step).

- [ ] **Step 6: Commit**

```bash
git add lib/core/network/reference_cache_helper.dart \
        lib/features/ocorrencias/repository/support_repository_impl.dart \
        lib/features/ocorrencias/model/localizacao.dart \
        lib/features/ocorrencias/model/norma.dart \
        lib/features/ocorrencias/model/empresa.dart \
        test/core/network/reference_cache_helper_test.dart
git commit -m "feat: cache local de localizações, normas e empresas contratadas"
```

---

### Task 4: Cache de leitura para NC/Desvio (listas + detalhe)

**Files:**
- Modify: `lib/features/ocorrencias/repository/nc_repository_impl.dart`
- Modify: `lib/features/ocorrencias/repository/desvio_repository_impl.dart`
- Modify: `lib/features/auth/provider/auth_provider.dart` (limpar cache no logout)
- Create: `test/features/ocorrencias/repository/nc_repository_impl_test.dart`

**Interfaces:**
- Consumes: `OcorrenciasCacheDao` (Task 1), `connectivityProvider`, `authProvider` (usuarioId real).
- Produces: `NcRepositoryImpl.listar()`/`.buscarPorId()` cache-first quando offline, com JSON completo (não mais campos inventados).

- [ ] **Step 1: Escrever o teste que falha — `listar` offline devolve o summary completo do cache, não valores inventados**

```dart
// test/features/ocorrencias/repository/nc_repository_impl_test.dart
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecore_mobile/core/database/app_database.dart';
import 'package:safecore_mobile/features/ocorrencias/repository/nc_repository_impl.dart';

class _FailingDio extends DioMixin implements Dio {
  _FailingDio() {
    httpClientAdapter = _ThrowingAdapter();
    options = BaseOptions();
  }
}

// mínimo pra forçar DioException — ajustar ao padrão de mock de Dio já
// usado em outros testes de repositório deste projeto, se existir um
// (checar `test/features/ocorrencias/repository/` antes de escrever este
// step — se já houver um helper de "Dio que sempre falha", reusar em vez
// de duplicar).

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  test('listar offline devolve nivelRisco e demais campos reais do cache, não inventados', () async {
    await db.ocorrenciasCacheDao.salvar(OcorrenciasCacheCompanion.insert(
      id: 'nc-1',
      tipo: 'NC',
      nivel: 'SUMMARY',
      dadosJson: '{"id":"nc-1","titulo":"Vazamento","status":"ABERTA","nivelRisco":"ALTO","estabelecimentoNome":"Obra X","dataRegistro":"2026-09-01","vencida":true}',
      usuarioId: 'u1',
      cachedEm: DateTime.now().millisecondsSinceEpoch,
    ));

    final repo = NcRepositoryImpl(dio: _FailingDio(), cacheDao: db.ocorrenciasCacheDao, usuarioId: 'u1');
    final lista = await repo.listar(estabelecimentoId: 'e1');

    expect(lista.single.nivelRisco, 'ALTO');
    expect(lista.single.vencida, isTrue);
    expect(lista.single.dataRegistro, '2026-09-01');
  });
}
```

Run: `flutter test test/features/ocorrencias/repository/nc_repository_impl_test.dart`
Expected: FAIL — `NcRepositoryImpl` hoje não recebe `usuarioId`, grava
`usuarioId: ''` e reconstrói o summary com campos fixos (`nivelRisco:
'MEDIO'`, `vencida: false`, `dataRegistro: ''`).

- [ ] **Step 2: Corrigir `NcRepositoryImpl`**

```dart
// trecho relevante de lib/features/ocorrencias/repository/nc_repository_impl.dart
final ncRepositoryProvider = Provider<NcRepository>((ref) {
  final usuarioId = ref.watch(authProvider).valueOrNull?.id ?? '';
  return NcRepositoryImpl(
    dio: ref.watch(dioProvider),
    cacheDao: ref.watch(appDatabaseProvider).ocorrenciasCacheDao,
    usuarioId: usuarioId,
  );
});

class NcRepositoryImpl implements NcRepository {
  final Dio dio;
  final OcorrenciasCacheDao? cacheDao;
  final String usuarioId;

  NcRepositoryImpl({required this.dio, required this.cacheDao, required this.usuarioId});

  @override
  Future<List<NcSummary>> listar({String? estabelecimentoId, String? status}) async {
    try {
      final response = await dio.get<List<dynamic>>(
        '/api/nao-conformidades',
        queryParameters: {
          if (estabelecimentoId != null) 'estabelecimentoId': estabelecimentoId,
          if (status != null) 'status': status,
        },
      );
      final rawList = response.data ?? [];
      final list = rawList.map((e) => NcSummary.fromJson(e as Map<String, dynamic>)).toList();
      await cacheDao?.limpar('NC');
      for (var i = 0; i < rawList.length; i++) {
        await cacheDao?.salvar(OcorrenciasCacheCompanion.insert(
          id: list[i].id,
          tipo: 'NC',
          nivel: 'SUMMARY',
          dadosJson: jsonEncode(rawList[i]),
          usuarioId: usuarioId,
          cachedEm: DateTime.now().millisecondsSinceEpoch,
        ));
      }
      return list;
    } on DioException catch (_) {
      final cached = await cacheDao?.listarPorTipoENivel('NC', 'SUMMARY', usuarioId) ?? [];
      return cached
          .map((c) => NcSummary.fromJson(jsonDecode(c.dadosJson) as Map<String, dynamic>))
          .toList();
    }
  }

  @override
  Future<NcDetail> buscarPorId(String id) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/api/nao-conformidades/$id');
      final detail = NcDetail.fromJson(response.data!);
      await cacheDao?.salvar(OcorrenciasCacheCompanion.insert(
        id: id,
        tipo: 'NC',
        nivel: 'DETAIL',
        dadosJson: jsonEncode(response.data!),
        usuarioId: usuarioId,
        cachedEm: DateTime.now().millisecondsSinceEpoch,
      ));
      return detail;
    } on DioException catch (_) {
      final cached = await cacheDao?.buscar(id, 'DETAIL');
      if (cached == null) rethrow;
      return NcDetail.fromJson(jsonDecode(cached.dadosJson) as Map<String, dynamic>);
    }
  }

  @override
  Future<NcDetail> criar(CriarNcRequest request) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/api/nao-conformidades',
      data: request.toJson(),
    );
    return NcDetail.fromJson(response.data!);
  }

  @override
  Future<NcDetail> atualizar(String id, CriarNcRequest request) async {
    final response = await dio.put<Map<String, dynamic>>(
      '/api/nao-conformidades/$id',
      data: request.toJson(),
    );
    return NcDetail.fromJson(response.data!);
  }

  @override
  Future<void> salvarRascunho(RascunhoLocal rascunho) async {
    // Handled by DraftRepository
  }
}
```

`jsonEncode`/`jsonDecode` precisam de `import 'dart:convert';` no topo do
arquivo (checar se já está importado).

Nota: `criar()`/`atualizar()` **não são tocados** além do necessário pra
compilar — são o caminho de escrita online, fora do escopo desta task.

- [ ] **Step 3: Repetir o mesmo padrão em `DesvioRepositoryImpl`**

Aplicar exatamente a mesma mudança (`usuarioId` no construtor/provider,
`nivel: 'SUMMARY'`/`'DETAIL'`, `dadosJson` completo em vez de campos
fabricados) em `lib/features/ocorrencias/repository/desvio_repository_impl.dart`
— ler o arquivo primeiro pra confirmar o formato exato do fallback atual
antes de replicar (pode divergir em detalhe do `NcRepositoryImpl`, ex: se
`listar`/`buscarPorId` já tem cache parcial ou não).

- [ ] **Step 4: Limpar `OcorrenciasCache` no logout**

```dart
// lib/features/auth/provider/auth_provider.dart, dentro de AuthNotifier
Future<void> logout() async {
  await ref.read(authRepositoryProvider).logout();
  await ref.read(appDatabaseProvider).ocorrenciasCacheDao.limparTudo();
  ref.read(workspaceProvider.notifier).state = null;
  state = const AsyncData(null);
}
```

Precisa de `import '../../../core/database/app_database.dart';` no topo
do arquivo. **`Rascunhos`/`RascunhoNormas`/`RascunhoFotos` não são
limpos** — é trabalho não sincronizado, só fica escopado por `usuarioId`
(já garantido pela Task 1/2).

- [ ] **Step 5: Rodar os testes**

Run: `flutter test test/features/ocorrencias/repository/`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/ocorrencias/repository/nc_repository_impl.dart \
        lib/features/ocorrencias/repository/desvio_repository_impl.dart \
        lib/features/auth/provider/auth_provider.dart \
        test/features/ocorrencias/repository/nc_repository_impl_test.dart
git commit -m "fix: cache de leitura offline com JSON completo e escopado por usuário"
```

---

### Task 5: Guarda offline no wizard

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/core/network/connectivity_provider.dart`
- Create: `lib/features/wizard/rascunho_offline.dart`
- Modify: `lib/features/wizard/wizard_page.dart` (só a guarda em `_submit`, ~6 linhas)
- Create: `test/core/network/connectivity_provider_test.dart`
- Create: `test/features/wizard/rascunho_offline_test.dart`

**Interfaces:**
- Consumes: `RascunhoNormasDao`, `RascunhoFotosDao`, `DraftRepository` (Tasks 1-2).
- Produces: `Future<void> salvarRascunhoOffline({required WidgetRef ref, required String usuarioId, required String tipo, required Map<String, dynamic> dadosJson, required List<File> fotos, required Map<String, ({String? clausulaReferencia, String textoEditado})> normaTrechos, double? latitude, double? longitude, int? capturedAt})`.

- [ ] **Step 1: Adicionar dependência `uuid`**

Editar `pubspec.yaml`, dentro do bloco `dependencies:` (a mudança pendente
nesse arquivo hoje é só um bump de `version:` no topo — não conflita):

```yaml
  uuid: ^4.5.1
```

Run: `flutter pub get`

- [ ] **Step 2: Escrever o teste que falha — `connectivityProvider` emite um valor inicial sem esperar mudança**

```dart
// test/core/network/connectivity_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecore_mobile/core/network/connectivity_provider.dart';

void main() {
  test('connectivityProvider emite um valor antes de qualquer mudança de rede', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // força a criação do provider e espera o primeiro evento
    final sub = container.listen(connectivityProvider, (_, __) {});
    await Future.delayed(const Duration(milliseconds: 100));

    expect(sub.read().hasValue, isTrue);
  });
}
```

Run: `flutter test test/core/network/connectivity_provider_test.dart`
Expected: FAIL (ou flaky/hasValue false) — o provider atual só emite a
partir de `onConnectivityChanged`, sem valor inicial.

- [ ] **Step 3: Corrigir `connectivity_provider.dart`**

```dart
// lib/core/network/connectivity_provider.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  final inicial = await connectivity.checkConnectivity();
  yield inicial.any((r) => r != ConnectivityResult.none);
  yield* connectivity.onConnectivityChanged.map(
    (results) => results.any((r) => r != ConnectivityResult.none),
  );
});
```

- [ ] **Step 4: Rodar o teste e confirmar que passa**

Run: `flutter test test/core/network/connectivity_provider_test.dart`
Expected: PASS. Também rodar `flutter test test/` completo nesse ponto pra
garantir que nada que dependia do comportamento antigo (`value == null`
tratado como offline em algum lugar) quebrou — se algo quebrar, investigar
antes de seguir (é comportamento novo sendo corrigido, não regressão a
reverter).

- [ ] **Step 5: Escrever o teste que falha — `salvarRascunhoOffline` grava rascunho + normas + fotos copiadas**

```dart
// test/features/wizard/rascunho_offline_test.dart
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:safecore_mobile/core/database/app_database.dart';
import 'package:safecore_mobile/features/ocorrencias/repository/draft_repository_impl.dart';
import 'package:safecore_mobile/features/wizard/rascunho_offline.dart';

class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final Directory dir;
  _FakePathProvider(this.dir);
  @override
  Future<String?> getApplicationDocumentsPath() async => dir.path;
}

void main() {
  late Directory tmpDir;
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    tmpDir = await Directory.systemTemp.createTemp('rascunho_offline_test');
    PathProviderPlatform.instance = _FakePathProvider(tmpDir);
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    await tmpDir.delete(recursive: true);
  });

  test('salva rascunho, copia fotos pro diretório persistente e grava trechos de norma', () async {
    final fotoOrigem = File('${tmpDir.path}/origem.jpg')..writeAsBytesSync([1, 2, 3]);

    await salvarRascunhoOffline(
      container: container,
      usuarioId: 'u1',
      tipo: 'NC',
      dadosJson: const {'estabelecimentoId': 'e1', 'titulo': 'Vazamento'},
      fotos: [fotoOrigem],
      normaTrechos: const {
        'norma-1': (clausulaReferencia: '4.2', textoEditado: 'texto editado'),
      },
      latitude: -23.5,
      longitude: -46.6,
      capturedAt: 1234567890,
    );

    final pendentes = await container.read(draftRepositoryProvider).watchPendentes('u1').first;
    expect(pendentes.length, 1);
    expect(pendentes.first.status, 'pendente');
    expect(pendentes.first.dadosJson['titulo'], 'Vazamento');

    final normas = await db.rascunhoNormasDao.listarDoRascunho(pendentes.first.id);
    expect(normas.single.normaId, 'norma-1');
    expect(normas.single.textoEditado, 'texto editado');

    final fotos = await db.rascunhoFotosDao.listarDoRascunho(pendentes.first.id);
    expect(fotos.single.status, 'pendente');
    expect(File(fotos.single.path).existsSync(), isTrue);
    expect(fotos.single.path, isNot(fotoOrigem.path)); // copiada, não o path original
  });
}
```

Se `path_provider_platform_interface`/`plugin_platform_interface` não
estiverem disponíveis como dev dependency transitiva do `path_provider`
já existente, adicionar `path_provider_platform_interface` em
`dev_dependencies` no `pubspec.yaml` antes deste step.

Run: `flutter test test/features/wizard/rascunho_offline_test.dart`
Expected: FAIL — `rascunho_offline.dart` não existe ainda.

- [ ] **Step 6: Implementar `salvarRascunhoOffline`**

```dart
// lib/features/wizard/rascunho_offline.dart
import 'dart:io';
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
```

Precisa de `import 'package:drift/drift.dart';` pra `Value(...)` — checar
se falta no import list.

- [ ] **Step 7: Rodar o teste e confirmar que passa**

Run: `flutter test test/features/wizard/rascunho_offline_test.dart`
Expected: PASS.

- [ ] **Step 8: Adicionar a guarda em `wizard_page.dart` — única mudança nesse arquivo**

Ler `wizard_page.dart` em torno da linha 330 (`Future<void> _submit()`
— a linha exata pode ter mudado desde o levantamento original, buscar por
`Future<void> _submit()`) e adicionar, como a primeira coisa dentro da
função, antes de qualquer chamada de rede:

```dart
Future<void> _submit() async {
  final online = ref.read(connectivityProvider).valueOrNull ?? true;
  if (!online) {
    final usuarioId = ref.read(authProvider).valueOrNull?.id ?? '';
    await salvarRascunhoOffline(
      container: ProviderScope.containerOf(context),
      usuarioId: usuarioId,
      tipo: widget.tipo == 'nc' ? 'NC' : 'DESVIO', // usar o campo real que já indica NC/Desvio nesta classe
      dadosJson: request.toJson(), // usar a variável `request` já montada nesta função, antes do branch NC/Desvio
      fotos: ref.read(captureProvider).map((x) => File(x.path)).toList(),
      normaTrechos: _normaTrechos.map(
        (normaId, t) => MapEntry(normaId, (clausulaReferencia: t.clausulaReferencia, textoEditado: t.textoEditado)),
      ),
      latitude: (widget.extra?['latitude'] as num?)?.toDouble(),
      longitude: (widget.extra?['longitude'] as num?)?.toDouble(),
      capturedAt: widget.extra?['capturedAt'] as int?,
    );
    if (mounted) context.go('/sincronizacao');
    return;
  }

  // --- tudo abaixo é o código que já existe hoje, sem alteração ---
```

Isso é um esboço de onde encaixar — **a implementação real precisa ler o
corpo atual de `_submit()` pra saber exatamente o nome da variável de
request (`request` no trecho lido durante o planejamento, pode já estar
montada em dois branches NC/Desvio separados — nesse caso a guarda
precisa ir *antes* da bifurcação, usando `dadosJson` cru montado a partir
dos mesmos campos de estado que os dois branches já usam, não da variável
`request` tipada, que só existe depois da bifurcação) e o nome exato do
campo que distingue NC de Desvio nesta tela** (no código lido durante o
planejamento havia um `if (isNc) {...} else {...}` — usar a mesma
condição). Adicionar os imports necessários
(`rascunho_offline.dart`, `connectivity_provider.dart` — já deve estar
importado se o arquivo já referenciar conectividade em outro lugar,
senão adicionar).

- [ ] **Step 9: Rodar `flutter analyze` no arquivo e testes de wizard existentes, se houver**

Run: `flutter analyze lib/features/wizard/wizard_page.dart`
Run: `flutter test test/features/wizard/ 2>/dev/null || true` (pode não
existir suíte de teste pro wizard hoje — confirmar antes de assumir falha)

Expected: sem erro de análise introduzido pela guarda nova. Testar
manualmente no emulador com modo avião ligado: preencher o wizard,
publicar, confirmar que aparece o rascunho na tela (ainda "Rascunhos"
nesse ponto — Task 7 renomeia) em vez de erro de rede.

- [ ] **Step 10: Commit**

```bash
git add pubspec.yaml pubspec.lock \
        lib/core/network/connectivity_provider.dart \
        lib/features/wizard/rascunho_offline.dart \
        lib/features/wizard/wizard_page.dart \
        test/core/network/connectivity_provider_test.dart \
        test/features/wizard/rascunho_offline_test.dart
git commit -m "feat: guarda offline no wizard salva rascunho local (fluxo online intocado)"
```

---

### Task 6: Motor de sincronização manual

**Requisito herdado da revisão final da Spec 1 (backend):** `@Valid` em
cascata em `SyncItemRequest` (já implementado no `safecore-api`) faz o
`POST /sync/batch` retornar 400 se o item enviado for inválido —
`safecore-mobile-backend` hoje não trata isso (`SyncForwardingService`
sem `@ExceptionHandler`), então vira um 500 opaco sem corpo de erro.
`sincronizarRascunho` (Step 2 abaixo) precisa tratar tanto um `DioException`
com status 400/500 vindo do `/sync/batch` quanto um item `status: "ERRO"`
dentro de uma resposta 200 — ambos os casos marcam só aquele rascunho como
`erro` (já é uma chamada por item, então não trava os outros). Ver detalhe
completo na spec, seção "Requisito herdado da revisão final da Spec 1".

**Files:**
- Modify: `lib/core/sync/sync_service.dart`
- Create: `test/core/sync/sync_service_test.dart`

**Interfaces:**
- Consumes: `DraftRepository.atualizarStatus` (Task 2), `RascunhoNormasDao`, `RascunhoFotosDao` (Task 1), `NcTrechoNormaRepositoryImpl.vincular`, `EvidenciaRepository.uploadParaNc`/`.uploadParaDesvio` (já existentes).
- Produces: `SyncService.sincronizarRascunho(RascunhoLocal rascunho): Future<void>` — chamado item a item pela tela da Task 7 (substitui `syncPendentes()` em lote, que não permite acionar item por item).

- [ ] **Step 1: Escrever o teste que falha — sincronizar um rascunho sem `serverId` cria, vincula normas e sobe fotos**

```dart
// test/core/sync/sync_service_test.dart
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safecore_mobile/core/database/app_database.dart';
import 'package:safecore_mobile/core/sync/sync_service.dart';
import 'package:safecore_mobile/features/ocorrencias/model/rascunho_local.dart';
import 'package:safecore_mobile/features/ocorrencias/repository/draft_repository_impl.dart';
import 'package:safecore_mobile/features/ocorrencias/repository/nc_trecho_norma_repository_impl.dart';
import 'package:safecore_mobile/features/ocorrencias/repository/evidencia_repository_impl.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late AppDatabase db;
  late MockDio bffDio;
  late DraftRepositoryImpl draftRepository;
  late SyncService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    bffDio = MockDio();
    draftRepository = DraftRepositoryImpl(dao: db.rascunhosDao);
    // trechoRepo/evidenciaRepo usam um Dio real desconfigurado: nos dois
    // testes abaixo eles nunca chegam a fazer a chamada de rede (teste 1
    // não tem normas/fotos pendentes; teste 2 falha antes, ao tentar ler
    // um arquivo de foto que não existe) — não precisam de mock próprio.
    final apiDio = Dio();
    service = SyncService(
      bffDio: bffDio,
      draftRepository: draftRepository,
      db: db,
      trechoRepo: NcTrechoNormaRepositoryImpl(dio: apiDio),
      evidenciaRepo: EvidenciaRepositoryImpl(dio: apiDio),
    );
  });

  tearDown(() async => db.close());

  test('rascunho sem serverId: cria via /sync, marca sincronizado quando não há normas/fotos pendentes', () async {
    await draftRepository.salvar(RascunhoLocal(
      id: 'r1', usuarioId: 'u1', tipo: 'NC', titulo: 'T',
      dadosJson: const {'estabelecimentoId': 'e1', 'titulo': 'T'},
      criadoEm: DateTime.now().millisecondsSinceEpoch,
    ));

    when(() => bffDio.post<Map<String, dynamic>>('/sync/batch', data: any(named: 'data')))
        .thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: '/sync/batch'),
              data: {
                'results': [
                  {'localId': 'r1', 'serverId': 'server-1', 'status': 'CRIADO', 'erro': null}
                ]
              },
            ));

    final rascunho = (await draftRepository.watchPendentes('u1').first).single;
    await service.sincronizarRascunho(rascunho);

    final atualizado = (await draftRepository.watchPendentes('u1').first);
    expect(atualizado, isEmpty); // sincronizado, sai da lista de pendentes
  });

  test('rascunho com foto pendente que falha no upload fica status erro, mantém serverId', () async {
    await draftRepository.salvar(RascunhoLocal(
      id: 'r2', usuarioId: 'u1', tipo: 'NC', titulo: 'T',
      dadosJson: const {'estabelecimentoId': 'e1', 'titulo': 'T'},
      criadoEm: DateTime.now().millisecondsSinceEpoch,
    ));
    await db.rascunhoFotosDao.salvar(RascunhoFotosCompanion.insert(
      rascunhoId: 'r2', path: '/caminho/inexistente.jpg', ordem: 0,
    ));

    when(() => bffDio.post<Map<String, dynamic>>('/sync/batch', data: any(named: 'data')))
        .thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: '/sync/batch'),
              data: {
                'results': [
                  {'localId': 'r2', 'serverId': 'server-2', 'status': 'CRIADO', 'erro': null}
                ]
              },
            ));

    final rascunho = (await draftRepository.watchPendentes('u1').first).single;
    await service.sincronizarRascunho(rascunho);

    final atualizado = (await draftRepository.watchPendentes('u1').first).single;
    expect(atualizado.status, 'erro');
    expect(atualizado.serverId, 'server-2'); // NC já criada, não recria no retry
  });
}
```

`vincular`/`uploadParaNc` dependem de `Dio` real (`dioProvider`) — este
teste força erro no upload de foto via path inexistente
(`MultipartFile.fromFile` lança ao não achar o arquivo), sem precisar
mockar o segundo `Dio`. Se isso não gerar a exceção esperada na prática,
ajustar o teste pra mockar `EvidenciaRepository` via injeção de
dependência em vez de deixar `SyncService` instanciar seus próprios
repositórios internamente — nesse caso, `SyncService` recebe
`EvidenciaRepository`/`NcTrechoNormaRepositoryImpl` no construtor
(seguindo o mesmo padrão de injeção que `bffDio`/`draftRepository` já
usam), e o teste passa fakes.

Run: `flutter test test/core/sync/sync_service_test.dart`
Expected: FAIL — `sincronizarRascunho` não existe ainda.

- [ ] **Step 2: Implementar `SyncService.sincronizarRascunho`**

```dart
// lib/core/sync/sync_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';
import '../database/app_database.dart';
import '../../features/ocorrencias/repository/draft_repository.dart';
import '../../features/ocorrencias/repository/draft_repository_impl.dart';
import '../../features/ocorrencias/repository/nc_trecho_norma_repository_impl.dart';
import '../../features/ocorrencias/repository/evidencia_repository_impl.dart';
import '../../features/ocorrencias/model/evidencia_metadata.dart';
import '../../features/ocorrencias/model/rascunho_local.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    bffDio: ref.watch(bffDioProvider),
    draftRepository: ref.watch(draftRepositoryProvider),
    db: ref.watch(appDatabaseProvider),
    trechoRepo: ref.watch(ncTrechoNormaRepositoryProvider),
    evidenciaRepo: ref.watch(evidenciaRepositoryProvider),
  );
});

class SyncService {
  final Dio bffDio;
  final DraftRepository draftRepository;
  final AppDatabase db;
  final NcTrechoNormaRepositoryImpl trechoRepo;
  final EvidenciaRepositoryImpl evidenciaRepo;

  SyncService({
    required this.bffDio,
    required this.draftRepository,
    required this.db,
    required this.trechoRepo,
    required this.evidenciaRepo,
  });

  Future<void> sincronizarRascunho(RascunhoLocal rascunho) async {
    await draftRepository.atualizarStatus(rascunho.id, status: 'sincronizando');

    var serverId = rascunho.serverId;
    if (serverId == null) {
      final data = <String, dynamic>{'localId': rascunho.id, 'tipo': rascunho.tipo};
      if (rascunho.tipo == 'NC') {
        data['nc'] = rascunho.dadosJson;
      } else {
        data['desvio'] = rascunho.dadosJson;
      }

      try {
        final response = await bffDio.post<Map<String, dynamic>>(
          '/sync/batch',
          data: {'items': [data]},
        );
        final resultado = (response.data?['results'] as List).first as Map<String, dynamic>;
        if (resultado['status'] != 'CRIADO' || resultado['serverId'] == null) {
          await draftRepository.atualizarStatus(rascunho.id,
              status: 'erro', erroMensagem: resultado['erro'] as String? ?? 'Falha ao criar');
          return;
        }
        serverId = resultado['serverId'] as String;
        // status continua 'sincronizando' — só grava o serverId aqui pra
        // não perder essa informação se o app fechar no meio dos passos
        // seguintes (normas/fotos); o status final é decidido no fim.
        await draftRepository.atualizarStatus(rascunho.id, status: 'sincronizando', serverId: serverId);
      } catch (e) {
        await draftRepository.atualizarStatus(rascunho.id, status: 'erro', erroMensagem: e.toString());
        return;
      }
    }

    var tudoOk = true;
    final normas = await db.rascunhoNormasDao.listarDoRascunho(rascunho.id);
    for (final norma in normas.where((n) => n.status == 'pendente')) {
      if (rascunho.tipo != 'NC') continue;
      try {
        await trechoRepo.vincular(
          serverId,
          normaId: norma.normaId,
          clausulaReferencia: norma.clausulaReferencia,
          textoEditado: norma.textoEditado,
        );
        await db.rascunhoNormasDao.marcarVinculado(norma.id);
      } catch (_) {
        await db.rascunhoNormasDao.marcarErro(norma.id);
        tudoOk = false;
      }
    }

    final fotos = await db.rascunhoFotosDao.listarDoRascunho(rascunho.id);
    for (final foto in fotos.where((f) => f.status == 'pendente')) {
      try {
        final meta = EvidenciaMetadata(
          latitude: rascunho.latitude ?? 0,
          longitude: rascunho.longitude ?? 0,
          capturedAt: rascunho.capturedAt ?? DateTime.now().millisecondsSinceEpoch,
          cidade: rascunho.cidade,
        );
        final response = rascunho.tipo == 'NC'
            ? await evidenciaRepo.uploadParaNc(serverId, File(foto.path), meta)
            : await evidenciaRepo.uploadParaDesvio(serverId, File(foto.path), meta);
        await db.rascunhoFotosDao.marcarEnviado(foto.id, response.id);
      } catch (e) {
        await db.rascunhoFotosDao.marcarErro(foto.id, e.toString());
        tudoOk = false;
      }
    }

    if (tudoOk) {
      await draftRepository.atualizarStatus(rascunho.id, status: 'sincronizado', serverId: serverId);
    } else {
      await draftRepository.atualizarStatus(rascunho.id,
          status: 'erro', serverId: serverId, erroMensagem: 'Alguns itens não sincronizaram — toque para tentar de novo');
    }
  }
}
```

Resolução de `cidade` via `geocoding` fica **fora desta task** — o
`meta.cidade` acima usa `rascunho.cidade` (null se não resolvido na
captura), aceitável pelo backend (campo opcional no multipart). Resolver
`cidade` em segundo plano é uma melhoria futura, não bloqueia o sync.

- [ ] **Step 3: Rodar os testes e ajustar até passar**

Run: `flutter test test/core/sync/sync_service_test.dart`
Expected: PASS. Se o segundo teste não gerar o erro esperado com path
inexistente, aplicar o ajuste de injeção de dependência descrito no
Step 1.

- [ ] **Step 4: Commit**

```bash
git add lib/core/sync/sync_service.dart test/core/sync/sync_service_test.dart
git commit -m "feat: SyncService sincroniza rascunho completo (NC/Desvio + normas + fotos)"
```

---

### Task 7: Tela "Sincronização" (era "Rascunhos")

**Files:**
- Create: `lib/features/sync/sincronizacao_page.dart`
- Delete: `lib/features/drafts/drafts_page.dart`
- Modify: `lib/core/router/app_router.dart`
- Modify: `lib/features/profile/profile_page.dart`
- Create: `test/features/sync/sincronizacao_page_test.dart`

**Interfaces:**
- Consumes: `draftsProvider(usuarioId)` (Task 2), `SyncService.sincronizarRascunho` (Task 6), `DraftRepository.deletar`.

- [ ] **Step 1: Escrever o teste que falha — lista rascunhos pendentes e permite excluir**

```dart
// test/features/sync/sincronizacao_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecore_mobile/features/auth/model/login_response.dart';
import 'package:safecore_mobile/features/auth/provider/auth_provider.dart';
import 'package:safecore_mobile/features/ocorrencias/model/rascunho_local.dart';
import 'package:safecore_mobile/features/ocorrencias/repository/draft_repository_impl.dart';
import 'package:safecore_mobile/features/sync/sincronizacao_page.dart';
import 'package:safecore_mobile/shared/theme/tokens.dart';

class MockAuthNotifier extends AsyncNotifier<LoginResponse?> with Mock implements AuthNotifier {
  @override
  Future<LoginResponse?> build() async => const LoginResponse(
        id: 'u1', token: 'tok', nome: 'T', email: 't@t.com', perfil: 'ENGENHEIRO', isAdmin: false,
      );
}

Widget _wrap(List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: MaterialApp(theme: safeCoreThemeDark(), home: const SincronizacaoPage()),
    );

void main() {
  testWidgets('mostra rascunhos pendentes com status', (tester) async {
    await tester.pumpWidget(_wrap([
      authProvider.overrideWith(MockAuthNotifier.new),
      draftsProvider.overrideWith((ref, usuarioId) async* {
        yield [
          RascunhoLocal(
            id: 'r1', usuarioId: 'u1', tipo: 'NC', titulo: 'Vazamento',
            dadosJson: const {}, criadoEm: DateTime.now().millisecondsSinceEpoch,
            status: 'pendente',
          ),
        ];
      }),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Vazamento'), findsOneWidget);
    expect(find.text('Pendente'), findsOneWidget);
  });

  testWidgets('sem rascunhos pendentes mostra estado vazio', (tester) async {
    await tester.pumpWidget(_wrap([
      authProvider.overrideWith(MockAuthNotifier.new),
      draftsProvider.overrideWith((ref, usuarioId) async* {
        yield <RascunhoLocal>[];
      }),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Vazamento'), findsNothing);
  });
}
```

Run: `flutter test test/features/sync/sincronizacao_page_test.dart`
Expected: FAIL — `sincronizacao_page.dart` não existe.

- [ ] **Step 2: Criar `SincronizacaoPage`, adaptando `_DraftCard` de `drafts_page.dart`**

Ler `lib/features/drafts/drafts_page.dart` inteiro antes de escrever (já
lido durante o planejamento — reaproveitar a estrutura visual/tokens,
trocando `sincronizado`/status hardcoded por `RascunhoLocal.status`
(`pendente`/`sincronizando`/`erro`/`sincronizado`) e adicionando as ações
por item:

```dart
// lib/features/sync/sincronizacao_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ocorrencias/model/rascunho_local.dart';
import '../ocorrencias/repository/draft_repository_impl.dart';
import '../auth/provider/auth_provider.dart';
import '../../core/network/connectivity_provider.dart';
import '../../core/sync/sync_service.dart';
import '../../shared/theme/tokens.dart';
import '../../shared/widgets/prototype_ui.dart';
import '../../shared/widgets/confirm_action_modal.dart'; // ajustar import ao nome real do widget já usado em outras 6 telas — confirmar em uma delas antes de usar

class SincronizacaoPage extends ConsumerWidget {
  const SincronizacaoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final usuarioId = ref.watch(authProvider).valueOrNull?.id ?? '';
    final draftsAsync = ref.watch(draftsProvider(usuarioId));
    final online = ref.watch(connectivityProvider).valueOrNull ?? false;

    return Scaffold(
      backgroundColor: c.bgBase,
      body: SafeArea(
        bottom: false,
        child: draftsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erro: $e', style: TextStyle(color: c.statusRedFg))),
          data: (drafts) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 104),
            children: [
              Text('Sincronização', style: SafeCoreType.headline.copyWith(color: c.fg0)),
              const SizedBox(height: 3),
              Text('${drafts.length} pendentes de sincronização', style: SafeCoreType.body.copyWith(color: c.fg2)),
              const SizedBox(height: 14),
              if (drafts.isNotEmpty)
                ProtoButton(
                  label: 'Sincronizar tudo',
                  onTap: online
                      ? () async {
                          for (final d in drafts) {
                            await ref.read(syncServiceProvider).sincronizarRascunho(d);
                          }
                        }
                      : null,
                ),
              const SizedBox(height: 12),
              for (final draft in drafts)
                _SincronizacaoCard(
                  draft: draft,
                  online: online,
                  onSincronizar: () => ref.read(syncServiceProvider).sincronizarRascunho(draft),
                  onExcluir: () => ref.read(draftRepositoryProvider).deletar(draft.id),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SincronizacaoCard extends StatelessWidget {
  final RascunhoLocal draft;
  final bool online;
  final VoidCallback onSincronizar;
  final VoidCallback onExcluir;

  const _SincronizacaoCard({
    required this.draft,
    required this.online,
    required this.onSincronizar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isNc = draft.tipo == 'NC';
    final statusLabel = switch (draft.status) {
      'sincronizando' => 'Sincronizando',
      'erro' => 'Erro',
      _ => 'Pendente',
    };
    final color = switch (draft.status) {
      'erro' => c.statusRedFg,
      'sincronizando' => c.statusYellowFg,
      _ => c.statusYellowFg,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ProtoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(color: color.withValues(alpha: .16), borderRadius: BorderRadius.circular(12)),
                  child: Icon(isNc ? Icons.shield_outlined : Icons.warning_amber_rounded, color: color, size: 23),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(spacing: 6, children: [
                        ProtoPill(label: draft.tipo, bg: isNc ? c.statusRedBg : c.statusYellowBg, fg: isNc ? c.statusRedFg : c.statusYellowFg),
                        ProtoPill(label: statusLabel, bg: color.withValues(alpha: .16), fg: color),
                      ]),
                      const SizedBox(height: 6),
                      Text(draft.titulo, maxLines: 2, overflow: TextOverflow.ellipsis, style: SafeCoreType.bodyStrong.copyWith(color: c.fg0)),
                      if (draft.status == 'erro' && draft.erroMensagem != null) ...[
                        const SizedBox(height: 4),
                        Text(draft.erroMensagem!, maxLines: 2, overflow: TextOverflow.ellipsis, style: SafeCoreType.micro.copyWith(color: c.statusRedFg)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ProtoButton(label: 'Sincronizar', onTap: online ? onSincronizar : null),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ProtoButton(
                    label: 'Excluir',
                    onTap: () => showConfirmActionModal(
                      context,
                      title: 'Excluir rascunho?',
                      message: 'Os dados preenchidos offline serão perdidos.',
                      onConfirm: onExcluir,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

O nome exato do helper de confirmação (`showConfirmActionModal`) e a
assinatura de `ProtoButton`/`ProtoPill`/`ProtoCard` precisam ser
conferidos em `prototype_ui.dart` e num dos 6 usos existentes de
`ConfirmActionModal` (memória do projeto cita esse padrão) antes de
finalizar este step — ajustar chamada ao nome/assinatura real.

- [ ] **Step 3: Apagar `lib/features/drafts/drafts_page.dart` e atualizar rota + Perfil**

```dart
// lib/core/router/app_router.dart — trocar
GoRoute(path: '/drafts', builder: (_, __) => const DraftsPage()),
// por
GoRoute(path: '/sincronizacao', builder: (_, __) => const SincronizacaoPage()),
```

Atualizar o import correspondente no topo do arquivo (trocar import de
`drafts_page.dart` por `sincronizacao_page.dart`).

```dart
// lib/features/profile/profile_page.dart:111 — trocar
_ProfileRow(icon: Icons.storage_rounded, label: 'Rascunhos locais', value: '', onTap: () => context.go('/drafts')),
// por
_ProfileRow(icon: Icons.cloud_sync_rounded, label: 'Sincronização', value: '', onTap: () => context.go('/sincronizacao')),
```

Apagar o diretório `lib/features/drafts/` inteiro depois de confirmar que
nada mais referencia `DraftsPage`/`/drafts`:

Run: `grep -rn "DraftsPage\|'/drafts'" lib/`
Expected: nenhuma ocorrência restante fora do que já foi trocado.

- [ ] **Step 4: Rodar os testes**

Run: `flutter test test/features/sync/sincronizacao_page_test.dart`
Run: `flutter analyze`
Expected: PASS / sem erros.

- [ ] **Step 5: Commit**

```bash
git add lib/features/sync/sincronizacao_page.dart \
        lib/core/router/app_router.dart \
        lib/features/profile/profile_page.dart \
        test/features/sync/sincronizacao_page_test.dart
git rm -r lib/features/drafts/
git commit -m "feat: tela Sincronização substitui Rascunhos (ações manuais por item)"
```

---

### Task 8: Banner global de pendência + remover auto-sync

**Files:**
- Create: `lib/shared/widgets/pending_sync_banner.dart`
- Modify: `lib/main.dart`
- Create: `test/shared/widgets/pending_sync_banner_test.dart`

**Interfaces:**
- Consumes: `connectivityProvider` (Task 5), `draftsProvider(usuarioId)` (Task 2).

- [ ] **Step 1: Escrever o teste que falha — banner aparece só quando online e há pendência**

```dart
// test/shared/widgets/pending_sync_banner_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:safecore_mobile/features/auth/model/login_response.dart';
import 'package:safecore_mobile/features/auth/provider/auth_provider.dart';
import 'package:safecore_mobile/features/ocorrencias/model/rascunho_local.dart';
import 'package:safecore_mobile/features/ocorrencias/repository/draft_repository_impl.dart';
import 'package:safecore_mobile/core/network/connectivity_provider.dart';
import 'package:safecore_mobile/shared/widgets/pending_sync_banner.dart';
import 'package:safecore_mobile/shared/theme/tokens.dart';

class MockAuthNotifier extends AsyncNotifier<LoginResponse?> with Mock implements AuthNotifier {
  @override
  Future<LoginResponse?> build() async => const LoginResponse(
        id: 'u1', token: 'tok', nome: 'T', email: 't@t.com', perfil: 'ENGENHEIRO', isAdmin: false,
      );
}

final _router = GoRouter(routes: [
  GoRoute(path: '/', builder: (_, __) => const Scaffold(body: PendingSyncBanner())),
  GoRoute(path: '/sincronizacao', builder: (_, __) => const SizedBox()),
]);

Widget _wrap(List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(theme: safeCoreThemeDark(), routerConfig: _router),
    );

RascunhoLocal _rascunho(String id) => RascunhoLocal(
      id: id, usuarioId: 'u1', tipo: 'NC', titulo: 'T',
      dadosJson: const {}, criadoEm: DateTime.now().millisecondsSinceEpoch,
    );

void main() {
  testWidgets('mostra aviso quando online e há pendência', (tester) async {
    await tester.pumpWidget(_wrap([
      authProvider.overrideWith(MockAuthNotifier.new),
      connectivityProvider.overrideWith((ref) => Stream.value(true)),
      draftsProvider.overrideWith((ref, usuarioId) async* { yield [_rascunho('r1')]; }),
    ]));
    await tester.pumpAndSettle();

    expect(find.textContaining('1 ite'), findsOneWidget);
  });

  testWidgets('não mostra nada quando offline mesmo com pendência', (tester) async {
    await tester.pumpWidget(_wrap([
      authProvider.overrideWith(MockAuthNotifier.new),
      connectivityProvider.overrideWith((ref) => Stream.value(false)),
      draftsProvider.overrideWith((ref, usuarioId) async* { yield [_rascunho('r1')]; }),
    ]));
    await tester.pumpAndSettle();

    expect(find.textContaining('ite'), findsNothing);
  });

  testWidgets('não mostra nada quando online sem pendência', (tester) async {
    await tester.pumpWidget(_wrap([
      authProvider.overrideWith(MockAuthNotifier.new),
      connectivityProvider.overrideWith((ref) => Stream.value(true)),
      draftsProvider.overrideWith((ref, usuarioId) async* { yield <RascunhoLocal>[]; }),
    ]));
    await tester.pumpAndSettle();

    expect(find.textContaining('ite'), findsNothing);
  });
}
```

Run: `flutter test test/shared/widgets/pending_sync_banner_test.dart`
Expected: FAIL — widget não existe.

- [ ] **Step 2: Implementar `PendingSyncBanner`**

```dart
// lib/shared/widgets/pending_sync_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/connectivity_provider.dart';
import '../../features/auth/provider/auth_provider.dart';
import '../../features/ocorrencias/repository/draft_repository_impl.dart';
import '../theme/tokens.dart';

class PendingSyncBanner extends ConsumerWidget {
  const PendingSyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(connectivityProvider).valueOrNull ?? false;
    final usuarioId = ref.watch(authProvider).valueOrNull?.id;
    if (!online || usuarioId == null) return const SizedBox.shrink();

    final draftsAsync = ref.watch(draftsProvider(usuarioId));
    final count = draftsAsync.valueOrNull?.length ?? 0;
    if (count == 0) return const SizedBox.shrink();

    final c = context.c;
    return Material(
      color: c.statusYellowBg,
      child: InkWell(
        onTap: () => context.go('/sincronizacao'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.cloud_upload_outlined, color: c.statusYellowFg, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  count == 1
                      ? 'Você tem 1 item para sincronizar'
                      : 'Você tem $count itens para sincronizar',
                  style: SafeCoreType.body.copyWith(color: c.statusYellowFg),
                ),
              ),
              Text('Ver', style: SafeCoreType.bodyStrong.copyWith(color: c.statusYellowFg)),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Montar o banner no shell principal e remover a tela de workspace da sua árvore**

Checar em `app_router.dart` qual é o shell/route que envolve as abas
inferiores (NCs/Desvios/Avisos/Perfil — provavelmente um `ShellRoute` ou
`StatefulShellRoute`) e adicionar `const PendingSyncBanner()` no topo do
`body`/acima do `child` desse shell, **fora** da rota de seleção de
workspace (que é uma rota separada, fora do shell — confirmar isso lendo
a árvore de rotas antes de decidir onde encaixar).

- [ ] **Step 4: Remover o auto-sync de `main.dart`, manter só a atualização de estado pro banner**

```dart
// lib/main.dart
class _AppConnectivityListener extends ConsumerWidget {
  final Widget child;
  const _AppConnectivityListener({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provider já observado pelo PendingSyncBanner e pela guarda do
    // wizard — nada a fazer aqui além de manter o listener vivo se
    // algum outro efeito colateral global for necessário no futuro.
    // O antigo listener chamava syncServiceProvider.syncPendentes()
    // automaticamente ao reconectar — removido: sincronização é sempre
    // manual (ver Sincronização, Task 6/7).
    return child;
  }
}
```

Se `_AppConnectivityListener`/`SyncStatus`/`syncStatusProvider` ficarem
sem nenhum outro uso depois dessa remoção, apagar
`lib/core/sync/sync_status.dart` e simplificar `main.dart` removendo a
classe `_AppConnectivityListener` inteira (usar `child` direto no
`SafeCoreApp.build`) — checar com `grep -rn "syncStatusProvider\|SyncStatus" lib/`
antes de decidir.

- [ ] **Step 5: Rodar os testes e a suíte completa**

Run: `flutter test test/shared/widgets/pending_sync_banner_test.dart`
Run: `flutter test`
Run: `flutter analyze`
Expected: PASS em tudo, sem regressão nos testes das Tasks 1-7.

- [ ] **Step 6: Teste manual fim a fim**

Emulador em modo avião: preencher wizard → publicar → ver rascunho em
Sincronização com status Pendente. Desligar modo avião → banner aparece
em qualquer tela (exceto seleção de workspace) → tocar Ver → tela de
Sincronização → tocar Sincronizar no item → status muda pra
Sincronizando → Sincronizado (ou Erro, com mensagem, se algo no ambiente
de teste não tiver rede real pro backend).

- [ ] **Step 7: Commit**

```bash
git add lib/shared/widgets/pending_sync_banner.dart \
        lib/main.dart \
        lib/core/router/app_router.dart \
        test/shared/widgets/pending_sync_banner_test.dart
git commit -m "feat: banner global de sincronização pendente, remove auto-sync ao reconectar"
```
