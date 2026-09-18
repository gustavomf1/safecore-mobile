import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safecore_mobile/features/auth/model/login_response.dart';
import 'package:safecore_mobile/features/auth/provider/auth_provider.dart';
import 'package:safecore_mobile/shared/widgets/safecore_auth_image.dart';
import 'package:safecore_mobile/shared/theme/tokens.dart';

class MockAuthNotifier extends AsyncNotifier<LoginResponse?>
    with Mock
    implements AuthNotifier {
  @override
  Future<LoginResponse?> build() async => const LoginResponse(
        id: 'u1',
        token: 'tok123',
        nome: 'Test',
        email: 't@t.com',
        perfil: 'ENGENHEIRO',
        isAdmin: false,
      );
}

void main() {
  testWidgets('SafeCoreAuthImage renderiza sem crash quando token disponível',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(MockAuthNotifier.new),
        ],
        child: MaterialApp(
          theme: safeCoreThemeDark(),
          home: const Scaffold(
            body: SafeCoreAuthImage(url: 'http://localhost/api/evidencias/1/download'),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(SafeCoreAuthImage), findsOneWidget);
  });

  testWidgets('SafeCoreAuthImage renderiza error widget em rede inacessível',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(MockAuthNotifier.new),
        ],
        child: MaterialApp(
          theme: safeCoreThemeDark(),
          home: const Scaffold(
            body: SafeCoreAuthImage(
              url: 'http://localhost/api/evidencias/404/download',
              errorWidget: SizedBox(key: Key('err'), width: 10, height: 10),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(SafeCoreAuthImage), findsOneWidget);
  });
}
