class Norma {
  final String id;
  // Backend retorna só "titulo" — mapeamos para ambos os campos usados no wizard
  final String codigo;
  final String nome;

  const Norma({required this.id, required this.codigo, required this.nome});

  factory Norma.fromJson(Map<String, dynamic> json) {
    final titulo = json['titulo'] as String? ?? '';
    return Norma(
      id: json['id'] as String,
      codigo: titulo,
      nome: titulo,
    );
  }

  // Espelha fromJson: backend usa "titulo", que mapeamos para codigo e nome.
  Map<String, dynamic> toJson() => {'id': id, 'titulo': nome};
}
