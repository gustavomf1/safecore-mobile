import '../model/rascunho_local.dart';

abstract class DraftRepository {
  Stream<List<RascunhoLocal>> watchPendentes(String usuarioId);
  Future<void> salvar(RascunhoLocal rascunho);
  Future<void> atualizarStatus(
    String id, {
    required String status,
    String? serverId,
    String? erroMensagem,
  });
  Future<void> deletar(String id);
}
