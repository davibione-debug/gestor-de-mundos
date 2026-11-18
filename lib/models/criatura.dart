import 'item.dart';
import 'poder.dart';

class Criatura {
  // O nome é a identidade do Criatura.
  // O campo id permanece apenas para compatibilidade
  // com os pontos antigos do aplicativo que ainda passam id:.
  final String id;

  final int? numero;
  final String nome;
  final int nivel;
  final bool lendario;
  final List<String> tipos;

  final String superEfetivo;
  final String poucoEfetivo;
  final String imune;
  final String efetividadeTipo;
  final String descricao;

  final int forca;
  final int habilidade;
  final int resistencia;
  final int armadura;
  final int defesaEspecial;
  final int poderDeFogo;

  final int bonusForca;
  final int bonusHabilidade;
  final int bonusResistencia;
  final int bonusArmadura;
  final int bonusDefesaEspecial;
  final int bonusPoderDeFogo;

  final String forcaPlanilha;
  final String habilidadePlanilha;
  final String resistenciaPlanilha;
  final String armaduraPlanilha;
  final String defesaEspecialPlanilha;
  final String poderDeFogoPlanilha;

  final bool valoresPlanilhaFixos;

  final List<String> moves;

  final int pontosMoveProgressao;

  final List<Poder> poderes;

  // Pontos iniciais disponíveis para Moves.
  // Não fazem parte da progressão.
  int get pontosMoveIniciais => lendario ? 5 : 3;
  final int poderesExtras;

  final int pv;
  final int pe;

  final Item? itemComum;
  final Item? itemEquipado;
  final Item? itemRaro;
  final String localizacao;

  Criatura({
    String? id,
    this.numero,
    required this.nome,
    this.nivel = 1,
    this.lendario = false,
    required this.tipos,
    this.superEfetivo = '',
    this.poucoEfetivo = '',
    this.imune = '',
    this.efetividadeTipo = '',
    this.descricao = '',
    required this.forca,
    required this.habilidade,
    required this.resistencia,
    required this.armadura,
    required this.defesaEspecial,
    required this.poderDeFogo,
    this.bonusForca = 0,
    this.bonusHabilidade = 0,
    this.bonusResistencia = 0,
    this.bonusArmadura = 0,
    this.bonusDefesaEspecial = 0,
    this.bonusPoderDeFogo = 0,
    this.forcaPlanilha = '',
    this.habilidadePlanilha = '',
    this.resistenciaPlanilha = '',
    this.armaduraPlanilha = '',
    this.defesaEspecialPlanilha = '',
    this.poderDeFogoPlanilha = '',
    this.valoresPlanilhaFixos = false,
    this.moves = const [],
    this.pontosMoveProgressao = 0,
    required this.poderes,
    this.poderesExtras = 0,
    this.pv = 0,
    this.pe = 0,
    this.itemComum,
    this.itemEquipado,
    this.itemRaro,
    this.localizacao = '',
  }) : id = nome;

  Criatura comNivel(
    int novoNivel, {
    bool valoresPlanilhaFixos = false,
  }) {
    return Criatura(
      id: nome,
      numero: numero,
      nome: nome,
      nivel: novoNivel,
      lendario: lendario,
      tipos: List<String>.from(tipos),
      superEfetivo: superEfetivo,
      poucoEfetivo: poucoEfetivo,
      imune: imune,
      efetividadeTipo: efetividadeTipo,
      descricao: descricao,
      forca: forca,
      habilidade: habilidade,
      resistencia: resistencia,
      armadura: armadura,
      defesaEspecial: defesaEspecial,
      poderDeFogo: poderDeFogo,
      bonusForca: bonusForca,
      bonusHabilidade: bonusHabilidade,
      bonusResistencia: bonusResistencia,
      bonusArmadura: bonusArmadura,
      bonusDefesaEspecial: bonusDefesaEspecial,
      bonusPoderDeFogo: bonusPoderDeFogo,
      forcaPlanilha: forcaPlanilha,
      habilidadePlanilha: habilidadePlanilha,
      resistenciaPlanilha: resistenciaPlanilha,
      armaduraPlanilha: armaduraPlanilha,
      defesaEspecialPlanilha: defesaEspecialPlanilha,
      poderDeFogoPlanilha: poderDeFogoPlanilha,
      valoresPlanilhaFixos: valoresPlanilhaFixos,
      moves: List<String>.from(moves),
      pontosMoveProgressao: pontosMoveProgressao,
      poderes: List<Poder>.from(poderes),
      poderesExtras: poderesExtras,
      pv: pv,
      pe: pe,
      localizacao: localizacao,
      itemComum: itemComum,
      itemEquipado: itemEquipado,
      itemRaro: itemRaro,
    );
  }

  int get valorForca => forca + bonusForca;
  int get valorHabilidade => habilidade + bonusHabilidade;
  int get valorResistencia => resistencia + bonusResistencia;
  int get valorArmadura => armadura + bonusArmadura;
  int get valorDefesaEspecial => defesaEspecial + bonusDefesaEspecial;
  int get valorPoderDeFogo => poderDeFogo + bonusPoderDeFogo;

