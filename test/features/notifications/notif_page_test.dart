import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safecore_mobile/features/notifications/notif_page.dart';
import 'package:safecore_mobile/features/notifications/model/notificacao_item.dart';
import 'package:safecore_mobile/features/notifications/repository/notificacao_repository.dart';
import 'package:safecore_mobile/features/notifications/repository/notificacao_repository_impl.dart';

class _MockNotificacaoRepository extends Mock implements NotificacaoRepository {}

GoRouter _buildRouter() => GoRouter(routes: [
  GoRoute(path: '/', builder: (_, __) => const NotifPage()),
  GoRoute(path: '/oc/:id', builder: (_, state) => Text('NC ${state.pathParameters['id']}')),
  GoRoute(path: '/desvio/:id', builder: (_, state) => Text('Desvio ${state.pathParameters['id']}')),
]);

Widget _wrap(List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(routerConfig: _buildRouter()),
    );

final _itemNc = NotificacaoItem(
  id: 'notif-1',
  ncId: 'nc-1',
  tipo: 'NC_ATIVADA',
  titulo: 'SafeCore — NC Teste',
  corpo: 'corpo do push',
  lida: false,
  criadoEm: DateTime(2026, 6, 19, 10, 0),
);

final _itemDesvio = NotificacaoItem(
  id: 'notif-2',
  desvioId: 'dev-1',
  tipo: 'DESVIO_ATIVADO',
  titulo: 'SafeCore — Desvio Teste',
  corpo: 'corpo desvio',
  lida: false,
  criadoEm: DateTime(2026, 6, 19, 11, 0),
);

void main() {
  testWidgets('notif page mostra lista vinda do provider', (tester) async {
    await tester.pumpWidget(_wrap([
      notificacoesProvider.overrideWith((ref) async => [_itemNc]),
    ]));
    await tester.pumpAndSettle();
    expect(find.text('SafeCore — NC Teste'), findsOneWidget);
    expect(find.text('corpo do push'), findsOneWidget);
  });

  testWidgets('notif page mostra empty state quando lista vazia', (tester) async {
    await tester.pumpWidget(_wrap([
      notificacoesProvider.overrideWith((ref) async => []),
    ]));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma notificação por aqui'), findsOneWidget);
  });

  testWidgets('tap em item com ncId navega para /oc/:id', (tester) async {
    final repo = _MockNotificacaoRepository();
    when(() => repo.marcarComoLida(any())).thenAnswer((_) async {});

    await tester.pumpWidget(_wrap([
      notificacoesProvider.overrideWith((ref) async => [_itemNc]),
      notificacaoRepositoryProvider.overrideWithValue(repo),
    ]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SafeCore — NC Teste'));
    await tester.pumpAndSettle();

    expect(find.text('NC nc-1'), findsOneWidget);
  });

  testWidgets('tap em item com desvioId navega para /desvio/:id', (tester) async {
    final repo = _MockNotificacaoRepository();
    when(() => repo.marcarComoLida(any())).thenAnswer((_) async {});

    await tester.pumpWidget(_wrap([
      notificacoesProvider.overrideWith((ref) async => [_itemDesvio]),
      notificacaoRepositoryProvider.overrideWithValue(repo),
    ]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SafeCore — Desvio Teste'));
    await tester.pumpAndSettle();

    expect(find.text('Desvio dev-1'), findsOneWidget);
  });
}
