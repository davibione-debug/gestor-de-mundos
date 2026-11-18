import 'periodo_dia.dart';
import 'criatura.dart';

class Encontro {
  final Criatura criatura;

  final String condicao;
  final bool raro;
  final PeriodoDia? periodo;

  final int? leguaMin;
  final int? leguaMax;

  final int? nivelFixo;

  final bool fichaFixada;

  const Encontro({
    required this.criatura,
    required this.condicao,
    this.raro = false,
    this.periodo,
    this.leguaMin,
    this.leguaMax,
    this.nivelFixo,
    this.fichaFixada = false,
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
