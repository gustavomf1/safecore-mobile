import 'dart:convert';

class RascunhoLocal {
  final String id;
  final String usuarioId;
  final String tipo; // "NC" | "DESVIO"
  final String titulo;
  final String? descricao;
  final int? severidade;
  final double? latitude;
  final double? longitude;
  final int? capturedAt;
  final String? cidade;
  final Map<String, dynamic> dadosJson;
  final int criadoEm;
  final String status; // pendente | sincronizando | erro | sincronizado
  final String? erroMensagem;
  final String? serverId;

  const RascunhoLocal({
    required this.id,
    required this.usuarioId,
    required this.tipo,
    required this.titulo,
    this.descricao,
    this.severidade,
    this.latitude,
    this.longitude,
    this.capturedAt,
    this.cidade,
    required this.dadosJson,
    required this.criadoEm,
    this.status = 'pendente',
    this.erroMensagem,
    this.serverId,
  });

  String get dadosJsonEncoded => jsonEncode(dadosJson);
}
