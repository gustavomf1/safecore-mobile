import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safecore_mobile/core/database/app_database.dart';
import 'package:safecore_mobile/features/auth/model/login_response.dart';
import 'package:safecore_mobile/features/auth/provider/auth_provider.dart';
import 'package:safecore_mobile/features/ocorrencias/repository/ocorrencias_repository_impl.dart';
import 'package:safecore_mobile/core/network/dio_client.dart';

class MockDio extends Mock implements Dio {}

class MockAuthNotifier extends AsyncNotifier<LoginResponse?> with Mock implements AuthNotifier {
  @override
  Future<LoginResponse?> build() async => const LoginResponse(
        id: 'u1', token: 'tok', nome: 'T', email: 't@t.com', perfil: 'ENGENHEIRO', isAdmin: false,
      );
}

void main() {
  late MockDio mockDio;
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    mockDio = MockDio();
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(mockDio),
        appDatabaseProvider.overrideWithValue(db),
        authProvider.overrideWith(MockAuthNotifier.new),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  Future<void> aguardarSessao() => container.read(authProvider.future);

  final fakeResponse = [
    {
      'tipo': 'NAO_CONFORMIDADE',
      'id': 'nc-1',
      'titulo': 'NC A',
      'status': 'ABERTA',
      'estabelecimentoNome': 'Obra',
      'dataRegistro': '2026-01-01',
      'vencida': false,
      'primeiraEvidenciaId': 'ev-1',
      'primeiraEvidenciaNome': 'foto.png',
    },
    {
      'tipo': 'DESVIO',
      'id': 'dv-1',
      'titulo': 'Desvio A',
      'status': 'EM_ANALISE',
      'estabelecimentoNome': 'Canteiro',
      'dataRegistro': '2026-01-02',
    },
  ];

  test('parseia lista e separa por tipo', () async {
    when(() => mockDio.get<List<dynamic>>(
          '/api/ocorrencias',
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/api/ocorrencias'),
        data: fakeResponse,
        statusCode: 200,
      ),
    );

    final result = await container
        .read(ocorrenciasProvider(('ws-1', null)).future);

    expect(result.length, 2);
    expect(result.where((o) => o.isNc).length, 1);
    expect(result.where((o) => o.isDesvio).length, 1);
    expect(result.first.primeiraEvidenciaId, 'ev-1');
  });

  test('passa meuPapel no query quando fornecido', () async {
    when(() => mockDio.get<List<dynamic>>(
          '/api/ocorrencias',
          queryParameters: {'meuPapel': 'RESPONSAVEL_TRATATIVA_NC'},
        )).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/api/ocorrencias'),
        data: <dynamic>[],
        statusCode: 200,
      ),
    );

    final result = await container
        .read(ocorrenciasProvider((null, 'RESPONSAVEL_TRATATIVA_NC')).future);

    expect(result, isEmpty);
    verify(() => mockDio.get<List<dynamic>>(
          '/api/ocorrencias',
          queryParameters: {'meuPapel': 'RESPONSAVEL_TRATATIVA_NC'},
        )).called(1);
  });

  test('online com sucesso grava a lista no cache local', () async {
    await aguardarSessao();
    when(() => mockDio.get<List<dynamic>>(
          '/api/ocorrencias',
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/api/ocorrencias'),
        data: fakeResponse,
        statusCode: 200,
      ),
    );

    await container.read(ocorrenciasProvider(('ws-1', null)).future);

    final cached = await db.ocorrenciasCacheDao.listarPorTipoENivel('OCORRENCIA', 'FEED', 'u1');
    expect(cached.length, 2);
  });

  test('offline com cache existente cai pro cache em vez de mostrar erro cru', () async {
    await aguardarSessao();
    when(() => mockDio.get<List<dynamic>>(
          '/api/ocorrencias',
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/api/ocorrencias'),
        data: fakeResponse,
        statusCode: 200,
      ),
    );
    // primeira leitura, online, popula o cache
    await container.read(ocorrenciasProvider(('ws-1', null)).future);

    // segunda leitura, offline
    container.invalidate(ocorrenciasProvider(('ws-1', null)));
    when(() => mockDio.get<List<dynamic>>(
          '/api/ocorrencias',
          queryParameters: any(named: 'queryParameters'),
        )).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/api/ocorrencias'),
        type: DioExceptionType.connectionError,
        error: 'Failed host lookup',
      ),
    );

    final result = await container.read(ocorrenciasProvider(('ws-1', null)).future);

    expect(result.length, 2);
    expect(result.where((o) => o.isNc).length, 1);
  });

  test('offline sem cache retorna lista vazia em vez de propagar a exceção', () async {
    when(() => mockDio.get<List<dynamic>>(
          '/api/ocorrencias',
          queryParameters: any(named: 'queryParameters'),
        )).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/api/ocorrencias'),
        type: DioExceptionType.connectionError,
        error: 'Failed host lookup',
      ),
    );

    final result = await container.read(ocorrenciasProvider(('ws-1', null)).future);

    expect(result, isEmpty);
  });
}
