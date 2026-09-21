import '../../ocorrencias/model/empresa.dart';
import '../../ocorrencias/model/estabelecimento.dart';

class WorkspaceState {
  final Empresa empresa;
  final Estabelecimento estabelecimento;
  final Empresa empresaFilha;

  const WorkspaceState({
    required this.empresa,
    required this.estabelecimento,
    required this.empresaFilha,
  });

  factory WorkspaceState.fromJson(Map<String, dynamic> json) => WorkspaceState(
        empresa: Empresa.fromJson(json['empresa'] as Map<String, dynamic>),
        estabelecimento: Estabelecimento.fromJson(json['estabelecimento'] as Map<String, dynamic>),
        empresaFilha: Empresa.fromJson(json['empresaFilha'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'empresa': empresa.toJson(),
        'estabelecimento': estabelecimento.toJson(),
        'empresaFilha': empresaFilha.toJson(),
      };
}