  String atributoTexto(
    int base,
    int bonus, {
    String valorPlanilha = '',
  }) {
    if (valoresPlanilhaFixos && valorPlanilha.trim().isNotEmpty) {
      return valorPlanilha.trim();
    }

    if (bonus > 0) {
      return '$base (+$bonus)';
    }

    return '$base';
  }

  String get forcaTexto => atributoTexto(
        forca,
        bonusForca,
        valorPlanilha: forcaPlanilha,
      );

  String get habilidadeTexto => atributoTexto(
        habilidade,
        bonusHabilidade,
        valorPlanilha: habilidadePlanilha,
      );

  String get resistenciaTexto => atributoTexto(
        resistencia,
        bonusResistencia,
        valorPlanilha: resistenciaPlanilha,
      );

  String get armaduraTexto => atributoTexto(
        armadura,
        bonusArmadura,
        valorPlanilha: armaduraPlanilha,
      );

  String get defesaEspecialTexto => atributoTexto(
        defesaEspecial,
        bonusDefesaEspecial,
        valorPlanilha: defesaEspecialPlanilha,
      );

  String get poderDeFogoTexto => atributoTexto(
        poderDeFogo,
        bonusPoderDeFogo,
        valorPlanilha: poderDeFogoPlanilha,
      );

  String get textoMoves {
    if (moves.isEmpty) {
      return '—';
    }

    return moves.join(' • ');
  }


  Criatura comStatsCalculados() {
    final pvCalculado = (resistencia + bonusResistencia) * 5;
    final peCalculado = poderes.fold(0, (soma, p) {
      final ehTipoUnico = tipos.length == 1;
      final mesmoTipo = ehTipoUnico && tipos.first.trim().toLowerCase() == p.tipo.trim().toLowerCase();
      final valorPoder = p.valorBase + p.bonus;
      return soma + (mesmoTipo ? valorPoder * 2 : valorPoder);
    });

    return Criatura(
      id: id,
      numero: numero,
      nome: nome,
      nivel: nivel,
      lendario: lendario,
      tipos: tipos,
      superEfetivo: superEfetivo,
      poucoEfetivo: poucoEfetivo,
      imune: imune,
      efetividadeTipo: efetividadeTipo,
      descricao: descricao,
      forca: forca,
      habilidade: habilidade,
      resistencia: resistencia,
      armadura: armadura,
      defesaEspecial: defesaEspecial,
      poderDeFogo: poderDeFogo,
      bonusForca: bonusForca,
      bonusHabilidade: bonusHabilidade,
      bonusResistencia: bonusResistencia,
      bonusArmadura: bonusArmadura,
      bonusDefesaEspecial: bonusDefesaEspecial,
      bonusPoderDeFogo: bonusPoderDeFogo,
      forcaPlanilha: forcaPlanilha,
      habilidadePlanilha: habilidadePlanilha,
      resistenciaPlanilha: resistenciaPlanilha,
      armaduraPlanilha: armaduraPlanilha,
      defesaEspecialPlanilha: defesaEspecialPlanilha,
      poderDeFogoPlanilha: poderDeFogoPlanilha,
      valoresPlanilhaFixos: valoresPlanilhaFixos,
      moves: moves,
      pontosMoveProgressao: pontosMoveProgressao,
      poderes: poderes,
      poderesExtras: poderesExtras,
      pv: pvCalculado,
      pe: peCalculado,
      itemComum: itemComum,
      itemEquipado: itemEquipado,
      itemRaro: itemRaro,
      localizacao: localizacao,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': nome,
      'numero': numero,
      'nome': nome,
      'nivel': nivel,
      'lendario': lendario,
      'tipos': tipos,
      'superEfetivo': superEfetivo,
      'poucoEfetivo': poucoEfetivo,
      'imune': imune,
      'efetividadeTipo': efetividadeTipo,
      'descricao': descricao,
      'forca': forca,
      'habilidade': habilidade,
      'resistencia': resistencia,
      'armadura': armadura,
      'defesaEspecial': defesaEspecial,
      'poderDeFogo': poderDeFogo,
      'bonusForca': bonusForca,
      'bonusHabilidade': bonusHabilidade,
      'bonusResistencia': bonusResistencia,
      'bonusArmadura': bonusArmadura,
      'bonusDefesaEspecial': bonusDefesaEspecial,
      'bonusPoderDeFogo': bonusPoderDeFogo,
      'forcaPlanilha': forcaPlanilha,
      'habilidadePlanilha': habilidadePlanilha,
      'resistenciaPlanilha': resistenciaPlanilha,
      'armaduraPlanilha': armaduraPlanilha,
      'defesaEspecialPlanilha': defesaEspecialPlanilha,
      'poderDeFogoPlanilha': poderDeFogoPlanilha,
      'moves': moves,
      'pontosMoveProgressao': pontosMoveProgressao,
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
      'pe': pe,
      'itemComum': itemComum?.toMap(),
      'itemEquipado': itemEquipado?.toMap(),
      'itemRaro': itemRaro?.toMap(),
      'localizacao': localizacao,
    };
  }

