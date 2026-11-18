import 'tabela_encontro.dart';

class Rota {
  final String nome;

  final TabelaEncontro? diurno;
  final TabelaEncontro? noturno;
  final TabelaEncontro? pesca;
  final TabelaEncontro? surfar;

  Rota({
    required this.nome,
    this.diurno,
    this.noturno,
    this.pesca,
    this.surfar,
  });
}