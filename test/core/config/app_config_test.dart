import 'package:flutter_test/flutter_test.dart';
import 'package:engseg_mobile/core/config/app_config.dart';

void main() {
  test('AppConfig has correct base URLs', () {
    expect(AppConfig.apiBaseUrl, equals('https://api.safecoreteste.online'));
    expect(AppConfig.bffBaseUrl, equals('https://mobile-api.safecoreteste.online'));
  });

  test('AppConfig has correct timeouts', () {
    expect(AppConfig.connectTimeout, equals(const Duration(seconds: 30)));
    expect(AppConfig.receiveTimeout, equals(const Duration(seconds: 60)));
  });
}
