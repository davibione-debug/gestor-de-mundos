import 'evento.dart';
import 'encontro.dart';
import 'encontro_npc.dart';
import 'periodo_dia.dart';
import 'grupo.dart';
import 'grupo_npc.dart';
import 'item.dart';
import 'npc.dart';
import 'criatura.dart';

class PontoInteresse {
  final String id;
  final String nome;
  final String descricao;

  final String efeitos;
  // Identifica o cadastro-base do Mapa do qual esta cópia se originou.
  // Cadastro-base possui null.
  final String? cadastroBaseId;

  // Mantidos para compatibilidade com dados antigos.
  final String localizacao;
  final String localizacaoTipo;
  final String localizacaoId;
  final int leguas;

  final int nivelMinCriatura;
  final int nivelMaxCriatura;

  final List<Evento> eventos;
  final List<NPC> npcs;
  final List<NPC> aliados;
  final List<NPC> inimigos;
  final String dadoEncontros;
  final String dadoEventos;
  final List<Criatura> criaturas;
  final String nivelCriatura;
  final List<Item> itens;
  final List<Grupo> encontros;

  // Encontros proprios do Ponto de Interesse (independentes do Local).
  final Grupo encontrosCriaturas;
  final GrupoNPC encontrosAliados;
  final GrupoNPC encontrosInimigos;

  const PontoInteresse({
    required this.id,
    required this.nome,
    required this.descricao,
    this.efeitos = '',
    this.cadastroBaseId,
    this.localizacao = '',
    this.localizacaoTipo = 'nenhuma',
    this.localizacaoId = '',
    this.leguas = 0,
    this.nivelMinCriatura = 0,
    this.nivelMaxCriatura = 0,
    this.eventos = const [],
    this.npcs = const [],
    this.aliados = const [],
    this.inimigos = const [],
    this.dadoEncontros = '',
    this.dadoEventos = '',
    this.criaturas = const [],
    this.nivelCriatura = '',
    this.itens = const [],
    this.encontros = const [],
    this.encontrosCriaturas = const Grupo(
      id: '',
      nome: '',
      diurno: [],
      noturno: [],
      pesca: [],
      surfe: [],
    ),
    this.encontrosAliados = const GrupoNPC(),
    this.encontrosInimigos = const GrupoNPC(),
  });

