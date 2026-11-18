import 'package:flutter/material.dart';

import '../models/grupo.dart';
import '../models/tipo_encontro.dart';

class SeletorEncontro extends StatelessWidget {
  final Grupo grupo;
  final TipoEncontro selecionado;
  final ValueChanged<TipoEncontro> onChanged;

  const SeletorEncontro({
    super.key,
    required this.grupo,
    required this.selecionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final opcoes = <Widget>[];

    void adicionarBotao(
      TipoEncontro tipo,
      String texto,
      List lista,
    ) {
      if (lista.isEmpty) return;

      opcoes.add(
        ChoiceChip(
          label: Text(texto),
          selected: selecionado == tipo,
          onSelected: (_) => onChanged(tipo),
        ),
      );
    }

    adicionarBotao(
      TipoEncontro.diurno,
      "Diurno",
      grupo.diurno,
    );

    adicionarBotao(
      TipoEncontro.noturno,
      "Noturno",
      grupo.noturno,
    );

    adicionarBotao(
      TipoEncontro.pesca,
      "Pesca",
      grupo.pesca,
    );

    adicionarBotao(
      TipoEncontro.surfe,
      "Aquático",
      grupo.surfe,
    );

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: opcoes,
    );
  }
}
