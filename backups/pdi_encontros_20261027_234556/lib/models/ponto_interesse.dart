import 'evento.dart';
import 'encontro.dart';
import 'periodo_dia.dart';
import 'grupo.dart';
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

  final List<Evento> eventos;
  final List<NPC> npcs;
  final List<Criatura> criaturas;
  final String nivelCriatura;
  final List<Item> itens;
  final List<Grupo> encontros;

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
    this.eventos = const [],
    this.npcs = const [],
    this.criaturas = const [],
    this.nivelCriatura = '',
    this.itens = const [],
    this.encontros = const [],
  });

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
      'eventos': eventos.map((evento) => evento.toMap()).toList(),
      'npcs': npcs.map((npc) => npc.toMap()).toList(),
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
    };
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
      eventos: _eventosFromList(mapa['eventos']),
      npcs: _npcsFromList(mapa['npcs']),
      criaturas: _criaturasFromList(mapa['criaturas']),
      nivelCriatura: mapa['nivelCriatura']?.toString() ?? '',
      itens: _itensFromList(mapa['itens']),
      encontros: _gruposFromList(mapa['encontros']),
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
}
