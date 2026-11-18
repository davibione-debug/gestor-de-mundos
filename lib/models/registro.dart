class Registro {
  final String id;
  final String titulo;
  final String resumo;
  final String nomeArquivoAudio;
  final DateTime dataCriacao;
  final int duracaoSegundos;

  Registro({
    required this.id,
    required this.titulo,
    required this.resumo,
    required this.nomeArquivoAudio,
    required this.dataCriacao,
    this.duracaoSegundos = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'resumo': resumo,
      'nomeArquivoAudio': nomeArquivoAudio,
      'dataCriacao': dataCriacao.toIso8601String(),
      'duracaoSegundos': duracaoSegundos,
    };
  }

  factory Registro.fromJson(Map<String, dynamic> json) {
    return Registro(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      resumo: json['resumo'] ?? '',
      nomeArquivoAudio: json['nomeArquivoAudio'] ?? '',
      dataCriacao: DateTime.tryParse(json['dataCriacao'] ?? '') ?? DateTime.now(),
      duracaoSegundos: json['duracaoSegundos'] ?? 0,
    );
  }
}