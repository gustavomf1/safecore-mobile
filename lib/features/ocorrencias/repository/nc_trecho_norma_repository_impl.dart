import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/nc_trecho_norma.dart';
import '../../../core/network/dio_client.dart';

final ncTrechoNormaRepositoryProvider = Provider<NcTrechoNormaRepositoryImpl>((ref) {
  return NcTrechoNormaRepositoryImpl(dio: ref.watch(dioProvider));
});

/// Trechos de norma vinculados a uma NC (só faz sentido para NC — Desvio não
/// tem normas). Usado para pré-popular a edição com o que já foi salvo.
final ncTrechosProvider = FutureProvider.family<List<NcTrechoNorma>, String>((ref, ncId) async {
  return ref.watch(ncTrechoNormaRepositoryProvider).listar(ncId);
});

class NcTrechoNormaRepositoryImpl {
  final Dio dio;
  NcTrechoNormaRepositoryImpl({required this.dio});

  Future<List<NcTrechoNorma>> listar(String ncId) async {
    final response = await dio.get<List<dynamic>>('/api/nao-conformidades/$ncId/trechos-norma');
    return (response.data ?? [])
        .map((e) => NcTrechoNorma.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<NcTrechoNorma> vincular(
    String ncId, {
    required String normaId,
    String? clausulaReferencia,
    required String textoEditado,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/api/nao-conformidades/$ncId/trechos-norma',
      data: {
        'normaId': normaId,
        if (clausulaReferencia != null && clausulaReferencia.isNotEmpty) 'clausulaReferencia': clausulaReferencia,
        'textoEditado': textoEditado,
      },
    );
    return NcTrechoNorma.fromJson(response.data!);
  }

  Future<void> deletar(String ncId, String trechoId) async {
    await dio.delete('/api/nao-conformidades/$ncId/trechos-norma/$trechoId');
  }
}