  factory Criatura.fromMap(Map<String, dynamic> map) {
    final poderesRaw = map['poderes'];

    final poderes = poderesRaw is List
        ? poderesRaw.whereType<Map>().map((poderMap) {
            final dados = Map<String, dynamic>.from(poderMap);

            return Poder(
              tipo: dados['tipo']?.toString() ?? '',
              valorBase: _int(dados['valorBase']),
              bonus: _int(dados['bonus']),
              original: _bool(dados['original']),
            );
          }).toList()
        : <Poder>[];

    final tiposRaw = map['tipos'];

    final tipos = tiposRaw is List
        ? tiposRaw.map((tipo) => tipo.toString()).toList()
        : <String>[];

    final movesRaw = map['moves'];

    final moves = movesRaw is List
        ? movesRaw
            .map((move) => move.toString().trim())
            .where((move) => move.isNotEmpty)
            .toList()
        : <String>[];

    final forca = _int(map['forca']);
    final habilidade = _int(map['habilidade']);
    final resistencia = _int(map['resistencia']);
    final armadura = _int(map['armadura']);
    final defesaEspecial = _int(map['defesaEspecial']);
    final poderDeFogo = _int(map['poderDeFogo']);

    return Criatura(
      id: map['nome']?.toString() ?? map['id']?.toString() ?? '',
      numero: _numero(map['numero']),
      nome: map['nome']?.toString() ?? map['id']?.toString() ?? '',
      nivel: _int(map['nivel'], padrao: 1),
      lendario: _bool(map['lendario']),
      tipos: tipos,
      superEfetivo: map['superEfetivo']?.toString() ?? '',
      poucoEfetivo: map['poucoEfetivo']?.toString() ?? '',
      imune: map['imune']?.toString() ?? '',
      efetividadeTipo: map['efetividadeTipo']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      forca: forca,
      habilidade: habilidade,
      resistencia: resistencia,
      armadura: armadura,
      defesaEspecial: defesaEspecial,
      poderDeFogo: poderDeFogo,
      bonusForca: _int(map['bonusForca']),
      bonusHabilidade: _int(map['bonusHabilidade']),
      bonusResistencia: _int(map['bonusResistencia']),
      bonusArmadura: _int(map['bonusArmadura']),
      bonusDefesaEspecial: _int(map['bonusDefesaEspecial']),
      bonusPoderDeFogo: _int(map['bonusPoderDeFogo']),
      forcaPlanilha: _textoPlanilha(map['forcaPlanilha'], forca),
      habilidadePlanilha: _textoPlanilha(
        map['habilidadePlanilha'],
        habilidade,
      ),
      resistenciaPlanilha: _textoPlanilha(
        map['resistenciaPlanilha'],
        resistencia,
      ),
      armaduraPlanilha: _textoPlanilha(
        map['armaduraPlanilha'],
        armadura,
      ),
      defesaEspecialPlanilha: _textoPlanilha(
        map['defesaEspecialPlanilha'],
        defesaEspecial,
      ),
      poderDeFogoPlanilha: _textoPlanilha(
        map['poderDeFogoPlanilha'],
        poderDeFogo,
      ),
      moves: moves,
      pontosMoveProgressao: _int(map['pontosMoveProgressao']),
      poderes: poderes,
      poderesExtras: _int(map['poderesExtras']),
      pv: _int(map['pv']),
      pe: _int(map['pe']),
      localizacao: map['localizacao']?.toString() ?? '',
      itemComum: _itemFromMap(map['itemComum']),
      itemEquipado: _itemFromMap(map['itemEquipado']),
      itemRaro: _itemFromMap(map['itemRaro']),
    );
  }

  static int? _numero(dynamic valor) {
    if (valor == null) {
      return null;
    }

    if (valor is int) {
      return valor;
    }

    if (valor is num) {
      return valor.round();
    }

    final texto = valor.toString().trim();

    if (texto.isEmpty) {
      return null;
    }

    return int.tryParse(texto);
  }

  static String _textoPlanilha(
    dynamic valor,
    int fallback,
  ) {
    final texto = valor?.toString().trim() ?? '';

    if (texto.isNotEmpty) {
      return texto;
    }

    return fallback.toString();
  }

  static int _int(
    dynamic valor, {
    int padrao = 0,
  }) {
    if (valor == null) return padrao;
    if (valor is int) return valor;
    if (valor is num) return valor.round();

    final texto = valor.toString().trim();

    if (texto.isEmpty) return padrao;

    return double.tryParse(
          texto.replaceAll(',', '.'),
        )?.round() ??
        padrao;
  }

  static bool _bool(dynamic valor) {
    final texto = valor?.toString().trim().toLowerCase() ?? '';

    return valor == true ||
        texto == 'true' ||
        texto == 'sim' ||
        texto == 's' ||
        texto == '1';
  }

  static Item? _itemFromMap(dynamic valor) {
    if (valor is! Map) return null;
    try {
      return Item.fromMap(Map<String, dynamic>.from(valor));
    } catch (_) {
      return null;
    }
  }
}




