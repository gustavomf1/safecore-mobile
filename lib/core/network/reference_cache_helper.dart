import 'dart:convert';
import 'package:flutter/foundation.dart';
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
      try {
        await dao.salvar(chave, jsonEncode(lista.map(toJson).toList()));
      } catch (e) {
        // falha ao cachear não pode descartar um resultado online que já
        // funcionou — só loga e segue com o que veio da rede.
        debugPrint('buscarComCache[$chave]: falha ao gravar cache: $e');
      }
      return lista;
    } catch (e) {
      debugPrint('buscarComCache[$chave]: buscarOnline falhou: $e');
      // cai pro cache abaixo
    }
  }
  final cached = await dao.buscar(chave);
  if (cached == null) return [];
  return (jsonDecode(cached.dadosJson) as List)
      .map((e) => fromJson(e as Map<String, dynamic>))
      .toList();
}
