import 'poder.dart';
import 'item.dart';

class CriaturaTreinador {
  final String nome;

  final int nivel;

  final int bonusForca;
  final int bonusHabilidade;
  final int bonusResistencia;
  final int bonusArmadura;
  final int bonusDefesaEspecial;
  final int bonusPoderDeFogo;

  final List<Poder> poderes;
  final int poderesExtras;

  final int pv;
  final int creditos;
  final int pe;

  final List<String> moves;

  final Item? itemComum;
  final Item? itemEquipado;
  final Item? itemRaro;

  const CriaturaTreinador({
    required this.nome,
    this.nivel = 1,
    this.bonusForca = 0,
    this.bonusHabilidade = 0,
    this.bonusResistencia = 0,
    this.bonusArmadura = 0,
    this.bonusDefesaEspecial = 0,
    this.bonusPoderDeFogo = 0,
    this.poderes = const [],
    this.poderesExtras = 0,
    this.pv = 0,
    this.creditos = 0,
    this.pe = 0,
    this.moves = const [],
    this.itemComum,
    this.itemEquipado,
    this.itemRaro,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'nivel': nivel,
      'bonusForca': bonusForca,
      'bonusHabilidade': bonusHabilidade,
      'bonusResistencia': bonusResistencia,
      'bonusArmadura': bonusArmadura,
      'bonusDefesaEspecial': bonusDefesaEspecial,
      'bonusPoderDeFogo': bonusPoderDeFogo,
      'poderes': poderes.map((poder) {
        return {
          'tipo': poder.tipo,
          'valorBase': poder.valorBase,
          'bonus': poder.bonus,
          'original': poder.original,
        };
      }).toList(),
      'poderesExtras': poderesExtras,
      'pv': pv,
      'creditos': creditos,
      'pe': pe,
      'moves': moves,
      'itemComum': itemComum?.toMap(),
      'itemEquipado': itemEquipado?.toMap(),
      'itemRaro': itemRaro?.toMap(),
    };
  }

  factory CriaturaTreinador.fromMap(
    Map<String, dynamic> map,
  ) {
    final poderesRaw = map['poderes'];

    final poderes = poderesRaw is List
        ? poderesRaw.whereType<Map>().map((poderMap) {
            final dados =
                Map<String, dynamic>.from(poderMap);

            return Poder(
              tipo: dados['tipo']?.toString() ?? '',
              valorBase: _int(dados['valorBase']),
              bonus: _int(dados['bonus']),
              original: _bool(dados['original']),
            );
          }).toList()
        : <Poder>[];

    final movesRaw = map['moves'];

    final moves = movesRaw is List
        ? movesRaw
            .map(
              (move) => move.toString().trim(),
            )
            .where(
              (move) => move.isNotEmpty,
            )
            .toList()
        : <String>[];

    return CriaturaTreinador(
      nome: map['nome']?.toString() ?? '',
      nivel: _int(
        map['nivel'],
        padrao: 1,
      ),
      bonusForca:
          _int(map['bonusForca']),
      bonusHabilidade:
          _int(map['bonusHabilidade']),
      bonusResistencia:
          _int(map['bonusResistencia']),
      bonusArmadura:
          _int(map['bonusArmadura']),
      bonusDefesaEspecial:
          _int(map['bonusDefesaEspecial']),
      bonusPoderDeFogo:
          _int(map['bonusPoderDeFogo']),
      poderes: poderes,
      poderesExtras:
          _int(map['poderesExtras']),
      pv: _int(map['pv']),
      creditos: _int(map['creditos']),
      pe: _int(map['pe']),
      moves: moves,
      itemComum: _itemFromMap(map['itemComum']),
      itemEquipado: _itemFromMap(map['itemEquipado']),
      itemRaro: _itemFromMap(map['itemRaro']),
    );
  }

  static Item? _itemFromMap(dynamic valor) {
    if (valor is! Map) return null;
    try {
      return Item.fromMap(Map<String, dynamic>.from(valor));
    } catch (_) {
      return null;
    }
  }

  static int _int(
    dynamic valor, {
    int padrao = 0,
  }) {
    if (valor == null) {
      return padrao;
    }

    if (valor is int) {
      return valor;
    }

    if (valor is num) {
      return valor.round();
    }

    return double.tryParse(
          valor
              .toString()
              .trim()
              .replaceAll(',', '.'),
        )?.round() ??
        padrao;
  }

  static bool _bool(dynamic valor) {
    final texto =
        valor?.toString().trim().toLowerCase() ?? '';

    return valor == true ||
        texto == 'true' ||
        texto == 'sim' ||
        texto == 's' ||
        texto == '1';
  }
}

class NPC {
  final String id;
  final String nome;
  final String tipo;
  final String descricao;

  // Cadastro-base possui null.
  // Cópia incluída em Local possui o id do cadastro-base.
  final String? cadastroBaseId;

