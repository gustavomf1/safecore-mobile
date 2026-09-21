import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/ocorrencia_summary.dart';
import 'ocorrencias_repository.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/ocorrencias_cache_dao.dart';
import '../../auth/provider/auth_provider.dart';

// Provider key: (estabelecimentoId, meuPapel)
final ocorrenciasProvider =
    FutureProvider.family<List<OcorrenciaSummary>, (String?, String?)>(
  (ref, args) async {
    final (estabelecimentoId, meuPapel) = args;
    return ref
        .read(ocorrenciasRepositoryProvider)
        .listar(estabelecimentoId: estabelecimentoId, meuPapel: meuPapel);
  },
);

final ocorrenciasRepositoryProvider = Provider<OcorrenciasRepository>((ref) {
  return OcorrenciasRepositoryImpl(
    dio: ref.watch(dioProvider),
    cacheDao: ref.watch(appDatabaseProvider).ocorrenciasCacheDao,
    usuarioId: ref.watch(authProvider).valueOrNull?.id ?? '',
  );
});

class OcorrenciasRepositoryImpl implements OcorrenciasRepository {
  final Dio dio;
  final OcorrenciasCacheDao? cacheDao;
  final String usuarioId;

  // Bucket próprio no cache compartilhado (tipo/nível distintos dos usados por
  // NcRepositoryImpl/DesvioRepositoryImpl) — evita colidir na mesma chave
  // primária {id, nivel} quando o mesmo id aparece nos dois caches.
  static const _tipoCache = 'OCORRENCIA';
  static const _nivelCache = 'FEED';

  OcorrenciasRepositoryImpl({required this.dio, required this.cacheDao, required this.usuarioId});

  @override
  Future<List<OcorrenciaSummary>> listar({
    String? estabelecimentoId,
    String? meuPapel,
  }) async {
    try {
      final response = await dio.get<List<dynamic>>(
        '/api/ocorrencias',
        queryParameters: {
          if (estabelecimentoId != null) 'estabelecimentoId': estabelecimentoId,
          if (meuPapel != null) 'meuPapel': meuPapel,
        },
      );
      final rawList = response.data ?? [];
      final list = rawList.map((e) => OcorrenciaSummary.fromJson(e as Map<String, dynamic>)).toList();
      await cacheDao?.limpar(_tipoCache);
      for (var i = 0; i < rawList.length; i++) {
        await cacheDao?.salvar(OcorrenciasCacheCompanion.insert(
          id: list[i].id,
          tipo: _tipoCache,
          nivel: _nivelCache,
          dadosJson: jsonEncode(rawList[i]),
          usuarioId: usuarioId,
          cachedEm: DateTime.now().millisecondsSinceEpoch,
        ));
      }
      return list;
    } on DioException catch (_) {
      final cached = await cacheDao?.listarPorTipoENivel(_tipoCache, _nivelCache, usuarioId) ?? [];
      return cached
          .map((c) => OcorrenciaSummary.fromJson(jsonDecode(c.dadosJson) as Map<String, dynamic>))
          .toList();
    }
  }
}
