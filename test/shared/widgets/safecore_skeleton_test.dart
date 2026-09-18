import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecore_mobile/shared/widgets/safecore_skeleton.dart';
import 'package:safecore_mobile/shared/theme/tokens.dart';

void main() {
  testWidgets('SafeCoreSkeleton renderiza Container', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: safeCoreThemeDark(), home: const Scaffold(body: SafeCoreSkeleton(height: 40))),
    );
    await tester.pump(Duration.zero); // fire flutter_animate startup timer
    expect(find.byType(Container), findsWidgets);
    await tester.pumpWidget(const SizedBox()); // dispose AnimationController
    await tester.pump();
  });

  testWidgets('CoverCardSkeleton renderiza múltiplos SafeCoreSkeleton', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: safeCoreThemeDark(), home: const Scaffold(body: CoverCardSkeleton())),
    );
    await tester.pump(Duration.zero);
    expect(find.byType(SafeCoreSkeleton), findsWidgets);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
