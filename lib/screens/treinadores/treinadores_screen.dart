import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/npc.dart';
import '../../repositories/npcs_repository.dart';
import '../npcs/npc_edit_screen.dart';
import '../npcs/npc_screen.dart';

class TreinadoresScreen extends StatefulWidget {
  const TreinadoresScreen({super.key});

  @override
  State<TreinadoresScreen> createState() =>
      _TreinadoresScreenState();
}

class _TreinadoresScreenState
    extends State<TreinadoresScreen> {
  final NPCsRepository _repository =
      NPCsRepository();

  final TextEditingController _pesquisaController =
      TextEditingController();

  List<NPC> _npcs = [];
  bool _carregando = true;
  String _nomeMenu = 'Personagens';
  String _pesquisa = '';
  String _tipoSelecionado = 'Todos';

  @override
  void initState() {
    super.initState();
    _carregar();
    _carregarNomeMenu();
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  Future<void> _carregarNomeMenu() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      final nome = prefs.getString('menu_personagens')?.trim() ?? '';
      _nomeMenu = nome.isEmpty ? 'Personagens' : nome;
    });
  }
  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
    });

    try {
      final npcs = await _repository.carregar();

      if (!mounted) {
        return;
      }

      setState(() {
        _npcs = npcs;
        _carregando = false;

        if (_tipoSelecionado != 'Todos' &&
            !_tipos.contains(_tipoSelecionado)) {
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
            'Não foi possível carregar os treinadores: $e',
          ),
        ),
      );
    }
  }

  List<String> get _tipos {
    final tipos = _npcs
        .map(
          (npc) => npc.tipo.trim(),
        )
        .where(
          (tipo) => tipo.isNotEmpty,
        )
        .toSet()
        .toList();

    tipos.sort(
      (a, b) => a.toLowerCase().compareTo(
        b.toLowerCase(),
      ),
    );

    return tipos;
  }

  List<NPC> get _npcsFiltrados {
    final pesquisa = _normalizar(_pesquisa);

    final resultado = _npcs.where((npc) {
      final nome = _normalizar(npc.nome);

      final correspondeNome =
          pesquisa.isEmpty ||
          nome.contains(pesquisa);

      final correspondeTipo =
          _tipoSelecionado == 'Todos' ||
          npc.tipo.trim() == _tipoSelecionado;

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

  String _normalizar(String texto) {
    return texto
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(
          RegExp(r'[^a-z0-9]'),
          '',
        );
  }

  Future<void> _adicionarTreinador() async {
    final novo = NPC(
      id: DateTime.now()
          .microsecondsSinceEpoch
          .toString(),
      nome: '',
      descricao: '',
    );

    final resultado =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NPCEditScreen(
          npc: novo,
          novo: true,
        ),
      ),
    );

    if (resultado == true && mounted) {
      await _carregar();
    }
  }

  Future<void> _editarTreinador(NPC npc) async {
    final resultado =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NPCEditScreen(
          npc: npc,
        ),
      ),
    );

    if (resultado == true && mounted) {
      await _carregar();
    }
  }

  Future<void> _abrirTreinador(NPC npc) async {
    final resultado =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NPCScreen(
          npcId: npc.id,
        ),
      ),
    );

    if (resultado == true && mounted) {
      await _carregar();
    }
  }

  Widget _buildFiltros() {
    final filtrados = _npcsFiltrados;

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
              const Icon(
                Icons.manage_search,
                color: Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${filtrados.length} Cadastros',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (_pesquisa.isNotEmpty ||
                  _tipoSelecionado != 'Todos')
                TextButton(
                  onPressed: () {
                    setState(() {
                      _pesquisaController.clear();
                      _pesquisa = '';
                      _tipoSelecionado = 'Todos';
                    });
                  },
                  child: const Text('Limpar'),
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _pesquisaController,
            onChanged: (valor) {
              setState(() {
                _pesquisa = valor;
              });
            },
            decoration: InputDecoration(
              labelText: 'Pesquisar',
              hintText: 'Nome do treinador',
              prefixIcon: const Icon(
                Icons.search,
              ),
              suffixIcon:
                  _pesquisaController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar pesquisa',
                          onPressed: () {
                            _pesquisaController.clear();
                            setState(() {
                              _pesquisa = '';
                            });
                          },
                          icon: const Icon(
                            Icons.clear,
                          ),
                        ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _tipoSelecionado,
            decoration: const InputDecoration(
              labelText: 'Tipo',
              prefixIcon: Icon(
                Icons.category_outlined,
              ),
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(
                value: 'Todos',
                child: Text('Todos os tipos'),
              ),
              ..._tipos.map(
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

  Widget _buildTreinador(NPC npc) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 9,
      ),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _abrirTreinador(npc),
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
                  color: Colors.red.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.red,
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
                      npc.nome,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    if (npc.tipo.trim().isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          top: 5,
                        ),
                        child: Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red
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
                            npc.tipo,
                            style:
                                const TextStyle(
                              color: Colors.red,
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    if (npc.descricao
                        .trim()
                        .isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          top: 5,
                        ),
                        child: Text(
                          npc.descricao,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey
                                .shade700,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip:
                    'Editar treinador',
                onPressed: () =>
                    _editarTreinador(npc),
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
          title: Text(_nomeMenu),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_nomeMenu),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _carregar,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: Column(
          children: [
            _buildFiltros(),
            Expanded(
              child: _npcsFiltrados.isEmpty
                  ? ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding:
                          const EdgeInsets.all(24),
                      children: [
                        const SizedBox(height: 45),
                        Icon(
                          Icons.person_search,
                          size: 58,
                          color:
                              Colors.grey.shade400,
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: Text(
                            _npcs.isEmpty
                                ? 'Nenhum treinador cadastrado.'
                                : 'Nenhum treinador encontrado.',
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
                        if (_npcs.isEmpty) ...[
                          const SizedBox(height: 8),
                          const Center(
                            child: Text(
                              'Use o botão + para cadastrar o primeiro treinador.',
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
                          _npcsFiltrados.length,
                      itemBuilder:
                          (context, index) {
                        return _buildTreinador(
                          _npcsFiltrados[index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _adicionarTreinador,
        icon: const Icon(Icons.add),
        label: const Text(
          'Adicionar',
        ),
      ),
    );
  }
}


