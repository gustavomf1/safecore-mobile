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
