import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:safecore_mobile/features/auth/model/login_response.dart';
import 'package:safecore_mobile/features/auth/model/workspace_state.dart';
import 'package:safecore_mobile/features/auth/provider/auth_provider.dart';
import 'package:safecore_mobile/features/ocorrencias/model/ocorrencia_summary.dart';
import 'package:safecore_mobile/features/ocorrencias/model/empresa.dart';
import 'package:safecore_mobile/features/ocorrencias/model/estabelecimento.dart';
import 'package:safecore_mobile/features/ocorrencias/repository/ocorrencias_repository_impl.dart';
import 'package:safecore_mobile/features/ocorrencias/desvio_feed_page.dart';
import 'package:safecore_mobile/shared/widgets/safecore_cover_card.dart';
import 'package:safecore_mobile/shared/widgets/safecore_skeleton.dart';

class MockAuthNotifier extends AsyncNotifier<LoginResponse?>
    with Mock
    implements AuthNotifier {
  @override
  Future<LoginResponse?> build() async => const LoginResponse(
        id: 'u1', token: 'tok', nome: 'T', email: 't@t.com',
        perfil: 'ENGENHEIRO', isAdmin: false,
      );
}

final _ws = const WorkspaceState(
  empresa: Empresa(id: 'e-1', nome: 'Empresa'),
  estabelecimento: Estabelecimento(id: 'ws-1', nome: 'WS'),
  empresaFilha: Empresa(id: 'ef-1', nome: 'EmpFilha'),
);

final _router = GoRouter(routes: [
  GoRoute(path: '/', builder: (_, __) => const DesvioFeedPage()),
  GoRoute(path: '/desvio/:id', builder: (_, __) => const SizedBox()),
]);

Widget _wrap(List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(routerConfig: _router),
    );

const _dv = OcorrenciaSummary(
  tipo: 'DESVIO',
  id: 'dv-1',
  titulo: 'Desvio Teste',
  status: 'EM_ANALISE',
  estabelecimentoNome: 'Canteiro B',
  dataRegistro: '2026-06-01',
);

void main() {
  testWidgets('feed Desvio mostra skeleton no loading', (tester) async {
    final completer = Completer<List<OcorrenciaSummary>>();
    await tester.pumpWidget(_wrap([
      authProvider.overrideWith(MockAuthNotifier.new),
      workspaceProvider.overrideWith((ref) => _ws),
      ocorrenciasProvider.overrideWith((ref, _) => completer.future),
    ]));
    await tester.pump(Duration.zero);
    expect(find.byType(CoverCardSkeleton), findsWidgets);
    completer.complete([]);
    await tester.pumpAndSettle();
  });

  testWidgets('feed Desvio mostra SafeCoreCoverCard com dados', (tester) async {
    await tester.pumpWidget(_wrap([
      authProvider.overrideWith(MockAuthNotifier.new),
      workspaceProvider.overrideWith((ref) => _ws),
      ocorrenciasProvider.overrideWith((ref, _) async => [_dv]),
    ]));
    await tester.pumpAndSettle();
    expect(find.byType(SafeCoreCoverCard), findsOneWidget);
    expect(find.text('Desvio Teste'), findsOneWidget);
  });

  testWidgets('feed Desvio mostra empty state quando lista vazia',
      (tester) async {
    await tester.pumpWidget(_wrap([
      authProvider.overrideWith(MockAuthNotifier.new),
      workspaceProvider.overrideWith((ref) => _ws),
      ocorrenciasProvider.overrideWith((ref, _) async => []),
    ]));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum desvio encontrado'), findsOneWidget);
  });

  testWidgets('feed Desvio mostra error state em falha de rede', (tester) async {
    await tester.pumpWidget(_wrap([
      authProvider.overrideWith(MockAuthNotifier.new),
      workspaceProvider.overrideWith((ref) => _ws),
      ocorrenciasProvider.overrideWith(
          (ref, _) async => throw Exception('Sem rede')),
    ]));
    await tester.pumpAndSettle();
    expect(find.text('Erro ao carregar'), findsOneWidget);
  });
}