  final String localizacao;

  final int forca;
  final int habilidade;
  final int inteligencia;
  final int resistencia;
  final int armadura;
  final int poderDeFogo;

  final int captura;
  final int controle;
  final int compreensao;
  final int tratamento;
  final int ecologia;

  final String kit;
  final String manobras;
  final String vantagens;
  final String desvantagens;

  final List<String> criaturas;
  final List<CriaturaTreinador> fichasCriatura;

  final String nivelCriatura;
  final String inventario;

  final int pv;
  final int creditos;

  final List<Item> itens;

  const NPC({
    required this.id,
    required this.nome,
    this.tipo = '',
    required this.descricao,
    this.cadastroBaseId,
    this.localizacao = '',
    this.forca = 0,
    this.habilidade = 0,
    this.inteligencia = 0,
    this.resistencia = 0,
    this.armadura = 0,
    this.poderDeFogo = 0,
    this.captura = 0,
    this.controle = 0,
    this.compreensao = 0,
    this.tratamento = 0,
    this.ecologia = 0,
    this.kit = '',
    this.manobras = '',
    this.vantagens = '',
    this.desvantagens = '',
    this.criaturas = const [],
    this.fichasCriatura = const [],
    this.nivelCriatura = '',
    this.inventario = '',
    this.pv = 0,
    this.creditos = 0,
    this.itens = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'descricao': descricao,
      'cadastroBaseId': cadastroBaseId,
      'localizacao': localizacao,
      'forca': forca,
      'habilidade': habilidade,
      'inteligencia': inteligencia,
      'resistencia': resistencia,
      'armadura': armadura,
      'poderDeFogo': poderDeFogo,
      'captura': captura,
      'controle': controle,
      'compreensao': compreensao,
      'tratamento': tratamento,
      'ecologia': ecologia,
      'kit': kit,
      'manobras': manobras,
      'vantagens': vantagens,
      'desvantagens': desvantagens,
      'criaturas': criaturas,
      'fichasCriatura':
          fichasCriatura.map(
        (criatura) => criatura.toMap(),
      ).toList(),
      'nivelCriatura': nivelCriatura,
      'inventario': inventario,
      'pv': pv,
      'creditos': creditos,
      'itens': itens.map((item) => item.toMap()).toList(),
    };
  }

  factory NPC.fromMap(
    Map<String, dynamic> map,
  ) {
    final raw = map['criaturas'];

    final criaturas = raw is List
        ? raw
            .map(
              (criatura) => criatura.toString(),
            )
            .where(
              (criatura) =>
                  criatura.trim().isNotEmpty,
            )
            .toList()
        : <String>[];

    final itensRaw = map['itens'];

    final itens = itensRaw is List
        ? itensRaw
            .whereType<Map>()
            .map(
              (itemMap) => Item.fromMap(
                Map<String, dynamic>.from(itemMap),
              ),
            )
            .toList()
        : <Item>[];

    final fichasRaw =
        map['fichasCriatura'];

    final fichasCriatura =
        fichasRaw is List
            ? fichasRaw
                .whereType<Map>()
                .map(
                  (criaturaMap) =>
                      CriaturaTreinador.fromMap(
                    Map<String, dynamic>.from(
                      criaturaMap,
                    ),
                  ),
                )
                .toList()
            : <CriaturaTreinador>[];

    return NPC(
      id: map['id']?.toString() ?? '',
      nome: map['nome']?.toString() ?? '',
      tipo: map['tipo']?.toString() ?? '',
      descricao:
          map['descricao']?.toString() ?? '',
      cadastroBaseId:
          _textoNulo(map['cadastroBaseId']),
      localizacao:
          map['localizacao']?.toString() ?? '',
      forca: _int(map['forca']),
      habilidade: _int(map['habilidade']),
      inteligencia:
          _int(map['inteligencia']),
      resistencia:
          _int(map['resistencia']),
      armadura: _int(map['armadura']),
      poderDeFogo:
          _int(map['poderDeFogo']),
      captura: _int(map['captura']),
      controle: _int(map['controle']),
      compreensao:
          _int(map['compreensao']),
      tratamento:
          _int(map['tratamento']),
      ecologia: _int(map['ecologia']),
      kit: map['kit']?.toString() ?? '',
      manobras:
          map['manobras']?.toString() ?? '',
      vantagens:
          map['vantagens']?.toString() ?? '',
      desvantagens:
          map['desvantagens']?.toString() ?? '',
      criaturas: criaturas,
      fichasCriatura: fichasCriatura,
      itens: itens,
      nivelCriatura:
          map['nivelCriatura']?.toString() ?? '',
      inventario:
          map['inventario']?.toString() ?? '',
      pv: _int(map['pv']),
      creditos: _int(map['creditos']),
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

  static int _int(dynamic valor) {
    if (valor == null) {
      return 0;
    }

    if (valor is int) {
      return valor;
    }

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



