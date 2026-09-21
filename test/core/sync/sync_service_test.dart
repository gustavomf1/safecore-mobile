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
