import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/criatura.dart';

class StatusBatalha {
  String nome;
  int duracao;

  StatusBatalha({
    required this.nome,
    required this.duracao,
  });
}

class Batalhacriatura {
  final int id;
  final Criatura criatura;
  final String origem;

  int pv;
  List<int> pe;
  List<String> moves;
  List<int> custosMoves;
  List<StatusBatalha> status;

  bool minimizada;

  Batalhacriatura({
    required this.id,
    required this.criatura,
    this.origem = 'bestiario',
    required this.pv,
    required this.pe,
    required this.moves,
    required this.custosMoves,
    required this.status,
    this.minimizada = false,
  });

  int get pontosMovesDisponiveis {
    return criatura.pontosMoveIniciais +
        criatura.pontosMoveProgressao;
  }

  int get pontosMovesGastos {
    return custosMoves.fold(
      0,
      (total, custo) => total + custo,
    );
  }

  int peMaximo(dynamic poder) {
    final valor = poder.valorTotal;

    final tipoUnico =
        criatura.tipos.length == 1 &&
        criatura.tipos.first.trim().toLowerCase() ==
            poder.tipo.trim().toLowerCase();

    return tipoUnico ? valor * 2 : valor;
  }

  int regeneracaoPe(dynamic poder) {
    final tipoUnico =
        criatura.tipos.length == 1 &&
        criatura.tipos.first.trim().toLowerCase() ==
            poder.tipo.trim().toLowerCase();

    return tipoUnico ? 2 : 1;
  }
}

final batalhasProvider =
    StateNotifierProvider<BatalhasNotifier, List<Batalhacriatura>>(
  (ref) => BatalhasNotifier(),
);

class BatalhasNotifier extends StateNotifier<List<Batalhacriatura>> {
  BatalhasNotifier() : super([]);

  int _proximoId = 1;

  Batalhacriatura? porId(int id) {
    for (final batalha in state) {
      if (batalha.id == id) {
        return batalha;
      }
    }

    return null;
  }

  int? abrir(
    Criatura criatura, {
    String origem = 'bestiario',
  }) {
    final batalha = Batalhacriatura(
      id: _proximoId++,
      criatura: criatura,
      origem: origem,
      pv: criatura.pv,
      pe: criatura.poderes
          .map((poder) {
            final valor = poder.valorTotal;

            final tipoUnico =
                criatura.tipos.length == 1 &&
                criatura.tipos.first.trim().toLowerCase() ==
                    poder.tipo.trim().toLowerCase();

            return tipoUnico ? valor * 2 : valor;
          })
          .toList(),
      moves: List<String>.generate(
        4,
        (indice) {
          if (indice < criatura.moves.length) {
            return criatura.moves[indice];
          }

          return '';
        },
      ),
      custosMoves: List<int>.filled(4, 0),
      status: [],
    );

    for (final outra in state) {
      outra.minimizada = true;
    }

    state = [
      ...state,
      batalha,
    ];

    return batalha.id;
  }

  void ativar(int id) {
    final batalha = porId(id);

    if (batalha == null) {
      return;
    }

    for (final outra in state) {
      outra.minimizada = outra.id != id;
    }

    batalha.minimizada = false;

    state = [...state];
  }

  void minimizar(int id) {
    final batalha = porId(id);

    if (batalha == null) {
      return;
    }

    batalha.minimizada = true;

    state = [...state];
  }

  void fechar(int id) {
    state = state
        .where((batalha) => batalha.id != id)
        .toList();
  }

  void alterarPv(
    int id,
    int valor,
  ) {
    final batalha = porId(id);

    if (batalha == null) {
      return;
    }

    batalha.pv =
        (batalha.pv + valor).clamp(0, batalha.criatura.pv);

    state = [...state];
  }

  void alterarPe(
    int id,
    int indice,
    int valor,
  ) {
    final batalha = porId(id);

    if (batalha == null ||
        indice < 0 ||
        indice >= batalha.pe.length ||
        indice >= batalha.criatura.poderes.length) {
      return;
    }

    final maximo =
        batalha.peMaximo(batalha.criatura.poderes[indice]);

    batalha.pe[indice] =
        (batalha.pe[indice] + valor).clamp(0, maximo);

    state = [...state];
  }

  void alterarMove(
    int id,
    int indice,
    String valor,
  ) {
    final batalha = porId(id);

    if (batalha == null ||
        indice < 0 ||
        indice >= batalha.moves.length) {
      return;
    }

    batalha.moves[indice] = valor;

    state = [...state];
  }

  void alterarCustoMove(
    int id,
    int indice,
    String valor,
  ) {
    final batalha = porId(id);

    if (batalha == null ||
        indice < 0 ||
        indice >= batalha.custosMoves.length) {
      return;
    }

    final custo = int.tryParse(valor);

    if (custo == null || custo < 1 || custo > 6) {
      batalha.custosMoves[indice] = 0;
    } else {
      batalha.custosMoves[indice] = custo;
    }

    state = [...state];
  }

  void adicionarStatus(
    int id,
    StatusBatalha status,
  ) {
    final batalha = porId(id);

    if (batalha == null) {
      return;
    }

    batalha.status.add(status);

    state = [...state];
  }

  void alterarStatusDuracao(
    int id,
    int indice,
    int valor,
  ) {
    final batalha = porId(id);

    if (batalha == null ||
        indice < 0 ||
        indice >= batalha.status.length) {
      return;
    }

    batalha.status[indice].duracao =
        (batalha.status[indice].duracao + valor)
            .clamp(1, 999);

    state = [...state];
  }

  void inicioTurno(int id) {
    final batalha = porId(id);

    if (batalha == null) {
      return;
    }

    for (var i = 0;
        i < batalha.criatura.poderes.length &&
            i < batalha.pe.length;
        i++) {
      final poder = batalha.criatura.poderes[i];
      final maximo = batalha.peMaximo(poder);
      final regeneracao =
          batalha.regeneracaoPe(poder);

      batalha.pe[i] =
          (batalha.pe[i] + regeneracao)
              .clamp(0, maximo);
    }

    state = [...state];
  }

  void fimTurno(int id) {
    final batalha = porId(id);

    if (batalha == null) {
      return;
    }

    for (final status in batalha.status) {
      status.duracao--;
    }

    batalha.status.removeWhere(
      (status) => status.duracao <= 0,
    );

    state = [...state];
  }
}