  PontoInteresse copyWith({
    String? id,
    String? nome,
    String? descricao,
    String? efeitos,
    String? cadastroBaseId,
    String? localizacao,
    String? localizacaoTipo,
    String? localizacaoId,
    int? leguas,
    int? nivelMinCriatura,
    int? nivelMaxCriatura,
    List<Evento>? eventos,
    List<NPC>? npcs,
    List<NPC>? aliados,
    List<NPC>? inimigos,
    String? dadoEncontros,
    String? dadoEventos,
    List<Criatura>? criaturas,
    String? nivelCriatura,
    List<Item>? itens,
    List<Grupo>? encontros,
    Grupo? encontrosCriaturas,
    GrupoNPC? encontrosAliados,
    GrupoNPC? encontrosInimigos,
  }) {
    return PontoInteresse(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      efeitos: efeitos ?? this.efeitos,
      cadastroBaseId: cadastroBaseId ?? this.cadastroBaseId,
      localizacao: localizacao ?? this.localizacao,
      localizacaoTipo: localizacaoTipo ?? this.localizacaoTipo,
      localizacaoId: localizacaoId ?? this.localizacaoId,
      leguas: leguas ?? this.leguas,
      nivelMinCriatura: nivelMinCriatura ?? this.nivelMinCriatura,
      nivelMaxCriatura: nivelMaxCriatura ?? this.nivelMaxCriatura,
      eventos: eventos ?? this.eventos,
      npcs: npcs ?? this.npcs,
      aliados: aliados ?? this.aliados,
      inimigos: inimigos ?? this.inimigos,
      dadoEncontros: dadoEncontros ?? this.dadoEncontros,
      dadoEventos: dadoEventos ?? this.dadoEventos,
      criaturas: criaturas ?? this.criaturas,
      nivelCriatura: nivelCriatura ?? this.nivelCriatura,
      itens: itens ?? this.itens,
      encontros: encontros ?? this.encontros,
      encontrosCriaturas: encontrosCriaturas ?? this.encontrosCriaturas,
      encontrosAliados: encontrosAliados ?? this.encontrosAliados,
      encontrosInimigos: encontrosInimigos ?? this.encontrosInimigos,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'efeitos': efeitos,
      'cadastroBaseId': cadastroBaseId,
      'localizacao': localizacao,
      'localizacaoTipo': localizacaoTipo,
      'localizacaoId': localizacaoId,
      'leguas': leguas,
      'nivelMinCriatura': nivelMinCriatura,
      'nivelMaxCriatura': nivelMaxCriatura,
      'eventos': eventos.map((evento) => evento.toMap()).toList(),
      'npcs': npcs.map((npc) => npc.toMap()).toList(),
      'aliados': aliados.map((npc) => npc.toMap()).toList(),
      'inimigos': inimigos.map((npc) => npc.toMap()).toList(),
      'dadoEncontros': dadoEncontros,
      'dadoEventos': dadoEventos,
      'criaturas': criaturas.map((criatura) => criatura.toMap()).toList(),
      'nivelCriatura': nivelCriatura,
      'itens': itens.map((item) => item.toMap()).toList(),
      'encontros': encontros
          .map((grupo) => {
                'id': grupo.id,
                'nome': grupo.nome,
                'diurno': grupo.diurno
                    .map((e) => {
                          'criatura': e.criatura.toMap(),
                          'condicao': e.condicao,
                          'raro': e.raro,
                          'periodo': e.periodo?.name,
                          'leguaMin': e.leguaMin,
                          'leguaMax': e.leguaMax,
                          'nivelFixo': e.nivelFixo,
                          'fichaFixada': e.fichaFixada
                        })
                    .toList(),
                'noturno': grupo.noturno
                    .map((e) => {
                          'criatura': e.criatura.toMap(),
                          'condicao': e.condicao,
                          'raro': e.raro,
                          'periodo': e.periodo?.name,
                          'leguaMin': e.leguaMin,
                          'leguaMax': e.leguaMax,
                          'nivelFixo': e.nivelFixo,
                          'fichaFixada': e.fichaFixada
                        })
                    .toList(),
                'pesca': grupo.pesca
                    .map((e) => {
                          'criatura': e.criatura.toMap(),
                          'condicao': e.condicao,
                          'raro': e.raro,
                          'periodo': e.periodo?.name,
                          'leguaMin': e.leguaMin,
                          'leguaMax': e.leguaMax,
                          'nivelFixo': e.nivelFixo,
                          'fichaFixada': e.fichaFixada
                        })
                    .toList(),
                'surfe': grupo.surfe
                    .map((e) => {
                          'criatura': e.criatura.toMap(),
                          'condicao': e.condicao,
                          'raro': e.raro,
                          'periodo': e.periodo?.name,
                          'leguaMin': e.leguaMin,
                          'leguaMax': e.leguaMax,
                          'nivelFixo': e.nivelFixo,
                          'fichaFixada': e.fichaFixada
                        })
                    .toList(),
              })
          .toList(),
      'encontrosCriaturas': {
        'id': encontrosCriaturas.id,
        'nome': encontrosCriaturas.nome,
        'diurno': encontrosCriaturas.diurno.map(_encontroToMap).toList(),
        'noturno': encontrosCriaturas.noturno.map(_encontroToMap).toList(),
        'pesca': encontrosCriaturas.pesca.map(_encontroToMap).toList(),
        'surfe': encontrosCriaturas.surfe.map(_encontroToMap).toList(),
      },
      'encontrosAliados': {
        'diurno': encontrosAliados.diurno.map(_encontroNPCToMap).toList(),
        'noturno': encontrosAliados.noturno.map(_encontroNPCToMap).toList(),
        'pesca': encontrosAliados.pesca.map(_encontroNPCToMap).toList(),
        'surfe': encontrosAliados.surfe.map(_encontroNPCToMap).toList(),
      },
      'encontrosInimigos': {
        'diurno': encontrosInimigos.diurno.map(_encontroNPCToMap).toList(),
        'noturno': encontrosInimigos.noturno.map(_encontroNPCToMap).toList(),
        'pesca': encontrosInimigos.pesca.map(_encontroNPCToMap).toList(),
        'surfe': encontrosInimigos.surfe.map(_encontroNPCToMap).toList(),
      },    };
  }

