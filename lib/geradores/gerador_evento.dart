import '../models/evento.dart';

class ResultadoEvento {
  final Evento evento;

  const ResultadoEvento({
    required this.evento,
  });

  String get inicio => evento.inicio;
  String get duracao => evento.duracao;
  String get efeito => evento.efeito;
}

class GeradorEvento {
  ResultadoEvento rolar(Evento evento) {
    return ResultadoEvento(evento: evento);
  }
}
