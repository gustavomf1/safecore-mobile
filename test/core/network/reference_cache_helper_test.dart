import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecore_mobile/core/database/app_database.dart';
import 'package:safecore_mobile/core/network/reference_cache_helper.dart';

class _Item {
  final String id;
  final String nome;
  const _Item(this.id, this.nome);
  Map<String, dynamic> toJson() => {'id': id, 'nome': nome};
  static _Item fromJson(Map<String, dynamic> j) => _Item(j['id'] as String, j['nome'] as String);
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  test('online com sucesso busca da rede e grava no cache', () async {
    final resultado = await buscarComCache<_Item>(
      dao: db.referenceCacheDao,
      chave: 'normas',
      online: true,
      buscarOnline: () async => [const _Item('n1', 'Norma 1')],
      fromJson: _Item.fromJson,
      toJson: (i) => i.toJson(),
    );

    expect(resultado.single.nome, 'Norma 1');
    final cached = await db.referenceCacheDao.buscar('normas');
    expect(cached, isNotNull);
  });

  test('online mas buscarOnline falha cai pro cache existente', () async {
    await db.referenceCacheDao.salvar('normas', '[{"id":"n1","nome":"Cacheada"}]');

    final resultado = await buscarComCache<_Item>(
      dao: db.referenceCacheDao,
      chave: 'normas',
      online: true,
      buscarOnline: () async => throw Exception('rede caiu'),
      fromJson: _Item.fromJson,
      toJson: (i) => i.toJson(),
    );

    expect(resultado.single.nome, 'Cacheada');
  });

  test('offline lê direto do cache sem chamar buscarOnline', () async {
    await db.referenceCacheDao.salvar('normas', '[{"id":"n1","nome":"Cacheada"}]');
    var chamouOnline = false;

    final resultado = await buscarComCache<_Item>(
      dao: db.referenceCacheDao,
      chave: 'normas',
      online: false,
      buscarOnline: () async {
        chamouOnline = true;
        return [];
      },
      fromJson: _Item.fromJson,
      toJson: (i) => i.toJson(),
    );

    expect(chamouOnline, isFalse);
    expect(resultado.single.nome, 'Cacheada');
  });

  test('offline sem cache retorna lista vazia', () async {
    final resultado = await buscarComCache<_Item>(
      dao: db.referenceCacheDao,
      chave: 'chave-nunca-cacheada',
      online: false,
      buscarOnline: () async => [],
      fromJson: _Item.fromJson,
      toJson: (i) => i.toJson(),
    );

    expect(resultado, isEmpty);
  });
}
