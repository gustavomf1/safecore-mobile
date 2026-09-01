class NcTrechoNorma {
  final String id;
  final String normaId;
  final String normaTitulo;
  final String? clausulaReferencia;
  final String textoEditado;

  const NcTrechoNorma({
    required this.id,
    required this.normaId,
    required this.normaTitulo,
    this.clausulaReferencia,
    required this.textoEditado,
  });

  factory NcTrechoNorma.fromJson(Map<String, dynamic> json) => NcTrechoNorma(
        id: json['id'] as String,
        normaId: json['normaId'] as String,
        normaTitulo: json['normaTitulo'] as String? ?? '',
        clausulaReferencia: json['clausulaReferencia'] as String?,
        textoEditado: json['textoEditado'] as String? ?? '',
      );
}
