import 'encontro.dart';
import 'encontro_npc.dart';
import 'evento.dart';
import 'grupo.dart';
import 'grupo_npc.dart';
import 'item.dart';
import 'npc.dart';
import 'periodo_dia.dart';
import 'criatura.dart';
import 'ponto_interesse.dart';

class Local {
  final String id;
  final String regiaoId;
  final String nome;
  final String descricao;

  final int leguas;
  final String terreno;

  final int nivelMinPokemon;
  final int nivelMaxPokemon;

  final String dadoEncontro;
  final String dadoEncontroDiurno;
  final String dadoEncontroNoturno;
  final String dadoEncontroPesca;
  final String dadoEncontroSurfe;

  final String dadoEventos;

  final Grupo encontros;

  final GrupoNPC treinadores;
  final GrupoNPC rockets;

  final List<PontoInteresse> pontosInteresse;
  final List<Evento> eventos;
  final List<Item> itens;

  final List<dynamic> conexoes;

  const Local({
    required this.id,
    required this.regiaoId,
    required this.nome,
    required this.descricao,
    required this.leguas,
    required this.terreno,
    this.nivelMinPokemon = 0,
    this.nivelMaxPokemon = 0,
    this.dadoEncontro = '',
    this.dadoEncontroDiurno = '',
    this.dadoEncontroNoturno = '',
    this.dadoEncontroPesca = '',
    this.dadoEncontroSurfe = '',
    this.dadoEventos = '',
    required this.encontros,
    this.treinadores = const GrupoNPC(),
    this.rockets = const GrupoNPC(),
    this.pontosInteresse = const [],
    this.eventos = const [],
    this.itens = const [],
    this.conexoes = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'regiaoId': regiaoId,
      'nome': nome,
      'descricao': descricao,
      'leguas': leguas,
      'terreno': terreno,
      'nivelMinPokemon': nivelMinPokemon,
      'nivelMaxPokemon': nivelMaxPokemon,
      'dadoEncontro': dadoEncontro,
      'dadoEncontroDiurno': dadoEncontroDiurno,
      'dadoEncontroNoturno': dadoEncontroNoturno,
      'dadoEncontroPesca': dadoEncontroPesca,
      'dadoEncontroSurfe': dadoEncontroSurfe,
      'dadoEventos': dadoEventos,
      'encontros': {
        'id': encontros.id,
        'nome': encontros.nome,
        'diurno': encontros.diurno.map(_encontroToMap).toList(),
        'noturno': encontros.noturno.map(_encontroToMap).toList(),
        'pesca': encontros.pesca.map(_encontroToMap).toList(),
        'surfe': encontros.surfe.map(_encontroToMap).toList(),
      },
      'treinadores': {
        'diurno': treinadores.diurno.map(_encontroNPCToMap).toList(),
        'noturno': treinadores.noturno.map(_encontroNPCToMap).toList(),
        'pesca': treinadores.pesca.map(_encontroNPCToMap).toList(),
        'surfe': treinadores.surfe.map(_encontroNPCToMap).toList(),
      },
      'rockets': {
        'diurno': rockets.diurno.map(_encontroNPCToMap).toList(),
        'noturno': rockets.noturno.map(_encontroNPCToMap).toList(),
        'pesca': rockets.pesca.map(_encontroNPCToMap).toList(),
        'surfe': rockets.surfe.map(_encontroNPCToMap).toList(),
      },
      'pontosInteresse': pontosInteresse.map(_pontoInteresseToMap).toList(),
      'eventos': eventos.map((evento) => evento.toMap()).toList(),
      'itens': itens.map((item) => item.toMap()).toList(),
      'conexoes': List<dynamic>.from(conexoes),
    };
  }

