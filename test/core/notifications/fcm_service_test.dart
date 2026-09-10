import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:safecore_mobile/core/notifications/fcm_service.dart';

void main() {
  late GlobalKey<NavigatorState> navigatorKey;
  late GoRouter router;
  late FcmService service;

  setUp(() {
    navigatorKey = GlobalKey<NavigatorState>();
    router = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SizedBox()),
        GoRoute(path: '/oc/:id', builder: (_, state) => Text('NC ${state.pathParameters['id']}')),
        GoRoute(path: '/desvio/:id', builder: (_, state) => Text('Desvio ${state.pathParameters['id']}')),
      ],
    );
    service = FcmService(
      bffDio: Dio(),
      messengerKey: GlobalKey<ScaffoldMessengerState>(),
      navigatorKey: navigatorKey,
      onNotificationReceived: () {},
    );
  });

  testWidgets('navigateToNotification navega para /oc/{ncId} quando data tem ncId', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    service.navigateToNotification(const RemoteMessage(data: {'ncId': 'nc-123'}));
    await tester.pumpAndSettle();

    expect(find.text('NC nc-123'), findsOneWidget);
  });

  testWidgets('navigateToNotification nao navega quando data nao tem ncId nem desvioId', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    service.navigateToNotification(const RemoteMessage(data: {}));
    await tester.pumpAndSettle();

    expect(find.text('NC nc-123'), findsNothing);
    expect(find.text('Desvio dev-123'), findsNothing);
  });

  testWidgets('navigateToNotification navega para /desvio/{desvioId} quando data tem desvioId', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    service.navigateToNotification(const RemoteMessage(data: {'desvioId': 'dev-123'}));
    await tester.pumpAndSettle();

    expect(find.text('Desvio dev-123'), findsOneWidget);
  });

  testWidgets('navigateToNotification prefere desvioId sobre ncId quando ambos presentes', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    service.navigateToNotification(const RemoteMessage(data: {'desvioId': 'dev-456', 'ncId': 'nc-456'}));
    await tester.pumpAndSettle();

    expect(find.text('Desvio dev-456'), findsOneWidget);
    expect(find.text('NC nc-456'), findsNothing);
  });
}
