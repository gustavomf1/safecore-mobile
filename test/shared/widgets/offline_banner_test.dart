import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecore_mobile/core/network/connectivity_provider.dart';
import 'package:safecore_mobile/shared/widgets/offline_banner.dart';
import 'package:safecore_mobile/shared/theme/tokens.dart';

Widget _wrap(List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: MaterialApp(theme: safeCoreThemeDark(), home: const Scaffold(body: OfflineBanner())),
    );

void main() {
  testWidgets('mostra aviso quando offline', (tester) async {
    await tester.pumpWidget(_wrap([
      connectivityProvider.overrideWith((ref) => Stream.value(false)),
    ]));
    await tester.pumpAndSettle();

    expect(find.textContaining('sem internet'), findsOneWidget);
  });

  testWidgets('não mostra nada quando online', (tester) async {
    await tester.pumpWidget(_wrap([
      connectivityProvider.overrideWith((ref) => Stream.value(true)),
    ]));
    await tester.pumpAndSettle();

    expect(find.textContaining('sem internet'), findsNothing);
  });
}