  factory Local.fromMap(Map<String, dynamic> mapa) {
    final dadoDiurno = mapa['dadoEncontroDiurno']?.toString() ??
        mapa['dadoEncontro']?.toString() ??
        '';

    return Local(
      id: mapa['id']?.toString() ?? '',
      regiaoId: mapa['regiaoId']?.toString() ?? '',
      nome: mapa['nome']?.toString() ?? '',
      descricao: mapa['descricao']?.toString() ?? '',
      leguas: _int(mapa['leguas']),
      terreno: mapa['terreno']?.toString() ?? '',
      nivelMinPokemon: _int(mapa['nivelMinPokemon']),
      nivelMaxPokemon: _int(mapa['nivelMaxPokemon']),
      dadoEncontro: dadoDiurno,
      dadoEncontroDiurno: dadoDiurno,
      dadoEncontroNoturno: mapa['dadoEncontroNoturno']?.toString() ?? '',
      dadoEncontroPesca: mapa['dadoEncontroPesca']?.toString() ?? '',
      dadoEncontroSurfe: mapa['dadoEncontroSurfe']?.toString() ?? '',
      dadoEventos: mapa['dadoEventos']?.toString() ?? '',
      encontros: _grupoFromMap(mapa['encontros']),
      treinadores: _grupoNPCFromMap(mapa['treinadores']),
      rockets: _grupoNPCFromMap(mapa['rockets']),
      pontosInteresse: _pontosInteresseFromList(
        mapa['pontosInteresse'],
      ),
      eventos: _eventosFromList(mapa['eventos']),
      itens: _itensFromList(mapa['itens']),
      conexoes: mapa['conexoes'] is List
          ? List<dynamic>.from(mapa['conexoes'] as List)
          : _listaStrings(mapa['conexoes']),
    );
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

    final mapa = Map<String, dynamic>.from(valor);

    return Grupo(
      id: mapa['id']?.toString() ?? '',
      nome: mapa['nome']?.toString() ?? '',
      diurno: _encontrosFromList(mapa['diurno']),
      noturno: _encontrosFromList(mapa['noturno']),
      pesca: _encontrosFromList(mapa['pesca']),
      surfe: _encontrosFromList(mapa['surfe']),
    );
  }

