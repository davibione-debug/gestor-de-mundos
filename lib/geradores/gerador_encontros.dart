import 'dart:math';

import '../models/encontro.dart';
import '../models/local.dart';
import '../models/periodo_dia.dart';
import '../models/criatura.dart';
import '../models/tipo_encontro.dart';
import 'progressao.dart';

class GeradorEncontro {
  final Random _random = Random();

  Criatura gerar(
    Local local,
    TipoEncontro tipo,
    PeriodoDia periodo, {
    int? leguaAtual,
  }) {
    var tabela = _selecionarTabela(
      local,
      tipo,
    );

    if (tabela.isEmpty) {
      throw Exception(
        'Não existem encontros para este tipo.',
      );
    }

    tabela = tabela.where((encontro) {
      return encontro.disponivelEm(
        periodoAtual: periodo,
        leguaAtual: leguaAtual,
      );
    }).toList();

    if (tabela.isEmpty) {
      if (leguaAtual != null &&
          periodo != PeriodoDia.qualquer) {
        throw Exception(
          'Não existem encontros disponíveis '
          'na Légua $leguaAtual para o período '
          '${periodo.texto}.',
        );
      }

      if (leguaAtual != null) {
        throw Exception(
          'Não existem encontros disponíveis '
          'na Légua $leguaAtual.',
        );
      }

      if (periodo != PeriodoDia.qualquer) {
        throw Exception(
          'Não existem encontros disponíveis '
          'para o período ${periodo.texto}.',
        );
      }

      throw Exception(
        'Não existem encontros disponíveis.',
      );
    }

    final normais =
        tabela.where((e) => !e.raro).toList();

    final raros =
        tabela.where((e) => e.raro).toList();

    final saiuRaro =
        _random.nextInt(6) == 5;

    late Encontro encontro;

    if (saiuRaro && raros.isNotEmpty) {
      encontro = raros[
        _random.nextInt(raros.length)
      ];
    } else {
      final lista =
          normais.isNotEmpty
              ? normais
              : tabela;

      encontro = lista[
        _random.nextInt(lista.length)
      ];
    }

    final nivel = encontro.nivelFixo ??
        _sortearNivel(
      local.nivelMinCriatura,
      local.nivelMaxCriatura,
    );

    final criaturaNivelado =
        encontro.criatura.comNivel(
      nivel,
    );

    final resultado =
        Progressao.aplicarProgressaoNivel(
      criaturaNivelado,
    );

    return resultado;
  }

  List<Encontro> _selecionarTabela(
    Local local,
    TipoEncontro tipo,
  ) {
    switch (tipo) {
      case TipoEncontro.diurno:
        return local.encontros.diurno;

      case TipoEncontro.noturno:
        return local.encontros.noturno;

      case TipoEncontro.pesca:
        return local.encontros.pesca;

      case TipoEncontro.surfe:
        return local.encontros.surfe;
    }
  }

  int _sortearNivel(
    int minimo,
    int maximo,
  ) {
    if (minimo <= 0 ||
        maximo <= 0) {
      throw Exception(
        'O Local não possui uma faixa de nível válida.',
      );
    }

    if (minimo > maximo) {
      throw Exception(
        'Nível mínimo do local não pode ser maior que o nível máximo.',
      );
    }

    return minimo +
        _random.nextInt(
          maximo - minimo + 1,
        );
  }
}

