import 'package:flutter_test/flutter_test.dart';
import 'package:engseg_mobile/core/config/app_config.dart';

void main() {
  // O host é o IP LAN da máquina de dev (editado localmente conforme a rede),
  // então o teste checa a forma da URL, não um host fixo.
  test('AppConfig has correct base URLs', () {
    expect(AppConfig.apiBaseUrl, startsWith('http://'));
    expect(AppConfig.apiBaseUrl, endsWith(':8080'));
    expect(AppConfig.bffBaseUrl, startsWith('http://'));
    expect(AppConfig.bffBaseUrl, endsWith(':8081'));
  });

  test('AppConfig has correct timeouts', () {
    expect(AppConfig.connectTimeout, equals(const Duration(seconds: 30)));
    expect(AppConfig.receiveTimeout, equals(const Duration(seconds: 60)));
  });
}
