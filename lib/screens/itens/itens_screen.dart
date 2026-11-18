import 'package:flutter/material.dart';

import '../../models/item.dart';
import '../../repositories/itens_repository.dart';
import 'item_detalhe_screen.dart';
import 'item_editar_screen.dart';

class ItensScreen extends StatefulWidget {
  const ItensScreen({super.key});

  @override
  State<ItensScreen> createState() =>
      _ItensScreenState();
}

class _ItensScreenState extends State<ItensScreen> {
  final ItensRepository _repository =
      ItensRepository();

  final TextEditingController _nomeController =
      TextEditingController();

  List<Item> _itens = [];
  bool _carregando = true;
  String _tipoSelecionado = 'Todos';

  @override
  void initState() {
    super.initState();
    _carregarItens();
    _nomeController.addListener(_atualizarFiltro);
  }

  @override
  void dispose() {
    _nomeController.removeListener(
      _atualizarFiltro,
    );
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _carregarItens() async {
    setState(() {
      _carregando = true;
    });

    try {
      final itens =
          await _repository.carregar();

      if (!mounted) {
        return;
      }

      setState(() {
        _itens = itens;
        _carregando = false;

        final tipos =
            _tiposDisponiveis(itens);

        if (_tipoSelecionado != 'Todos' &&
            !tipos.contains(_tipoSelecionado)) {
          _tipoSelecionado = 'Todos';
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao carregar itens: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _atualizarFiltro() {
    if (mounted) {
      setState(() {});
    }
  }

  List<String> _tiposDisponiveis(
    List<Item> itens,
  ) {
    final tipos = itens
        .map((item) => item.tipo.trim())
        .where((tipo) => tipo.isNotEmpty)
        .toSet()
        .toList();

    tipos.sort(
      (a, b) => a.toLowerCase().compareTo(
        b.toLowerCase(),
      ),
    );

    return tipos;
  }

  List<Item> get _itensFiltrados {
    final nomeBusca =
        _nomeController.text.trim().toLowerCase();

    final resultado = _itens.where((item) {
      final correspondeNome =
          nomeBusca.isEmpty ||
          item.nome
              .toLowerCase()
              .contains(nomeBusca);

      final correspondeTipo =
          _tipoSelecionado == 'Todos' ||
          item.tipo.trim() ==
              _tipoSelecionado;

      return correspondeNome &&
          correspondeTipo;
    }).toList();

    resultado.sort(
      (a, b) => a.nome.toLowerCase().compareTo(
        b.nome.toLowerCase(),
      ),
    );

    return resultado;
  }

  void _limparFiltros() {
    _nomeController.clear();

    setState(() {
      _tipoSelecionado = 'Todos';
    });
  }

  Future<void> _adicionarItem() async {
    final novo = const Item(
      nome: '',
      tipo: '',
      custoEmCreditos: 0,
      efeito: '',
    );

    final resultado =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ItemEditarScreen(
          item: novo,
          novo: true,
        ),
      ),
    );

    if (resultado == true && mounted) {
      await _carregarItens();
    }
  }

  Future<void> _editarItem(Item item) async {
    final resultado =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ItemEditarScreen(
          item: item,
        ),
      ),
    );

    if (resultado == true && mounted) {
      await _carregarItens();
    }
  }

  Future<void> _abrirItem(Item item) async {
    final resultado =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetalheScreen(
          item: item,
        ),
      ),
    );

    if (resultado == true && mounted) {
      await _carregarItens();
    }
  }

  Widget _buildFiltros() {
    final filtrados = _itensFiltrados;
    final tipos =
        _tiposDisponiveis(_itens);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        14,
        12,
        14,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: Colors.orange.shade800,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${filtrados.length} '
                  '${filtrados.length == 1 ? 'item' : 'itens'}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (_nomeController.text
                      .isNotEmpty ||
                  _tipoSelecionado != 'Todos')
                TextButton(
                  onPressed: _limparFiltros,
                  child:
                      const Text('Limpar'),
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nomeController,
            textInputAction:
                TextInputAction.search,
            decoration: InputDecoration(
              labelText: 'Pesquisar item',
              hintText: 'Nome do item',
              prefixIcon: const Icon(
                Icons.search,
              ),
              suffixIcon:
                  _nomeController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip:
                              'Limpar pesquisa',
                          onPressed: () {
                            _nomeController.clear();
                          },
                          icon: const Icon(
                            Icons.clear,
                          ),
                        ),
              border:
                  const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _tipoSelecionado,
            decoration:
                const InputDecoration(
              labelText: 'Tipo',
              prefixIcon: Icon(
                Icons.category_outlined,
              ),
              border:
                  OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(
                value: 'Todos',
                child: Text('Todos os tipos'),
              ),
              ...tipos.map(
                (tipo) => DropdownMenuItem(
                  value: tipo,
                  child: Text(tipo),
                ),
              ),
            ],
            onChanged: (valor) {
              if (valor == null) {
                return;
              }

              setState(() {
                _tipoSelecionado = valor;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(Item item) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 9,
      ),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _abrirItem(item),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            13,
            12,
            7,
            12,
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.orange
                      .withValues(alpha: 0.10),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color:
                      Colors.orange.shade800,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nome,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 6,
                      runSpacing: 5,
                      children: [
                        if (item.tipo
                            .trim()
                            .isNotEmpty)
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration:
                                BoxDecoration(
                              color: Colors.orange
                                  .withValues(
                                alpha: 0.10,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20,
                              ),
                            ),
                            child: Text(
                              item.tipo,
                              style: TextStyle(
                                color: Colors
                                    .orange
                                    .shade900,
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ),
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                Colors.grey.shade100,
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Text(
                            '${item.custoEmCreditos} Cr',
                            style:
                                const TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (item.descricao
                        .trim()
                        .isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          top: 5,
                        ),
                        child: Text(
                          item.descricao,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                                Colors.grey.shade700,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Editar item',
                onPressed: () =>
                    _editarItem(item),
                icon: const Icon(
                  Icons.edit_outlined,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.black45,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Itens'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Itens'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _carregarItens,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregarItens,
        child: Column(
          children: [
            _buildFiltros(),
            Expanded(
              child: _itensFiltrados.isEmpty
                  ? ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding:
                          const EdgeInsets.all(24),
                      children: [
                        const SizedBox(
                          height: 45,
                        ),
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 58,
                          color:
                              Colors.grey.shade400,
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        Center(
                          child: Text(
                            _itens.isEmpty
                                ? 'Nenhum item cadastrado.'
                                : 'Nenhum item encontrado.',
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ),
                        if (_itens.isEmpty) ...[
                          const SizedBox(height: 8),
                          const Center(
                            child: Text(
                              'Use o botão + para cadastrar o primeiro item.',
                              textAlign:
                                  TextAlign.center,
                              style: TextStyle(
                                color:
                                    Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ],
                    )
                  : ListView.builder(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding:
                          const EdgeInsets.fromLTRB(
                        12,
                        12,
                        12,
                        90,
                      ),
                      itemCount:
                          _itensFiltrados.length,
                      itemBuilder:
                          (context, index) {
                        return _buildItem(
                          _itensFiltrados[index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _adicionarItem,
        icon: const Icon(Icons.add),
        label: const Text(
          'Adicionar Item',
        ),
      ),
    );
  }
}
