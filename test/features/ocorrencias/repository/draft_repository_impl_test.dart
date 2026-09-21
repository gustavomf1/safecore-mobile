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
