class Item {
  final String nome;
  final String tipo;
  final String descricao;
  final int custoEmCreditos;
  final String efeito;
  final String localizacao;
  final int quantidade;

  const Item({
    required this.nome,
    required this.tipo,
    this.descricao = '',
    required this.custoEmCreditos,
    required this.efeito,
    this.localizacao = '',
    this.quantidade = 1,
  });

  Item copyWith({
    String? nome,
    String? tipo,
    String? descricao,
    int? custoEmCreditos,
    String? efeito,
    String? localizacao,
    int? quantidade,
  }) {
    return Item(
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      custoEmCreditos:
          custoEmCreditos ?? this.custoEmCreditos,
      efeito: efeito ?? this.efeito,
      localizacao:
          localizacao ?? this.localizacao,
      quantidade:
          quantidade ?? this.quantidade,
    );
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      nome: map['nome']?.toString() ?? '',
      tipo: map['tipo']?.toString() ?? '',
      descricao:
          map['descricao']?.toString() ?? '',
      custoEmCreditos:
          _int(map['custoEmCreditos']),
      efeito: map['efeito']?.toString() ?? '',
      localizacao:
          map['localizacao']?.toString() ?? '',
      quantidade:
          _int(map['quantidade'], padrao: 1),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'tipo': tipo,
      'descricao': descricao,
      'custoEmCreditos': custoEmCreditos,
      'efeito': efeito,
      'localizacao': localizacao,
      'quantidade': quantidade,
    };
  }

  static int _int(
    dynamic valor, {
    int padrao = 0,
  }) {
    if (valor == null) return padrao;

    if (valor is int) return valor;

    if (valor is num) {
      return valor.round();
    }

    return double.tryParse(
          valor
              .toString()
              .trim()
              .replaceAll(',', '.'),
        )?.round() ??
        0;
  }
}

