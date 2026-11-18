import 'package:flutter/material.dart';
import '../../models/evento.dart';
import '../../models/local.dart';
import '../../models/npc.dart';
import '../../models/ponto_interesse.dart';
import '../../repositories/cadastros_repository.dart';
import '../../repositories/locais_repository.dart';
import '../mapa/evento_screen.dart';
import '../mapa/local_screen.dart';
import '../mapa/ponto_interesse_screen.dart';

class ReferenciaLocalizacaoNPC {
  final String tipo;
  final String nome;
  final Object registro;
  final String? localId;
  final String? localNome;

  const ReferenciaLocalizacaoNPC({
    required this.tipo,
    required this.nome,
    required this.registro,
    this.localId,
    this.localNome,
  });

  String get chave {
    try {
      final dynamic item = registro;
      final id = item.id?.toString() ?? '';
      if (id.isNotEmpty) return '$tipo:$id';
    } catch (_) {}
    return '$tipo:$nome';
  }
}

bool eventoTemNPC(Evento evento, String nomeAtual) {
  bool contem(String id) {
    return id.trim().toLowerCase() == nomeAtual;
  }

  return evento.aliados.any(contem) || evento.inimigos.any(contem);
}

Future<List<ReferenciaLocalizacaoNPC>> buscarLocalizacoesDoNPC(NPC npc) async {
  final referencias = <String, ReferenciaLocalizacaoNPC>{};
  final nomeAtual = npc.nome.trim().toLowerCase();

  bool referenciaEstaNPC(dynamic referencia) {
    if (referencia == null) return false;
    if (referencia is String) return referencia.trim().toLowerCase() == nomeAtual;
    try {
      final nome = referencia.nome?.toString().trim().toLowerCase() ?? '';
      if (nome == nomeAtual) return true;
    } catch (_) {}
    try {
      final id = referencia.id?.toString().trim().toLowerCase() ?? '';
      if (id == nomeAtual) return true;
    } catch (_) {}
    return false;
  }

  String nomeRegistro(dynamic registro, [String fallback = '']) {
    try {
      final nome = registro.nome?.toString().trim() ?? '';
      if (nome.isNotEmpty) return nome;
    } catch (_) {}
    return fallback;
  }

  void adicionar(String tipo, dynamic registro, {String? localId, String? localNome}) {
    final nome = nomeRegistro(registro);
    if (nome.isEmpty) return;
    final ref = ReferenciaLocalizacaoNPC(
      tipo: tipo,
      nome: nome,
      registro: registro as Object,
      localId: localId,
      localNome: localNome,
    );
    referencias.putIfAbsent(ref.chave, () => ref);
  }

  bool grupoContemNPC(dynamic grupo) {
    if (grupo == null) return false;
    try {
      for (final periodo in [grupo.diurno, grupo.noturno, grupo.pesca, grupo.surfe]) {
        if (periodo is! Iterable) continue;
        for (final encontro in periodo) {
          try {
            if (referenciaEstaNPC(encontro.npc)) return true;
          } catch (_) {}
        }
      }
    } catch (_) {}
    return false;
  }

  final locais = await LocaisRepository().carregar();

  for (final local in locais) {
    final localId = local.id;
    var localTemReferencia = false;

    if (grupoContemNPC(local.treinadores)) localTemReferencia = true;
    if (grupoContemNPC(local.rockets)) localTemReferencia = true;

    for (final evento in local.eventos) {
      if (eventoTemNPC(evento, nomeAtual)) {
        adicionar('Evento', evento);
        localTemReferencia = true;
      }
    }

    for (final ponto in local.pontosInteresse) {
      for (final npcRef in ponto.npcs) {
        if (referenciaEstaNPC(npcRef)) {
          adicionar('Ponto de Interesse', ponto, localId: localId, localNome: local.nome);
          localTemReferencia = true;
        }
      }
      if (grupoContemNPC(ponto.encontrosAliados)) {
        adicionar('Ponto de Interesse', ponto, localId: localId, localNome: local.nome);
        localTemReferencia = true;
      }
      if (grupoContemNPC(ponto.encontrosInimigos)) {
        adicionar('Ponto de Interesse', ponto, localId: localId, localNome: local.nome);
        localTemReferencia = true;
      }
      for (final evento in ponto.eventos) {
        if (eventoTemNPC(evento, nomeAtual)) {
          adicionar('Evento', evento);
          localTemReferencia = true;
        }
      }
    }

    if (localTemReferencia) {
      adicionar('Local', local);
    }
  }

  try {
    final eventosBase = await CadastrosRepository().carregarEventos();
    for (final evento in eventosBase) {
      if (eventoTemNPC(evento, nomeAtual)) {
        adicionar('Evento', evento);
      }
    }
  } catch (_) {}

  try {
    final pontosBase = await CadastrosRepository().carregarPontos();
    for (final ponto in pontosBase) {
      if (referencias.values.any((r) => r.tipo == 'Ponto de Interesse' && r.nome == ponto.nome)) continue;
      for (final npcRef in ponto.npcs) {
        if (referenciaEstaNPC(npcRef)) {
          adicionar('Ponto de Interesse', ponto);
        }
      }
    }
  } catch (_) {}

  const ordemTipos = ['Local', 'Evento', 'Ponto de Interesse'];
  final resultado = referencias.values.toList()
    ..sort((a, b) {
      final ordemA = ordemTipos.indexOf(a.tipo);
      final ordemB = ordemTipos.indexOf(b.tipo);
      if (ordemA != ordemB) return ordemA.compareTo(ordemB);
      return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
    });
  return resultado;
}

Widget? widgetReferenciaNPC(BuildContext context, ReferenciaLocalizacaoNPC ref) {
  switch (ref.tipo) {
    case 'Local':
      return LocalScreen(local: ref.registro as Local);
    case 'Evento':
      return EventoScreen(evento: ref.registro as Evento);
    case 'Ponto de Interesse':
      final localId = ref.localId;
      if (localId == null || localId.isEmpty) return null;
      return PontoInteresseScreen(
        localId: localId,
        ponto: ref.registro as PontoInteresse,
      );
  }
  return null;
}