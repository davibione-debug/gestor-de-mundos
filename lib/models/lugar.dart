import 'trecho_terreno.dart';
import 'ponto_interesse.dart';

class Lugar {
  final String nome;

  final String descricao;

  final List<TrechoTerreno> trechos;

  final List<String> eventos;

  final List<PontoInteresse> pontosDeInteresse;

  const Lugar({
    required this.nome,
    required this.descricao,
    required this.trechos,
    required this.eventos,
    required this.pontosDeInteresse,
  });

  int get totalLeguas {
    return trechos.fold(
      0,
          (soma, trecho) => soma + trecho.leguas,
    );
  }
}