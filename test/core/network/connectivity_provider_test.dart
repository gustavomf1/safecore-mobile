import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecore_mobile/core/network/connectivity_provider.dart';

const _channel = MethodChannel('dev.fluttercommunity.plus/connectivity');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
      if (call.method == 'check') return ['wifi'];
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  test('connectivityProvider emite um valor antes de qualquer mudança de rede', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // força a criação do provider e espera o primeiro evento
    final sub = container.listen(connectivityProvider, (_, __) {});
    await Future.delayed(const Duration(milliseconds: 100));

    expect(sub.read().hasValue, isTrue);
  });
}
