import 'dart:math';

import '../models/criatura.dart';
import '../models/poder.dart';

class Progressao {
  static final Random random = Random();

  static const List<String> tipos = [
    "Normal",
    "Fogo",
    "Água",
    "Elétrico",
    "Planta",
    "Gelo",
    "Lutador",
    "Venenoso",
    "Terrestre",
    "Voador",
    "Psíquico",
    "Inseto",
    "Pedra",
    "Fantasma",
    "Dragão",
    "Noturno",
    "Metal",
    "Fada",
  ];

  static Criatura aplicarProgressaoNivel(
    Criatura criatura,
  ) {
    final quantidadeAjustes = criatura.nivel ~/ 10;

    Criatura resultado = criatura;

    for (int i = 0; i < quantidadeAjustes; i++) {
      resultado = aplicarAjuste(resultado);
    }

    return resultado;
  }

  static Criatura aplicarAjuste(
    Criatura criatura,
  ) {
    final resultado = random.nextInt(6) + 1;

    switch (resultado) {
      case 1:
      case 2:
      case 3:
        return aumentarCaracteristica(criatura);

      case 4:
      case 5:
        return copiarcriatura(
          criatura,
          pontosMoveProgressao:
              criatura.pontosMoveProgressao + 1,
        );

      case 6:
        return aumentarPoder(criatura);

      default:
        return criatura;
    }
  }

  static Criatura aumentarCaracteristica(
    Criatura criatura,
  ) {
    final atributo = random.nextInt(6);

    switch (atributo) {
      case 0:
        return copiarcriatura(
          criatura,
          bonusForca: criatura.bonusForca + 1,
        );

      case 1:
        return copiarcriatura(
          criatura,
          bonusHabilidade: criatura.bonusHabilidade + 1,
        );

      case 2:
        final novaResistencia =
            criatura.bonusResistencia + 1;

        final resistenciaTotal =
            criatura.resistencia + novaResistencia;

        return copiarcriatura(
          criatura,
          bonusResistencia: novaResistencia,
          pv: resistenciaTotal * 5,
        );

      case 3:
        return copiarcriatura(
          criatura,
          bonusArmadura: criatura.bonusArmadura + 1,
        );

      case 4:
        return copiarcriatura(
          criatura,
          bonusDefesaEspecial:
              criatura.bonusDefesaEspecial + 1,
        );

      case 5:
        return copiarcriatura(
          criatura,
          bonusPoderDeFogo:
              criatura.bonusPoderDeFogo + 1,
        );

      default:
        return criatura;
    }
  }

  static Criatura aumentarPoder(
    Criatura criatura,
  ) {
    final tipoSorteado =
        tipos[random.nextInt(tipos.length)];

    final novosPoderes = List<Poder>.from(
      criatura.poderes,
    );

    final indice = novosPoderes.indexWhere(
      (poder) =>
          poder.tipo.trim().toLowerCase() ==
          tipoSorteado.trim().toLowerCase(),
    );

    final ehTipoUnico =
        criatura.tipos.length == 1;

    final mesmoTipoDocriatura =
        ehTipoUnico &&
        criatura.tipos.first.trim().toLowerCase() ==
            tipoSorteado.trim().toLowerCase();

    late int ganhoPe;

    if (indice >= 0) {
      final antigo = novosPoderes[indice];

      novosPoderes[indice] = Poder(
        tipo: antigo.tipo,
        valorBase: antigo.valorBase,
        bonus: antigo.bonus + 1,
        original: antigo.original,
      );

      ganhoPe = mesmoTipoDocriatura ? 2 : 1;
    } else {
      final valorBase = criatura.lendario ? 3 : 1;

      novosPoderes.add(
        Poder(
          tipo: tipoSorteado,
          valorBase: valorBase,
          original: false,
        ),
      );

      ganhoPe = mesmoTipoDocriatura
          ? valorBase * 2
          : valorBase;
    }

    return copiarcriatura(
      criatura,
      poderes: novosPoderes,
      pe: criatura.pe + ganhoPe,
    );
  }

  static Criatura copiarcriatura(
    Criatura criatura, {
    int? bonusForca,
    int? bonusHabilidade,
    int? bonusResistencia,
    int? bonusArmadura,
    int? bonusDefesaEspecial,
    int? bonusPoderDeFogo,
    int? pontosMoveProgressao,
    List<Poder>? poderes,
    int? pv,
    int? pe,
  }) {
    return Criatura(
      id: criatura.id,
      numero: criatura.numero,
      nome: criatura.nome,
      nivel: criatura.nivel,
      lendario: criatura.lendario,
      tipos: criatura.tipos,
      superEfetivo: criatura.superEfetivo,
      poucoEfetivo: criatura.poucoEfetivo,
      imune: criatura.imune,
      efetividadeTipo: criatura.efetividadeTipo,
      forca: criatura.forca,
      habilidade: criatura.habilidade,
      resistencia: criatura.resistencia,
      armadura: criatura.armadura,
      defesaEspecial: criatura.defesaEspecial,
      poderDeFogo: criatura.poderDeFogo,
      bonusForca:
          bonusForca ?? criatura.bonusForca,
      bonusHabilidade:
          bonusHabilidade ?? criatura.bonusHabilidade,
      bonusResistencia:
          bonusResistencia ?? criatura.bonusResistencia,
      bonusArmadura:
          bonusArmadura ?? criatura.bonusArmadura,
      bonusDefesaEspecial:
          bonusDefesaEspecial ??
          criatura.bonusDefesaEspecial,
      bonusPoderDeFogo:
          bonusPoderDeFogo ??
          criatura.bonusPoderDeFogo,
      moves: List<String>.from(criatura.moves),
      pontosMoveProgressao:
          pontosMoveProgressao ??
          criatura.pontosMoveProgressao,
      poderes:
          poderes ?? criatura.poderes,
      poderesExtras: criatura.poderesExtras,
      pv: pv ?? criatura.pv,
      pe: pe ?? criatura.pe,
      localizacao: criatura.localizacao,
    );
  }
}
