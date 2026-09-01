import 'model/nc_summary.dart';

/// Espelha a regra do backend (NaoConformidadeService.validarFimDaCadeia):
/// se a NC escolhida como "anterior" já tem uma sucessora, o backend rejeita
/// a gravação. Aqui adiantamos esse aviso na UI, apontando a última NC da
/// cadeia para o usuário selecionar em vez da NC "no meio" da cadeia.
NcSummary? reincidenciaChainEnd(
  List<NcSummary> ncs,
  String ncAnteriorId, {
  String? excludeId,
}) {
  bool aplicavel(NcSummary nc) => nc.id != excludeId;

  NcSummary? sucessora(String id) {
    for (final nc in ncs) {
      if (nc.ncAnteriorId == id && aplicavel(nc)) return nc;
    }
    return null;
  }

  var fim = sucessora(ncAnteriorId);
  if (fim == null) return null;
  while (true) {
    final prox = sucessora(fim!.id);
    if (prox == null) break;
    fim = prox;
  }
  return fim;
}