  factory PontoInteresse.fromMap(
    Map<String, dynamic> mapa,
  ) {
    return PontoInteresse(
      id: mapa['id']?.toString() ?? '',
      nome: mapa['nome']?.toString() ?? '',
      descricao: mapa['descricao']?.toString() ?? '',
      efeitos: mapa['efeitos']?.toString() ?? '',
      cadastroBaseId: _textoNulo(mapa['cadastroBaseId']),
      localizacao: mapa['localizacao']?.toString() ?? '',
      localizacaoTipo: mapa['localizacaoTipo']?.toString().isNotEmpty == true
          ? mapa['localizacaoTipo'].toString()
          : 'nenhuma',
      localizacaoId: mapa['localizacaoId']?.toString() ?? '',
      leguas: _int(mapa['leguas']),
      nivelMinCriatura: _int(mapa['nivelMinCriatura']),
      nivelMaxCriatura: _int(mapa['nivelMaxCriatura']),
      eventos: _eventosFromList(mapa['eventos']),
      npcs: _npcsFromList(mapa['npcs']),
      aliados: _npcsFromList(mapa['aliados']),
      inimigos: _npcsFromList(mapa['inimigos']),
      dadoEncontros: mapa['dadoEncontros']?.toString() ?? '',
      dadoEventos: mapa['dadoEventos']?.toString() ?? '',
      criaturas: _criaturasFromList(mapa['criaturas']),
      nivelCriatura: mapa['nivelCriatura']?.toString() ?? '',
      itens: _itensFromList(mapa['itens']),
      encontros: _gruposFromList(mapa['encontros']),
      encontrosCriaturas: _grupoFromMap(mapa['encontrosCriaturas']),
      encontrosAliados: _grupoNPCFromMap(mapa['encontrosAliados']),
      encontrosInimigos: _grupoNPCFromMap(mapa['encontrosInimigos']),
    );
  }

  static List<Grupo> _gruposFromList(dynamic valor) {
    if (valor is! List) return [];
    return valor.whereType<Map>().map((item) {
      final mapa = Map<String, dynamic>.from(item);
      return Grupo(
        id: mapa['id']?.toString() ?? '',
        nome: mapa['nome']?.toString() ?? '',
        diurno: _encontrosFromList(mapa['diurno']),
        noturno: _encontrosFromList(mapa['noturno']),
        pesca: _encontrosFromList(mapa['pesca']),
        surfe: _encontrosFromList(mapa['surfe']),
      );
    }).toList();
  }

  static List<Encontro> _encontrosFromList(dynamic valor) {
    if (valor is! List) return [];
    return valor
        .whereType<Map>()
        .map((item) {
          final mapa = Map<String, dynamic>.from(item);
          final criaturaRaw = mapa['criatura'];
          if (criaturaRaw is! Map) return null;
          PeriodoDia? periodo;
          final textoPeriodo = mapa['periodo']?.toString();
          for (final p in PeriodoDia.values) {
            if (p.name == textoPeriodo || p.texto == textoPeriodo) {
              periodo = p;
              break;
            }
          }
          return Encontro(
            criatura: Criatura.fromMap(Map<String, dynamic>.from(criaturaRaw)),
            condicao: mapa['condicao']?.toString() ?? '',
            raro: mapa['raro'] == true || mapa['raro']?.toString() == 'true',
            periodo: periodo,
            leguaMin: _intNulo(mapa['leguaMin']),
            leguaMax: _intNulo(mapa['leguaMax']),
            nivelFixo: _intNulo(mapa['nivelFixo']),
            fichaFixada: mapa['fichaFixada'] == true,
          );
        })
        .whereType<Encontro>()
        .toList();
  }