  static List<Encontro> _encontrosFromList(
    dynamic valor,
  ) {
    if (valor is! List) {
      return [];
    }

    return valor
        .whereType<Map>()
        .map(
          (item) => _encontroFromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static Encontro _encontroFromMap(
    Map<String, dynamic> mapa,
  ) {
    PeriodoDia? periodo;

    final periodoTexto = mapa['periodo']?.toString();

    if (periodoTexto != null && periodoTexto.isNotEmpty) {
      periodo = _periodoFromString(periodoTexto);
    }

    final criaturaMap = mapa['criatura'];

    final criatura = criaturaMap is Map
        ? Criatura.fromMap(
            Map<String, dynamic>.from(
              criaturaMap,
            ),
          )
        : Criatura(
            id: '',
            numero: 0,
            nome: '',
            tipos: [],
            forca: 0,
            habilidade: 0,
            resistencia: 0,
            armadura: 0,
            defesaEspecial: 0,
            poderDeFogo: 0,
            poderes: [],
          );

    return Encontro(
      criatura: criatura,
      condicao: mapa['condicao']?.toString() ?? '',
      raro: mapa['raro'] == true || mapa['raro']?.toString() == 'true',
      periodo: periodo,
      leguaMin: _nullableInt(mapa['leguaMin']),
      leguaMax: _nullableInt(mapa['leguaMax']),
      nivelFixo: _nullableInt(mapa['nivelFixo']),
    );
  }

  static GrupoNPC _grupoNPCFromMap(
    dynamic valor,
  ) {
    if (valor is! Map) {
      return const GrupoNPC();
    }

    final mapa = Map<String, dynamic>.from(valor);

    return GrupoNPC(
      diurno: _encontrosNPCFromList(
        mapa['diurno'],
      ),
      noturno: _encontrosNPCFromList(
        mapa['noturno'],
      ),
      pesca: _encontrosNPCFromList(
        mapa['pesca'],
      ),
      surfe: _encontrosNPCFromList(
        mapa['surfe'],
      ),
    );
  }

  static List<EncontroNPC> _encontrosNPCFromList(
    dynamic valor,
  ) {
    if (valor is! List) {
      return [];
    }

    return valor
        .whereType<Map>()
        .map(
          (item) => _encontroNPCFromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static EncontroNPC _encontroNPCFromMap(
    Map<String, dynamic> mapa,
  ) {
    final npcMap = mapa['npc'];

    final npc = npcMap is Map
        ? NPC.fromMap(
            Map<String, dynamic>.from(
              npcMap,
            ),
          )
        : const NPC(
            id: '',
            nome: '',
            descricao: '',
          );

    return EncontroNPC(
      npc: npc,
      raro: mapa['raro'] == true || mapa['raro']?.toString() == 'true',
      periodo: _periodoFromString(
        mapa['periodo']?.toString(),
      ),
      leguaMin: _nullableInt(mapa['leguaMin']),
      leguaMax: _nullableInt(mapa['leguaMax']),
    );
  }

  static List<Evento> _eventosFromList(
    dynamic valor,
  ) {
    if (valor is! List) {
      return [];
    }

    return valor
        .whereType<Map>()
        .map(
          (item) => Evento.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static Map<String, dynamic> _pontoInteresseToMap(
    PontoInteresse ponto,
  ) {
    return {
      'id': ponto.id,
      'nome': ponto.nome,
      'descricao': ponto.descricao,
      'localizacao': ponto.localizacao,
      'localizacaoTipo': ponto.localizacaoTipo,
      'localizacaoId': ponto.localizacaoId,
      'leguas': ponto.leguas,
      'eventos': ponto.eventos.map((evento) => evento.toMap()).toList(),
      'npcs': ponto.npcs.map((npc) => npc.toMap()).toList(),
      'criaturas': ponto.criaturas.map((criatura) => criatura.toMap()).toList(),
      'nivelCriatura': ponto.nivelCriatura,
      'itens': ponto.itens.map((item) => item.toMap()).toList(),
      'cadastroBaseId': ponto.cadastroBaseId,
      'encontros': ponto.encontros
          .map((grupo) => {
                'id': grupo.id,
                'nome': grupo.nome,
                'diurno': grupo.diurno.map(_encontroToMap).toList(),
                'noturno': grupo.noturno.map(_encontroToMap).toList(),
                'pesca': grupo.pesca.map(_encontroToMap).toList(),
                'surfe': grupo.surfe.map(_encontroToMap).toList(),
              })
          .toList(),
    };
  }

  static List<PontoInteresse> _pontosInteresseFromList(
    dynamic valor,
  ) {
    if (valor is! List) {
      return [];
    }

    return valor
        .whereType<Map>()
        .map(
          (item) => _pontoInteresseFromMap(
            Map<String, dynamic>.from(
              item,
            ),
          ),
        )
        .toList();
  }

  static PontoInteresse _pontoInteresseFromMap(
    Map<String, dynamic> mapa,
  ) {
    final eventos = _eventosFromList(
      mapa['eventos'],
    );

    final npcsRaw = mapa['npcs'];

    final npcs = npcsRaw is List
        ? npcsRaw
            .whereType<Map>()
            .map(
              (item) => NPC.fromMap(
                Map<String, dynamic>.from(
                  item,
                ),
              ),
            )
            .toList()
        : <NPC>[];

    final criaturasRaw = mapa['criaturas'];

    final criaturas = criaturasRaw is List
        ? criaturasRaw
            .whereType<Map>()
            .map((item) => Criatura.fromMap(
                  Map<String, dynamic>.from(
                    item,
                  ),
                ))
            .toList()
        : <Criatura>[];

    final itensRaw = mapa['itens'];

    final itens = itensRaw is List
        ? itensRaw
            .whereType<Map>()
            .map((item) => Item.fromMap(
                  Map<String, dynamic>.from(
                    item,
                  ),
                ))
            .toList()
        : <Item>[];

    return PontoInteresse(
      id: mapa['id']?.toString() ?? '',
      nome: mapa['nome']?.toString() ?? '',
      descricao: mapa['descricao']?.toString() ?? '',
      localizacao: mapa['localizacao']?.toString() ?? '',
      localizacaoTipo:
          mapa['localizacaoTipo']?.toString().trim().isNotEmpty == true
              ? mapa['localizacaoTipo'].toString()
              : 'nenhuma',
      localizacaoId: mapa['localizacaoId']?.toString() ?? '',
      leguas: _int(mapa['leguas']),
      eventos: eventos,
      npcs: npcs,
      criaturas: criaturas,
      nivelCriatura: mapa['nivelCriatura']?.toString() ?? '',
      itens: itens,
      cadastroBaseId: mapa['cadastroBaseId']?.toString(),
      encontros: (mapa['encontros'] is List
          ? (mapa['encontros'] as List).whereType<Map>().map((item) {
              final grupo = Map<String, dynamic>.from(item);
              return Grupo(
                  id: grupo['id']?.toString() ?? '',
                  nome: grupo['nome']?.toString() ?? '',
                  diurno: _encontrosFromList(grupo['diurno']),
                  noturno: _encontrosFromList(grupo['noturno']),
                  pesca: _encontrosFromList(grupo['pesca']),
                  surfe: _encontrosFromList(grupo['surfe']));
            }).toList()
          : <Grupo>[]),
    );
  }

  static PeriodoDia? _periodoFromString(
    String? valor,
  ) {
    if (valor == null || valor.isEmpty) {
      return null;
    }

    final normalizado = valor.trim().toLowerCase();

    for (final periodo in PeriodoDia.values) {
      if (periodo.name.toLowerCase() == normalizado) {
        return periodo;
      }

      if (periodo.texto.toLowerCase() == normalizado) {
        return periodo;
      }
    }

    return null;
  }

  static Map<String, dynamic> _encontroToMap(
    Encontro encontro,
  ) {
    return {
      'criatura': encontro.criatura.toMap(),
      'condicao': encontro.condicao,
      'raro': encontro.raro,
      'periodo': encontro.periodo?.name,
      'leguaMin': encontro.leguaMin,
      'leguaMax': encontro.leguaMax,
      'nivelFixo': encontro.nivelFixo,
    };
  }

  static Map<String, dynamic> _encontroNPCToMap(
    EncontroNPC encontro,
  ) {
    return {
      'npc': encontro.npc.toMap(),
      'raro': encontro.raro,
      'periodo': encontro.periodo?.name,
      'leguaMin': encontro.leguaMin,
      'leguaMax': encontro.leguaMax,
    };
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

  static List<String> _listaStrings(
    dynamic valor,
  ) {
    if (valor is List) {
      return valor
          .map(
            (item) => item.toString().trim(),
          )
          .where(
            (item) => item.isNotEmpty,
          )
          .toList();
    }

    if (valor == null) {
      return [];
    }

    final texto = valor.toString().trim();

    if (texto.isEmpty || texto == '-') {
      return [];
    }

    return texto
        .split(',')
        .map(
          (item) => item.trim(),
        )
        .where(
          (item) => item.isNotEmpty,
        )
        .toList();
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

    final texto = valor.toString().trim();

    if (texto.isEmpty) {
      return 0;
    }

    return double.tryParse(
          texto.replaceAll(',', '.'),
        )?.round() ??
        0;
  }

  static int? _nullableInt(
    dynamic valor,
  ) {
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

    if (texto.isEmpty || texto == '-') {
      return null;
    }

    return int.tryParse(texto);
  }
}
