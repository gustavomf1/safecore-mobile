import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safecore_mobile/core/database/app_database.dart';
import 'package:safecore_mobile/features/ocorrencias/repository/nc_repository_impl.dart';

// Reusa o padrão de mock de Dio já usado em
// test/features/ocorrencias/nc_repository_test.dart e
// test/features/ocorrencias/repository/ocorrencias_repository_impl_test.dart
// em vez de criar um HttpClientAdapter customizado.
class MockDio extends Mock implements Dio {}

void main() {
  late AppDatabase db;
  late MockDio dio;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dio = MockDio();
    when(() => dio.get<List<dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenThrow(DioException(requestOptions: RequestOptions(path: '')));
  });

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

    final repo = NcRepositoryImpl(dio: dio, cacheDao: db.ocorrenciasCacheDao, usuarioId: 'u1');
    final lista = await repo.listar(estabelecimentoId: 'e1');

    expect(lista.single.nivelRisco, 'ALTO');
    expect(lista.single.vencida, isTrue);
    expect(lista.single.dataRegistro, '2026-09-01');
  });

  test('listar offline não devolve cache de outro usuário', () async {
    await db.ocorrenciasCacheDao.salvar(OcorrenciasCacheCompanion.insert(
      id: 'nc-2',
      tipo: 'NC',
      nivel: 'SUMMARY',
      dadosJson: '{"id":"nc-2","titulo":"Outro","status":"ABERTA","nivelRisco":"ALTO","estabelecimentoNome":"Obra Y","dataRegistro":"2026-09-02","vencida":false}',
      usuarioId: 'outro-usuario',
      cachedEm: DateTime.now().millisecondsSinceEpoch,
    ));

    final repo = NcRepositoryImpl(dio: dio, cacheDao: db.ocorrenciasCacheDao, usuarioId: 'u1');
    final lista = await repo.listar(estabelecimentoId: 'e1');

    expect(lista, isEmpty);
  });

  test('buscarPorId offline devolve o detalhe completo do cache', () async {
    await db.ocorrenciasCacheDao.salvar(OcorrenciasCacheCompanion.insert(
      id: 'nc-1',
      tipo: 'NC',
      nivel: 'DETAIL',
      dadosJson: '{"id":"nc-1","titulo":"Vazamento","status":"ABERTA"}',
      usuarioId: 'u1',
      cachedEm: DateTime.now().millisecondsSinceEpoch,
    ));
    when(() => dio.get<Map<String, dynamic>>(any()))
        .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

    final repo = NcRepositoryImpl(dio: dio, cacheDao: db.ocorrenciasCacheDao, usuarioId: 'u1');
    final detail = await repo.buscarPorId('nc-1');

    expect(detail.id, 'nc-1');
    expect(detail.titulo, 'Vazamento');
  });
}