  static int? _intNulo(dynamic valor) {
    if (valor == null) return null;
    if (valor is int) return valor;
    if (valor is num) return valor.round();
    return int.tryParse(valor.toString());
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
    if (valor is int) {
      return valor;
    }

    if (valor is num) {
      return valor.round();
    }

    return int.tryParse(
          valor?.toString().trim() ?? '',
        ) ??
        0;
  }

  static List<Evento> _eventosFromList(
    dynamic valor,
  ) {
    if (valor is! List) {
      return const [];
    }

    return valor
        .whereType<Map>()
        .map(
          (evento) => Evento.fromMap(
            Map<String, dynamic>.from(evento),
          ),
        )
        .toList();
  }

  static List<NPC> _npcsFromList(
    dynamic valor,
  ) {
    if (valor is! List) {
      return const [];
    }

    return valor
        .whereType<Map>()
        .map(
          (npc) => NPC.fromMap(
            Map<String, dynamic>.from(npc),
          ),
        )
        .toList();
  }

  static List<Criatura> _criaturasFromList(
    dynamic valor,
  ) {
    if (valor is! List) {
      return const [];
    }

    return valor
        .whereType<Map>()
        .map(
          (criatura) => Criatura.fromMap(
            Map<String, dynamic>.from(criatura),
          ),
        )
        .toList();
  }

  static List<Item> _itensFromList(
    dynamic valor,
  ) {
    if (valor is! List) {
      return const [];
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

  static Map<String, dynamic> _encontroToMap(Encontro e) {
    return {
      'criatura': e.criatura.toMap(),
      'condicao': e.condicao,
      'raro': e.raro,
      'periodo': e.periodo?.name,
      'leguaMin': e.leguaMin,
      'leguaMax': e.leguaMax,
      'nivelFixo': e.nivelFixo,
      'fichaFixada': e.fichaFixada,
    };
  }

  static Map<String, dynamic> _encontroNPCToMap(EncontroNPC e) {
    return {
      'npc': e.npc.toMap(),
      'raro': e.raro,
      'periodo': e.periodo?.name,
      'leguaMin': e.leguaMin,
      'leguaMax': e.leguaMax,
    };
  }

  static Grupo _grupoFromMap(dynamic valor) {
    if (valor is! Map) {
      return const Grupo(
        id: '',
        nome: '',
        diurno: [],
        noturno: [],
        pesca: [],
        surfe: [],
      );
    }
    final m = Map<String, dynamic>.from(valor);
    return Grupo(
      id: m['id']?.toString() ?? '',
      nome: m['nome']?.toString() ?? '',
      diurno: _encontrosFromList(m['diurno']),
      noturno: _encontrosFromList(m['noturno']),
      pesca: _encontrosFromList(m['pesca']),
      surfe: _encontrosFromList(m['surfe']),
    );
  }

  static GrupoNPC _grupoNPCFromMap(dynamic valor) {
    if (valor is! Map) {
      return const GrupoNPC();
    }
    final m = Map<String, dynamic>.from(valor);
    return GrupoNPC(
      diurno: _encontrosNPCFromList(m['diurno']),
      noturno: _encontrosNPCFromList(m['noturno']),
      pesca: _encontrosNPCFromList(m['pesca']),
      surfe: _encontrosNPCFromList(m['surfe']),
    );
  }

  static List<EncontroNPC> _encontrosNPCFromList(dynamic valor) {
    if (valor is! List) return [];
    return valor
        .whereType<Map>()
        .map((item) {
          final m = Map<String, dynamic>.from(item);
          final npcRaw = m['npc'];
          if (npcRaw is! Map) return null;
          PeriodoDia? periodo;
          final textoPeriodo = m['periodo']?.toString();
          for (final p in PeriodoDia.values) {
            if (p.name == textoPeriodo || p.texto == textoPeriodo) {
              periodo = p;
              break;
            }
          }
          return EncontroNPC(
            npc: NPC.fromMap(Map<String, dynamic>.from(npcRaw)),
            raro: m['raro'] == true || m['raro']?.toString() == 'true',
            periodo: periodo,
            leguaMin: _intNulo(m['leguaMin']),
            leguaMax: _intNulo(m['leguaMax']),
          );
        })
        .whereType<EncontroNPC>()
        .toList();
  }
}
