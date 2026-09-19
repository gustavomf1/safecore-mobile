import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:safecore_mobile/features/auth/model/login_response.dart';
import 'package:safecore_mobile/features/auth/provider/auth_provider.dart';
import 'package:safecore_mobile/features/ocorrencias/repository/ocorrencias_repository_impl.dart';
import 'package:safecore_mobile/shared/widgets/safecore_shell.dart';
import 'package:safecore_mobile/shared/theme/tokens.dart';

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._session);

  final LoginResponse? _session;

  @override
  Future<LoginResponse?> build() async => _session;
}

LoginResponse _session(String perfil) => LoginResponse(
      id: 'u1',
      token: 'tok',
      nome: 'Usuario Teste',
      email: 'teste@example.com',
      perfil: perfil,
      isAdmin: false,
    );

Widget _wrap(LoginResponse? session) {
  final router = GoRouter(
    initialLocation: '/feed',
    routes: [
      ShellRoute(
        builder: (_, __, child) => SafeCoreShell(child: child),
        routes: [
          GoRoute(path: '/feed', builder: (_, __) => const SizedBox()),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      authProvider.overrideWith(() => _FakeAuthNotifier(session)),
      // Perfil EXTERNO busca o feed mesmo sem workspace selecionado (ver
      // isExterno em feed_page.dart/desvio_feed_page.dart), então sem esse
      // override a chamada de rede real do FeedPage/DesvioFeedPage nunca
      // resolve dentro do pumpAndSettle deste teste.
      ocorrenciasProvider.overrideWith((ref, _) async => []),
    ],
    child: MaterialApp.router(theme: safeCoreThemeDark(), routerConfig: router),
  );
}

void main() {
  testWidgets('mostra o FAB de criacao para perfil ENGENHEIRO', (tester) async {
    await tester.pumpWidget(_wrap(_session('ENGENHEIRO')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });

  testWidgets('mostra o FAB de criacao para perfil TECNICO', (tester) async {
    await tester.pumpWidget(_wrap(_session('TECNICO')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });

  testWidgets('esconde o FAB de criacao para perfil EXTERNO', (tester) async {
    await tester.pumpWidget(_wrap(_session('EXTERNO')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add_rounded), findsNothing);
  });
}
