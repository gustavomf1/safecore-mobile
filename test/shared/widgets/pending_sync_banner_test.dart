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
import 'package:mocktail/mocktail.dart';

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
