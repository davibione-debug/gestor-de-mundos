import 'dart:math';

import '../models/encontro_npc.dart';
import '../models/grupo_npc.dart';
import '../models/npc.dart';
import '../models/periodo_dia.dart';
import '../models/tipo_encontro.dart';

class GeradorNPC {
  final Random _random = Random();

  NPC gerar(
    GrupoNPC grupo,
    TipoEncontro tipo,
    PeriodoDia periodo,
  ) {
    List<EncontroNPC> tabela = _selecionarTabela(
      grupo,
      tipo,
    );

    if (tabela.isEmpty) {
      throw Exception(
        "Não existem NPCs para este tipo de encontro.",
      );
    }

    // Filtra pelo período quando um período específico foi informado.
    if (periodo != PeriodoDia.qualquer) {
      tabela = tabela.where(
        (encontro) {
          return encontro.periodo == null ||
              encontro.periodo == periodo;
        },
      ).toList();
    }

    if (tabela.isEmpty) {
      throw Exception(
        "Não existem NPCs para este período.",
      );
    }

    final List<EncontroNPC> normais = tabela
        .where((e) => !e.raro)
        .toList();

    final List<EncontroNPC> raros = tabela
        .where((e) => e.raro)
        .toList();

    // 1/6 de chance de tentar gerar um encontro raro.
    final bool saiuRaro = _random.nextInt(6) == 5;

    late EncontroNPC encontro;

    if (saiuRaro && raros.isNotEmpty) {
      encontro = raros[
        _random.nextInt(
          raros.length,
        )
      ];
    } else {
      final List<EncontroNPC> lista = normais.isNotEmpty
          ? normais
          : tabela;

      encontro = lista[
        _random.nextInt(
          lista.length,
        )
      ];
    }

    return encontro.npc;
  }

  List<EncontroNPC> _selecionarTabela(
    GrupoNPC grupo,
    TipoEncontro tipo,
  ) {
    switch (tipo) {
      case TipoEncontro.diurno:
        return grupo.diurno;

      case TipoEncontro.noturno:
        return grupo.noturno;

      case TipoEncontro.pesca:
        return grupo.pesca;

      case TipoEncontro.surfe:
        return grupo.surfe;
    }
  }
}