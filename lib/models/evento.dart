import 'item.dart';
import 'criatura.dart';

class Evento {
  final String id;
  final String nome;
  final String descricao;

  // Identifica o cadastro-base do Mapa do qual esta cópia se originou.
  // Cadastro-base possui null.
  final String? cadastroBaseId;

  // Mantidos para compatibilidade com dados antigos.
  final String localizacao;
  final String localizacaoTipo;
  final String localizacaoId;
  final int? legua;

  final String efeito;

  final String inicio;
  final String duracao;
  final List<String> aliados;
  final List<String> inimigos;
  final Criatura? criatura;
  final String nivelCriatura;
  final List<Item> itens;

  const Evento({
    required this.id,
    required this.nome,
    required this.descricao,
    this.cadastroBaseId,
    this.localizacao = '',
    this.localizacaoTipo = 'nenhuma',
    this.localizacaoId = '',
    this.legua,
    this.efeito = '',
    this.inicio = '',
    this.duracao = '',
    this.aliados = const [],
    this.inimigos = const [],
    this.criatura,
    this.nivelCriatura = '',
    this.itens = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'cadastroBaseId': cadastroBaseId,
      'localizacao': localizacao,
      'localizacaoTipo': localizacaoTipo,
      'localizacaoId': localizacaoId,
      'legua': legua,
      'efeito': efeito,
      'inicio': inicio,
      'duracao': duracao,
      'aliados': List<String>.from(aliados),
      'inimigos': List<String>.from(inimigos),
      'criatura': criatura?.toMap(),
      'nivelCriatura': nivelCriatura,
      'itens': itens.map((item) => item.toMap()).toList(),
    };
  }

  factory Evento.fromMap(Map<String, dynamic> mapa) {
    Criatura? criatura;

    final criaturaRaw = mapa['criatura'];

    if (criaturaRaw is Map) {
      criatura = Criatura.fromMap(
        Map<String, dynamic>.from(criaturaRaw),
      );
    }

    final tipo = mapa['localizacaoTipo']?.toString() ?? '';
    final localizacaoId = mapa['localizacaoId']?.toString() ?? '';
    final legua = _nullableInt(mapa['legua']);

    final cadastroBaseId = _textoNulo(mapa['cadastroBaseId']);

    return Evento(
      id: mapa['id']?.toString() ?? '',
      nome: mapa['nome']?.toString() ?? '',
      descricao: mapa['descricao']?.toString() ?? '',
      cadastroBaseId: cadastroBaseId,
      localizacao: mapa['localizacao']?.toString() ?? '',
      localizacaoTipo: tipo.isEmpty ? 'nenhuma' : tipo,
      localizacaoId: localizacaoId,
      legua: legua,
      efeito: mapa['efeito']?.toString() ?? '',
      inicio: mapa['inicio']?.toString() ?? '',
      duracao: mapa['duracao']?.toString() ?? '',
      aliados: _listaTexto(mapa['aliados'], mapa['npc']),
      inimigos: _listaTexto(mapa['inimigos']),
      criatura: criatura,
      nivelCriatura:
          mapa['nivelCriatura']?.toString() ?? criatura?.nivel.toString() ?? '',
      itens: _itensFromList(mapa['itens']),
    );
  }

  static List<String> _listaTexto(dynamic valor, [dynamic legado]) {
    if (valor is List) {
      return valor
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList();
    }

    // Mantém o valor antigo para que o editor possa tentar localizar
    // o cadastro correspondente pelo nome.
    if (legado != null && legado.toString().trim().isNotEmpty) {
      return [legado.toString().trim()];
    }

    return [];
  }

  static List<Item> _itensFromList(dynamic valor) {
    if (valor is! List) {
      return [];
    }

    return valor
        .whereType<Map>()
        .map(
          (item) => Item.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static int? _nullableInt(dynamic valor) {
    if (valor == null) {
      return null;
    }

    if (valor is int) {
      return valor;
    }

    if (valor is num) {
      return valor.round();
    }

    return int.tryParse(
      valor.toString().trim(),
    );
  }

  static String? _textoNulo(dynamic valor) {
    if (valor == null) {
      return null;
    }

    final texto = valor.toString().trim();

    if (texto.isEmpty || texto == '-') {
      return null;
    }

    return texto;
  }
}
