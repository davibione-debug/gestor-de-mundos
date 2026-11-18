import 'package:flutter/material.dart';

import '../../models/evento.dart';
import '../../models/local.dart';
import '../../models/npc.dart';
import '../../models/ponto_interesse.dart';
import '../../repositories/cadastros_repository.dart';
import '../../repositories/criaturas_repository.dart';
import '../bestiario/criatura_detalhe_screen.dart';
import '../../models/criatura.dart';
import '../../repositories/locais_repository.dart';
import '../../repositories/npcs_repository.dart';
import '../../models/item.dart';
import '../../repositories/itens_repository.dart';
import 'item_editar_screen.dart';
import '../mapa/local_screen.dart';
import '../mapa/evento_screen.dart';
import '../mapa/ponto_interesse_screen.dart';
import '../npcs/npc_screen.dart';


class _ReferenciaItem {
  final String tipo;
  final String nome;
  final Object registro;
  final String? localId;
  final String? pontoId;

  const _ReferenciaItem({
    required this.tipo,
    required this.nome,
    required this.registro,
    this.localId,
    this.pontoId,
  });

  String get chave {
    try {
      final dynamic item = registro;
      final id = item.id?.toString() ?? '';
      if (id.isNotEmpty) return '$tipo:$id';
    } catch (_) {}
    return '$tipo:$nome';
  }
}

class ItemDetalheScreen extends StatefulWidget {
  final Item item;

  const ItemDetalheScreen({
    super.key,
    required this.item,
  });

  @override
  State<ItemDetalheScreen> createState() =>
      _ItemDetalheScreenState();
}

