import 'npc.dart';
import 'periodo_dia.dart';

class EncontroNPC {
  final NPC npc;
  final bool raro;
  final PeriodoDia? periodo;

  final int? leguaMin;
  final int? leguaMax;

  const EncontroNPC({
    required this.npc,
    this.raro = false,
    this.periodo,
    this.leguaMin,
    this.leguaMax,
  });

  bool disponivelEm({
    required PeriodoDia periodoAtual,
    required int? leguaAtual,
  }) {
    if (periodo != null &&
        periodo != PeriodoDia.qualquer &&
        periodoAtual != PeriodoDia.qualquer &&
        periodo != periodoAtual) {
      return false;
    }

    if (leguaAtual != null) {
      if (leguaMin != null && leguaAtual < leguaMin!) {
        return false;
      }

      if (leguaMax != null && leguaAtual > leguaMax!) {
        return false;
      }
    }

    return true;
  }
}
