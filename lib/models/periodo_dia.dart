enum PeriodoDia {
  qualquer,
  amanhecer,
  manha,
  tarde,
  anoitecer,
  noite,
  madrugada;

  String get texto {
    switch (this) {
      case PeriodoDia.qualquer:
        return "Qualquer";

      case PeriodoDia.amanhecer:
        return "Amanhecer";

      case PeriodoDia.manha:
        return "Manhã";

      case PeriodoDia.tarde:
        return "Tarde";

      case PeriodoDia.anoitecer:
        return "Anoitecer";

      case PeriodoDia.noite:
        return "Noite";

      case PeriodoDia.madrugada:
        return "Madrugada";
    }
  }
}
