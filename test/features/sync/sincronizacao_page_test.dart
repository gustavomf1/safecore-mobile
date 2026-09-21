import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecore_mobile/features/auth/model/login_response.dart';
import 'package:safecore_mobile/features/auth/provider/auth_provider.dart';
import 'package:safecore_mobile/features/ocorrencias/model/rascunho_local.dart';
import 'package:safecore_mobile/features/ocorrencias/repository/draft_repository_impl.dart';
import 'package:safecore_mobile/features/sync/sincronizacao_page.dart';
import 'package:safecore_mobile/shared/theme/tokens.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthNotifier extends AsyncNotifier<LoginResponse?> with Mock implements AuthNotifier {
  @override
  Future<LoginResponse?> build() async => const LoginResponse(
        id: 'u1', token: 'tok', nome: 'T', email: 't@t.com', perfil: 'ENGENHEIRO', isAdmin: false,
      );
}

Widget _wrap(List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: MaterialApp(theme: safeCoreThemeDark(), home: const SincronizacaoPage()),
    );

void main() {
  testWidgets('mostra rascunhos pendentes com status', (tester) async {
    await tester.pumpWidget(_wrap([
      authProvider.overrideWith(MockAuthNotifier.new),
      draftsProvider.overrideWith((ref, usuarioId) async* {
        yield [
          RascunhoLocal(
            id: 'r1', usuarioId: 'u1', tipo: 'NC', titulo: 'Vazamento',
            dadosJson: const {}, criadoEm: DateTime.now().millisecondsSinceEpoch,
            status: 'pendente',
          ),
        ];
      }),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Vazamento'), findsOneWidget);
    expect(find.text('Pendente'), findsOneWidget);
  });

  testWidgets('sem rascunhos pendentes mostra estado vazio', (tester) async {
    await tester.pumpWidget(_wrap([
      authProvider.overrideWith(MockAuthNotifier.new),
      draftsProvider.overrideWith((ref, usuarioId) async* {
        yield <RascunhoLocal>[];
      }),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Vazamento'), findsNothing);
  });
}
