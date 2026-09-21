import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:safecore_mobile/features/auth/model/workspace_state.dart';
import 'package:safecore_mobile/features/auth/repository/auth_repository_impl.dart';
import 'package:safecore_mobile/features/ocorrencias/model/empresa.dart';
import 'package:safecore_mobile/features/ocorrencias/model/estabelecimento.dart';

class MockDio extends Mock implements Dio {}
class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockDio dio;
  late MockSecureStorage storage;
  late AuthRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    dio = MockDio();
    storage = MockSecureStorage();
    repo = AuthRepositoryImpl(dio: dio, storage: storage);
  });

  group('login', () {
    setUp(() {
      when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});
      when(() => dio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/api/auth/login'),
            statusCode: 200,
            data: {
              'id': 'user-uuid',
              'token': 'eyJhbGci.test',
              'nome': 'João Silva',
              'email': 'joao@test.com',
              'perfil': 'ENGENHEIRO',
              'isAdmin': false,
            },
          ));
    });

    test('returns LoginResponse with correct fields', () async {
      final result = await repo.login('joao@test.com', 'senha123');
      expect(result.token, 'eyJhbGci.test');
      expect(result.perfil, 'ENGENHEIRO');
      expect(result.isAdmin, false);
    });

    test('persists jwt_token to secure storage', () async {
      await repo.login('joao@test.com', 'senha123');
      verify(() => storage.write(key: 'jwt_token', value: 'eyJhbGci.test')).called(1);
    });

    test('persists user_session as JSON to secure storage', () async {
      await repo.login('joao@test.com', 'senha123');
      final captured = verify(
        () => storage.write(key: 'user_session', value: captureAny(named: 'value')),
      ).captured;
      final decoded = jsonDecode(captured.first as String) as Map<String, dynamic>;
      expect(decoded['token'], 'eyJhbGci.test');
      expect(decoded['perfil'], 'ENGENHEIRO');
    });
  });

  group('logout', () {
    test('clears all secure storage', () async {
      when(() => storage.read(key: 'refresh_token')).thenAnswer((_) async => null);
      when(() => storage.deleteAll()).thenAnswer((_) async {});
      await repo.logout();
      verify(() => storage.deleteAll()).called(1);
    });
  });

  group('solicitarReset', () {
    test('posts email to /api/auth/reset/solicitar', () async {
      when(() => dio.post('/api/auth/reset/solicitar', data: {'email': 'joao@test.com'}))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/api/auth/reset/solicitar'),
                statusCode: 200,
                data: {'mensagem': 'ok'},
              ));

      await repo.solicitarReset('joao@test.com');

      verify(() => dio.post('/api/auth/reset/solicitar', data: {'email': 'joao@test.com'})).called(1);
    });
  });

  group('verificarOtp', () {
    test('returns resetToken from response', () async {
      when(() => dio.post('/api/auth/reset/verificar',
              data: {'email': 'joao@test.com', 'otp': '123456'}))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/api/auth/reset/verificar'),
                statusCode: 200,
                data: {'resetToken': 'a1b2c3d4-0000-0000-0000-000000000000'},
              ));

      final resetToken = await repo.verificarOtp('joao@test.com', '123456');

      expect(resetToken, 'a1b2c3d4-0000-0000-0000-000000000000');
    });
  });

  group('redefinirSenha', () {
    test('posts resetToken and novaSenha to /api/auth/reset/redefinir', () async {
      when(() => dio.post('/api/auth/reset/redefinir',
              data: {'resetToken': 'a1b2c3d4-0000-0000-0000-000000000000', 'novaSenha': 'NovaSenha123!'}))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/api/auth/reset/redefinir'),
                statusCode: 200,
              ));

      await repo.redefinirSenha('a1b2c3d4-0000-0000-0000-000000000000', 'NovaSenha123!');

      verify(() => dio.post('/api/auth/reset/redefinir',
          data: {'resetToken': 'a1b2c3d4-0000-0000-0000-000000000000', 'novaSenha': 'NovaSenha123!'})).called(1);
    });
  });

  group('salvarWorkspace / obterWorkspace', () {
    final workspace = const WorkspaceState(
      empresa: Empresa(id: 'e1', nome: 'Empresa Mãe'),
      estabelecimento: Estabelecimento(id: 'est1', nome: 'Estabelecimento', empresaId: 'e1'),
      empresaFilha: Empresa(id: 'ef1', nome: 'Empresa Filha'),
    );

    test('salvarWorkspace grava o workspace como JSON na chave workspace', () async {
      when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      await repo.salvarWorkspace(workspace);

      final captured = verify(
        () => storage.write(key: 'workspace', value: captureAny(named: 'value')),
      ).captured;
      final decoded = jsonDecode(captured.first as String) as Map<String, dynamic>;
      expect(decoded['empresa']['id'], 'e1');
      expect(decoded['estabelecimento']['id'], 'est1');
      expect(decoded['empresaFilha']['id'], 'ef1');
    });

    test('obterWorkspace retorna null quando nada foi salvo', () async {
      when(() => storage.read(key: 'workspace')).thenAnswer((_) async => null);
      final result = await repo.obterWorkspace();
      expect(result, isNull);
    });

    test('obterWorkspace reconstrói o WorkspaceState a partir do JSON salvo', () async {
      when(() => storage.read(key: 'workspace'))
          .thenAnswer((_) async => jsonEncode(workspace.toJson()));

      final result = await repo.obterWorkspace();

      expect(result?.empresa.id, 'e1');
      expect(result?.estabelecimento.nome, 'Estabelecimento');
      expect(result?.empresaFilha.id, 'ef1');
    });
  });

  group('getSession', () {
    test('returns null when no session stored', () async {
      when(() => storage.read(key: 'user_session')).thenAnswer((_) async => null);
      final result = await repo.getSession();
      expect(result, isNull);
    });

    test('returns LoginResponse from stored session JSON', () async {
      final stored = jsonEncode({
        'id': 'u1',
        'token': 'tok',
        'nome': 'Ana',
        'email': 'ana@test.com',
        'perfil': 'TECNICO',
        'isAdmin': false,
      });
      when(() => storage.read(key: 'user_session')).thenAnswer((_) async => stored);
      // Payload sem 'exp' faz _isTokenExpired retornar false, sem precisar mockar o fluxo de refresh.
      when(() => storage.read(key: 'jwt_token'))
          .thenAnswer((_) async => 'eyJhbGciOiJIUzI1NiJ9.e30.sig');
      final result = await repo.getSession();
      expect(result?.perfil, 'TECNICO');
      expect(result?.nome, 'Ana');
    });
  });
}
