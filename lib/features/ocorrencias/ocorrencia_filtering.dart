import 'model/ocorrencia_summary.dart';

class StatusBucketOption {
  final String key;
  final String label;
  const StatusBucketOption(this.key, this.label);
}

class PapelOption {
  final String? value;
  final String label;
  const PapelOption(this.value, this.label);
}

const kTodosBucket = 'TODOS';

const ncStatusOptions = [
  StatusBucketOption(kTodosBucket, 'Todos'),
  StatusBucketOption('ABERTAS', 'Abertas'),
  StatusBucketOption('EM_ANDAMENTO', 'Em Andamento'),
  StatusBucketOption('REPROVADOS', 'Reprovado'),
  StatusBucketOption('AGUARDANDO_VALIDACAO', 'Aguard. Validação'),
  StatusBucketOption('CONCLUIDAS', 'Concluídas'),
  StatusBucketOption('VENCIDAS', 'Vencidas'),
];

const desvioStatusOptions = [
  StatusBucketOption(kTodosBucket, 'Todos'),
  StatusBucketOption('AGUARD_DESVIO', 'Aguard. Tratativa'),
  StatusBucketOption('EM_ANDAMENTO', 'Em Andamento'),
  StatusBucketOption('CONCLUIDAS', 'Concluídos'),
];

const ncPapelOptions = [
  PapelOption(null, 'Todos'),
  PapelOption('REGISTRANTE', 'Sou o registrante'),
  PapelOption('RESPONSAVEL_NC', 'Responsável pela NC'),
  PapelOption('RESPONSAVEL_TRATATIVA_NC', 'Responsável pela Tratativa'),
];

const desvioPapelOptions = [
  PapelOption(null, 'Todos'),
  PapelOption('REGISTRANTE', 'Sou o registrante'),
  PapelOption('RESPONSAVEL_DESVIO', 'Responsável pelo Desvio'),
  PapelOption('RESPONSAVEL_TRATATIVA_DESVIO', 'Responsável pela Tratativa'),
];

/// Vencidas tem prioridade: uma NC em aberto e vencida cai só no bucket "Vencidas".
String bucketForNc(OcorrenciaSummary o) {
  final concluida = o.status == 'CONCLUIDA' ||
      o.status == 'CONCLUIDO' ||
      o.status == 'FECHADA' ||
      o.status == 'APROVADA';
  if (!concluida && o.vencida) return 'VENCIDAS';
  return switch (o.status) {
    'ABERTA' || 'AGUARDANDO_TRATATIVA' => 'ABERTAS',
    'EM_EXECUCAO' || 'EM_TRATAMENTO' => 'EM_ANDAMENTO',
    'EM_AJUSTE_PELO_EXTERNO' => 'REPROVADOS',
    'AGUARDANDO_APROVACAO_PLANO' || 'AGUARDANDO_VALIDACAO_FINAL' => 'AGUARDANDO_VALIDACAO',
    'CONCLUIDA' || 'CONCLUIDO' || 'FECHADA' || 'APROVADA' => 'CONCLUIDAS',
    _ => kTodosBucket,
  };
}

String bucketForDesvio(OcorrenciaSummary o) {
  return switch (o.status) {
    'ABERTO' || 'AGUARDANDO_TRATATIVA' => 'AGUARD_DESVIO',
    'AGUARDANDO_APROVACAO' => 'EM_ANDAMENTO',
    'CONCLUIDO' || 'FECHADO' || 'APROVADO' => 'CONCLUIDAS',
    _ => kTodosBucket,
  };
}

bool matchBuscaEData(
  OcorrenciaSummary o, {
  required String busca,
  required DateTime? dataInicio,
  required DateTime? dataFim,
}) {
  final q = busca.trim().toLowerCase();
  final matchBusca = q.isEmpty ||
      o.titulo.toLowerCase().contains(q) ||
      (o.localizacao ?? '').toLowerCase().contains(q) ||
      (o.codigo ?? '').toLowerCase().contains(q);
  if (!matchBusca) return false;

  if (dataInicio == null && dataFim == null) return true;
  final dataStr = o.dataRegistro.length >= 10 ? o.dataRegistro.substring(0, 10) : o.dataRegistro;
  DateTime? dataItem;
  try {
    dataItem = DateTime.parse(dataStr);
  } catch (_) {
    return true;
  }
  if (dataInicio != null && dataItem.isBefore(dataInicio)) return false;
  if (dataFim != null && dataItem.isAfter(dataFim)) return false;
  return true;
}