class _ItemDetalheScreenState
    extends State<ItemDetalheScreen> {
  final ItensRepository _repository =
      ItensRepository();

  late Item _item;

  late final Future<List<_ReferenciaItem>> _localizacoesFuture =
      _buscarLocalizacoes();

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _editar() async {
    final resultado =
        await Navigator.push<Item>(
      context,
      MaterialPageRoute(
        builder: (_) => ItemEditarScreen(
          item: _item,
        ),
      ),
    );

    if (resultado != null && mounted) {
      setState(() {
        _item = resultado;
      });
    } else if (mounted) {
      final itens = await _repository.carregar();

      for (final item in itens) {
        if (item.nome.trim().toLowerCase() ==
            _item.nome.trim().toLowerCase()) {
          setState(() {
            _item = item;
          });
          break;
        }
      }
    }
  }

  Future<void> _excluir() async {
    final confirmar =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Excluir item?',
          ),
          content: Text(
            'O item "${_item.nome}" será removido.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    await _repository.remover(_item.nome);

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  Future<List<_ReferenciaItem>> _buscarLocalizacoes() async {
    final referencias = <String, _ReferenciaItem>{};
    final nomeAtual = _item.nome.trim().toLowerCase();

    bool contemItem(List<Item> itens) {
      return itens.any(
        (it) => it.nome.trim().toLowerCase() == nomeAtual,
      );
    }

    // 1) Locais
    final locais = await LocaisRepository().carregar();
    for (final local in locais) {
      final localId = local.id;

      if (contemItem(local.itens)) {
        _adicionar(referencias, 'Local', local);
      }

      // 2) Pontos de Interesse dentro do Local
      for (final ponto in local.pontosInteresse) {
        if (contemItem(ponto.itens)) {
          _adicionar(
            referencias,
            'Ponto de Interesse',
            ponto,
            localId: localId,
          );
        }

        // Eventos do Ponto
        for (final evento in ponto.eventos) {
          if (contemItem(evento.itens)) {
            _adicionar(referencias, 'Evento', evento);
          }
        }
      }

      // 3) Eventos do Local
      for (final evento in local.eventos) {
        if (contemItem(evento.itens)) {
          _adicionar(referencias, 'Evento', evento);
        }
      }
    }

    // 4) Eventos-base (cadastro)
    try {
      final eventosBase = await CadastrosRepository().carregarEventos();
      for (final evento in eventosBase) {
        if (contemItem(evento.itens)) {
          _adicionar(referencias, 'Evento', evento);
        }
      }
    } catch (_) {}

    // 5) Pontos-base (cadastro)
    try {
      final pontosBase = await CadastrosRepository().carregarPontos();
      for (final ponto in pontosBase) {
        if (contemItem(ponto.itens)) {
          if (referencias.values.any((r) =>
              r.tipo == 'Ponto de Interesse' && r.nome == ponto.nome)) {
            continue;
          }
          _adicionar(referencias, 'Ponto de Interesse', ponto);
        }
      }
    } catch (_) {}

    // 6) NPCs
    try {
      final npcs = await NPCsRepository().carregar();
      for (final npc in npcs) {
        if (contemItem(npc.itens)) {
          _adicionar(referencias, 'Personagem', npc);
        }
      }
    } catch (_) {}

    // 7) Criaturas do Bestiário (itemComum / itemRaro)
    try {
      final criaturas = await CriaturasRepository().carregar();
      debugPrint('[DEBUG ITEM] Criaturas carregadas: ${criaturas.length}');
      debugPrint('[DEBUG ITEM] Procurando: $nomeAtual');
      for (final c in criaturas) {
        debugPrint('[DEBUG ITEM] Criatura ${c.nome}: comum=${c.itemComum?.nome} raro=${c.itemRaro?.nome}');
        if (c.itemComum?.nome.trim().toLowerCase() == nomeAtual ||
            c.itemRaro?.nome.trim().toLowerCase() == nomeAtual) {
          _adicionar(referencias, 'Criatura', c);
        }
      }
    } catch (_) {}

    const ordemTipos = ['Local', 'Personagem', 'Criatura', 'Evento', 'Ponto de Interesse'];
    final resultado = referencias.values.toList()
      ..sort((a, b) {
        final ordemA = ordemTipos.indexOf(a.tipo);
        final ordemB = ordemTipos.indexOf(b.tipo);
        if (ordemA != ordemB) return ordemA.compareTo(ordemB);
        return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
      });
    return resultado;
  }

  void _adicionar(
    Map<String, _ReferenciaItem> destino,
    String tipo,
    dynamic registro, {
    String? localId,
    String? pontoId,
  }) {
    final nome = _nomeRegistro(registro);
    if (nome.isEmpty) return;
    final referencia = _ReferenciaItem(
      tipo: tipo,
      nome: nome,
      registro: registro as Object,
      localId: localId,
      pontoId: pontoId,
    );
    destino.putIfAbsent(referencia.chave, () => referencia);
  }

  String _nomeRegistro(dynamic reg) {
    try {
      return reg.nome?.toString().trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  void _abrirReferencia(_ReferenciaItem r) {
    switch (r.tipo) {
      case 'Local':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LocalScreen(local: r.registro as Local),
          ),
        );
        break;
      case 'Criatura':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CriaturaDetalheScreen(
              criatura: r.registro as Criatura,
              nivelAlteravel: false,
              origem: OrigemCriatura.bestiario,
              iniciarBatalha: false,
            ),
          ),
        );
        return;
      case 'Personagem':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NPCScreen(npcId: (r.registro as NPC).id),
          ),
        );
        break;
      case 'Evento':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventoScreen(evento: r.registro as Evento),
          ),
        );
        break;
      case 'Ponto de Interesse':
        final ponto = r.registro as PontoInteresse;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PontoInteresseScreen(
              localId: r.localId ?? '',
              ponto: ponto,
            ),
          ),
        );
        break;
    }
  }

  Widget _secaoLocalizacao() {
    return FutureBuilder<List<_ReferenciaItem>>(
      future: _localizacoesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final referencias = snapshot.data ?? const [];
        if (referencias.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Nenhum registro referencia este item.'),
            ),
          );
        }

        const ordemTipos = [
          'Local',
          'Personagem',
          'Criatura',
          'Evento',
          'Ponto de Interesse',
        ];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LOCALIZAÇÃO',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                for (final tipo in ordemTipos)
                  if (referencias.any((r) => r.tipo == tipo))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '$tipo: ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          for (var i = 0, indice = 0;
                              i < referencias.length;
                              i++)
                            if (referencias[i].tipo == tipo) ...[
                              if (indice++ > 0) const Text(', '),
                              InkWell(
                                onTap: () => _abrirReferencia(referencias[i]),
                                child: Text(
                                  referencias[i].nome,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                    decoration: TextDecoration.underline,
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
      },
    );
  }

  Widget _campo(
    String titulo,
    String valor, {
    IconData? icone,
  }) {
    if (valor.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          if (icone != null) ...[
            Icon(
              icone,
              size: 21,
              color: Colors.orange.shade800,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blocoCompacto({
    required String titulo,
    required String texto,
    required IconData icone,
  }) {
    if (texto.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(
            alpha: 0.07,
          ),
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: Colors.orange.withValues(
              alpha: 0.18,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icone,
                  size: 19,
                  color: Colors.orange.shade800,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    titulo,
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              texto,
              style: const TextStyle(
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final temDescricao =
        _item.descricao.trim().isNotEmpty;
    final temEfeito =
        _item.efeito.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _item.nome,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Editar',
            onPressed: _editar,
            icon: const Icon(
              Icons.edit_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Excluir',
            onPressed: _excluir,
            icon: const Icon(
              Icons.delete_outline,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          32,
        ),
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.orange.shade800,
                  size: 31,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      _item.nome,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (_item.tipo
                        .trim()
                        .isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Colors.orange.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          _item.tipo,
                          style: TextStyle(
                            color:
                                Colors.orange.shade900,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(
                alpha: 0.08,
              ),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.monetization_on_outlined,
                  color: Colors.orange.shade800,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Custo',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_item.custoEmCreditos} Cr',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          if (temDescricao || temEfeito) ...[
            const SizedBox(height: 18),
            if (temDescricao && temEfeito)
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _blocoCompacto(
                    titulo: 'Descrição',
                    texto: _item.descricao,
                    icone:
                        Icons.description_outlined,
                  ),
                  const SizedBox(width: 10),
                  _blocoCompacto(
                    titulo: 'Efeito',
                    texto: _item.efeito,
                    icone:
                        Icons.auto_awesome_outlined,
                  ),
                ],
              )
            else if (temDescricao)
              _blocoCompacto(
                titulo: 'Descrição',
                texto: _item.descricao,
                icone:
                    Icons.description_outlined,
              )
            else
              _blocoCompacto(
                titulo: 'Efeito',
                texto: _item.efeito,
                icone:
                    Icons.auto_awesome_outlined,
              ),
          ],
          if (_item.localizacao.trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            _campo(
              'Localização (texto do item)',
              _item.localizacao,
              icone: Icons.location_on_outlined,
            ),
          ],
          const SizedBox(height: 18),
          _secaoLocalizacao(),
        ],
      ),
    );
  }
}
