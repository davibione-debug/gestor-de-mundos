class Poder {
  final String tipo;

  // Valor inicial do Poder
  final int valorBase;

  // Bônus recebido pela progressão
  final int bonus;

  // true = Poder original do Criatura
  // false = Poder adquirido durante a progressão
  final bool original;


  Poder({
    required this.tipo,

    required this.valorBase,

    this.bonus = 0,

    this.original = true,
  });



  // Valor total usado nas regras
  int get valorTotal {
    return valorBase + bonus;
  }



  // Texto exibido na ficha
  String get texto {

    // Poder original mostra o bônus separado
    if (original && bonus > 0) {

      return "$tipo $valorBase (+$bonus)";

    }


    // Poder extra mostra apenas o valor atual
    if (!original) {

      return "$tipo $valorTotal";

    }


    // Poder original sem bônus
    return "$tipo $valorBase";

  }

}