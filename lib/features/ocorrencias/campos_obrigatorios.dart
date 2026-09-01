import 'model/nc_detail.dart';
import 'model/desvio_detail.dart';

const Map<String, String> camposObrigatoriosLabels = {
  'MATRIZ_RISCO': 'Matriz de risco (severidade e probabilidade)',
  'RESPONSAVEL_TRATATIVA': 'Responsável pela tratativa',
  'RESPONSAVEL_NC': 'Responsável pela NC',
  'NORMA_VINCULADA': 'Norma vinculada',
  'DESCRICAO': 'Descrição',
  'ORIENTACAO_REALIZADA': 'Orientação realizada',
  'RESPONSAVEL_DESVIO': 'Responsável pelo Desvio',
};

List<String> camposFaltantesNc(NcDetail nc) {
  final faltantes = <String>[];
  if (nc.severidade == null || nc.probabilidade == null) faltantes.add('MATRIZ_RISCO');
  if (nc.responsavelTrativaNome == null || nc.responsavelTrativaNome!.isEmpty) faltantes.add('RESPONSAVEL_TRATATIVA');
  if (nc.responsavelNcNome == null || nc.responsavelNcNome!.isEmpty) faltantes.add('RESPONSAVEL_NC');
  if (nc.normas.isEmpty) faltantes.add('NORMA_VINCULADA');
  if (nc.descricao == null || nc.descricao!.trim().isEmpty) faltantes.add('DESCRICAO');
  return faltantes;
}

List<String> camposFaltantesDesvio(DesvioDetail d) {
  final faltantes = <String>[];
  if (d.descricao == null || d.descricao!.trim().isEmpty) faltantes.add('DESCRICAO');
  if (d.orientacaoRealizada == null || d.orientacaoRealizada!.trim().isEmpty) faltantes.add('ORIENTACAO_REALIZADA');
  if (d.responsavelDesvioId == null) faltantes.add('RESPONSAVEL_DESVIO');
  if (d.responsavelTratativaId == null) faltantes.add('RESPONSAVEL_TRATATIVA');
  return faltantes;
}
