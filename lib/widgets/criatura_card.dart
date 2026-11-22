import 'package:flutter/material.dart';

import '../models/criatura.dart';
import '../theme/app_colors.dart';

class CriaturaCard extends StatelessWidget {
  final Criatura criatura;
  final VoidCallback? onDelete;
  final bool nivelAlteravel;
  final ValueChanged<int>? onNivelChanged;
  final bool batalhaAberta;
  final VoidCallback? onBatalha;
  final bool batalhaNoFinal;

  const CriaturaCard({
    super.key,
    required this.criatura,
    this.onDelete,
    this.nivelAlteravel = false,
    this.onNivelChanged,
    this.batalhaAberta = false,
    this.onBatalha,
    this.batalhaNoFinal = false,
  });

  Widget _tituloSecao(String titulo, Color cor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 19,
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            titulo,
            style: const TextStyle(
              color: PTColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _efetividade(String titulo, String valor, Color cor) {
    if (valor.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$titulo: ',
            style: TextStyle(
              color: cor,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                color: PTColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _atributo(String titulo, String valor, Color cor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: PTColors.softSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 23,
              decoration: BoxDecoration(
                color: cor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  color: PTColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              valor.isEmpty ? '—' : valor,
              style: const TextStyle(
                color: PTColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recurso(
    String titulo,
    String valor,
    Color cor,
    IconData icone,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: cor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: cor.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icone,
              color: cor,
              size: 19,
            ),
            const SizedBox(width: 7),
            Text(
              titulo,
              style: TextStyle(
                color: cor,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            Text(
              valor,
              style: const TextStyle(
                color: PTColors.text,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nivel() {
    if (!nivelAlteravel || onNivelChanged == null) {
      return Text(
        'Nível ${criatura.nivel}',
        style: const TextStyle(
          color: PTColors.white,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: PTColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: criatura.nivel,
          isDense: true,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: PTColors.fire,
          ),
          style: const TextStyle(
            color: PTColors.text,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
          items: List.generate(
            100,
            (index) {
              final nivel = index + 1;

              return DropdownMenuItem<int>(
                value: nivel,
                child: Text(
                  'Nível $nivel',
                ),
              );
            },
          ),
          onChanged: (nivel) {
            if (nivel != null) {
              onNivelChanged!(nivel);
            }
          },
        ),
      ),
    );
  }

  Widget _poderesLinha() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSecao(
          'Poderes:',
          PTColors.electric,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: criatura.poderes.isEmpty
              ? const Text(
                  '—',
                  style: TextStyle(
                    color: PTColors.subtitle,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : Text(
                  criatura.poderes.map((poder) => poder.texto).join(' • '),
                  style: const TextStyle(
                    color: PTColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _moveItem(String move) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.flash_on,
              color: PTColors.electric,
              size: 17,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              move,
              style: const TextStyle(
                color: PTColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _movesLinha() {
    final moves = criatura.moves
        .map((move) => move.trim())
        .where((move) => move.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pontos para Moves: ${criatura.pontosMoveIniciais}',
          style: const TextStyle(
            color: PTColors.text,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        if (moves.isEmpty)
          const Text(
            '—',
            style: TextStyle(
              color: PTColors.subtitle,
              fontSize: 14,
            ),
          )
        else
          ...moves.map(_moveItem),
        if (criatura.pontosMoveProgressao > 0) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(
                Icons.add_circle_outline,
                color: PTColors.electric,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                '+${criatura.pontosMoveProgressao} por Progressão',
                style: const TextStyle(
                  color: PTColors.electric,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pvCalculado = (criatura.resistencia + criatura.bonusResistencia) * 5;
    final peCalculado = criatura.poderes.fold(0, (soma, p) {
      final ehTipoUnico = criatura.tipos.length == 1;
      final mesmoTipo = ehTipoUnico && criatura.tipos.first.trim().toLowerCase() == p.tipo.trim().toLowerCase();
      final valorPoder = p.valorBase + p.bonus;
      return soma + (mesmoTipo ? valorPoder * 2 : valorPoder);
    });
    final tipos = criatura.tipos
        .where(
          (tipo) => tipo.trim().isNotEmpty,
        )
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: PTColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: PTColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: PTColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                13,
                11,
                10,
                11,
              ),
              color: PTColors.fire,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          criatura.numero == null
                              ? criatura.nome
                              : '#${criatura.numero.toString().padLeft(3, '0')} ${criatura.nome}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: PTColors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (onDelete != null)
                        IconButton(
                          tooltip: 'Excluir Criatura',
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 38,
                            minHeight: 38,
                          ),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: PTColors.white,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (tipos.isNotEmpty)
                        Expanded(
                          child: Text(
                            tipos.join('/') + (criatura.lendario ? ' Lendário' : ''),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: PTColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                      else
                        const Spacer(),
                      const SizedBox(width: 8),
                      _nivel(),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                13,
                11,
                13,
                13,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (criatura.descricao.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: PTColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: PTColors.border),
                      ),
                      child: Text(
                        criatura.descricao,
                        style: const TextStyle(
                          color: PTColors.text,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Row(
                    children: [
                      _atributo(
                        'Força',
                        criatura.forcaTexto,
                        PTColors.fire,
                      ),
                      const SizedBox(width: 6),
                      _atributo(
                        'Armadura',
                        criatura.armaduraTexto,
                        PTColors.fighting,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _atributo(
                        'Habilidade',
                        criatura.habilidadeTexto,
                        PTColors.water,
                      ),
                      const SizedBox(width: 6),
                      _atributo(
                        'Defesa Especial',
                        criatura.defesaEspecialTexto,
                        PTColors.psychic,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _atributo(
                        'Resistência',
                        criatura.resistenciaTexto,
                        PTColors.grass,
                      ),
                      const SizedBox(width: 6),
                      _atributo(
                        'Poder de Fogo',
                        criatura.poderDeFogoTexto,
                        PTColors.electric,
                      ),
                    ],
                  ),
                  _tituloSecao(
                    'Efetividade de Tipo',
                    PTColors.psychic,
                  ),
                  _efetividade(
                    'Super Efetivo',
                    criatura.superEfetivo,
                    PTColors.grass,
                  ),
                  _efetividade(
                    'Pouco Efetivo',
                    criatura.poucoEfetivo,
                    PTColors.fighting,
                  ),
                  _efetividade(
                    'Imune',
                    criatura.imune,
                    PTColors.subtitle,
                  ),
                  const SizedBox(height: 8),                  if (!batalhaAberta) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _recurso('PV', pvCalculado.toString(),
                          PTColors.fire,
                          Icons.favorite,
                        ),
                        const SizedBox(width: 6),
                        _recurso('PE', peCalculado.toString(),
                          PTColors.water,
                          Icons.bolt,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 9),
                  _poderesLinha(),
                  if (!batalhaAberta) ...[
                    const SizedBox(height: 5),
                    _movesLinha(),
                  ],
                  if (!batalhaAberta && onBatalha != null) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onBatalha,
                        icon: const Icon(Icons.sports_mma),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        label: const Text(
                          'Batalha!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
