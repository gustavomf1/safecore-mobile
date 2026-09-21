import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';
import '../database/app_database.dart';
import '../../features/ocorrencias/repository/draft_repository.dart';
import '../../features/ocorrencias/repository/draft_repository_impl.dart';
import '../../features/ocorrencias/repository/nc_trecho_norma_repository_impl.dart';
import '../../features/ocorrencias/repository/evidencia_repository_impl.dart';
import '../../features/ocorrencias/model/evidencia_metadata.dart';
import '../../features/ocorrencias/model/rascunho_local.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    bffDio: ref.watch(bffDioProvider),
    draftRepository: ref.watch(draftRepositoryProvider),
    db: ref.watch(appDatabaseProvider),
    trechoRepo: ref.watch(ncTrechoNormaRepositoryProvider),
    evidenciaRepo: ref.watch(evidenciaRepositoryProvider) as EvidenciaRepositoryImpl,
  );
});

class SyncService {
  final Dio bffDio;
  final DraftRepository draftRepository;
  final AppDatabase db;
  final NcTrechoNormaRepositoryImpl trechoRepo;
  final EvidenciaRepositoryImpl evidenciaRepo;

  SyncService({
    required this.bffDio,
    required this.draftRepository,
    required this.db,
    required this.trechoRepo,
    required this.evidenciaRepo,
  });

  Future<void> sincronizarRascunho(RascunhoLocal rascunho) async {
    await draftRepository.atualizarStatus(rascunho.id, status: 'sincronizando');

    var serverId = rascunho.serverId;
    if (serverId == null) {
      final data = <String, dynamic>{'localId': rascunho.id, 'tipo': rascunho.tipo};
      if (rascunho.tipo == 'NC') {
        data['nc'] = rascunho.dadosJson;
      } else {
        data['desvio'] = rascunho.dadosJson;
      }

      try {
        final response = await bffDio.post<Map<String, dynamic>>(
          '/sync/batch',
          data: {'items': [data]},
        );
        final resultado = (response.data?['results'] as List).first as Map<String, dynamic>;
        if (resultado['status'] != 'CRIADO' || resultado['serverId'] == null) {
          await draftRepository.atualizarStatus(rascunho.id,
              status: 'erro', erroMensagem: resultado['erro'] as String? ?? 'Falha ao criar');
          return;
        }
        serverId = resultado['serverId'] as String;
        // status continua 'sincronizando' — só grava o serverId aqui pra
        // não perder essa informação se o app fechar no meio dos passos
        // seguintes (normas/fotos); o status final é decidido no fim.
        await draftRepository.atualizarStatus(rascunho.id, status: 'sincronizando', serverId: serverId);
      } catch (e) {
        await draftRepository.atualizarStatus(rascunho.id, status: 'erro', erroMensagem: e.toString());
        return;
      }
    }

    var tudoOk = true;
    final normas = await db.rascunhoNormasDao.listarDoRascunho(rascunho.id);
    for (final norma in normas.where((n) => n.status == 'pendente')) {
      if (rascunho.tipo != 'NC') continue;
      try {
        await trechoRepo.vincular(
          serverId,
          normaId: norma.normaId,
          clausulaReferencia: norma.clausulaReferencia,
          textoEditado: norma.textoEditado,
        );
        await db.rascunhoNormasDao.marcarVinculado(norma.id);
      } catch (_) {
        await db.rascunhoNormasDao.marcarErro(norma.id);
        tudoOk = false;
      }
    }

    final fotos = await db.rascunhoFotosDao.listarDoRascunho(rascunho.id);
    for (final foto in fotos.where((f) => f.status == 'pendente')) {
      try {
        final meta = EvidenciaMetadata(
          latitude: rascunho.latitude ?? 0,
          longitude: rascunho.longitude ?? 0,
          capturedAt: rascunho.capturedAt ?? DateTime.now().millisecondsSinceEpoch,
          cidade: rascunho.cidade,
        );
        final response = rascunho.tipo == 'NC'
            ? await evidenciaRepo.uploadParaNc(serverId, File(foto.path), meta)
            : await evidenciaRepo.uploadParaDesvio(serverId, File(foto.path), meta);
        await db.rascunhoFotosDao.marcarEnviado(foto.id, response.id);
      } catch (e) {
        await db.rascunhoFotosDao.marcarErro(foto.id, e.toString());
        tudoOk = false;
      }
    }

    if (tudoOk) {
      await draftRepository.atualizarStatus(rascunho.id, status: 'sincronizado', serverId: serverId);
    } else {
      await draftRepository.atualizarStatus(rascunho.id,
          status: 'erro', serverId: serverId, erroMensagem: 'Alguns itens não sincronizaram — toque para tentar de novo');
    }
  }
}
