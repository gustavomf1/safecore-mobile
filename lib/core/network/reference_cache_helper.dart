import 'dart:convert';
import '../database/reference_cache_dao.dart';

Future<List<T>> buscarComCache<T>({
  required ReferenceCacheDao dao,
  required String chave,
  required bool online,
  required Future<List<T>> Function() buscarOnline,
  required T Function(Map<String, dynamic>) fromJson,
  required Map<String, dynamic> Function(T) toJson,
}) async {
  if (online) {
    try {
      final lista = await buscarOnline();
      await dao.salvar(chave, jsonEncode(lista.map(toJson).toList()));
      return lista;
    } catch (_) {
      // cai pro cache abaixo
    }
  }
  final cached = await dao.buscar(chave);
  if (cached == null) return [];
  return (jsonDecode(cached.dadosJson) as List)
      .map((e) => fromJson(e as Map<String, dynamic>))
      .toList();
}
