import 'package:flutter/material.dart';

import '../../models/ponto_interesse.dart';
import '../../repositories/cadastros_repository.dart';
import 'ponto_interesse_edit_screen.dart';

class PontosInteresseCadastroScreen extends StatefulWidget {
  const PontosInteresseCadastroScreen({
    super.key,
  });

  @override
  State<PontosInteresseCadastroScreen> createState() =>
      _PontosInteresseCadastroScreenState();
}

class _PontosInteresseCadastroScreenState
    extends State<PontosInteresseCadastroScreen> {
  final CadastrosRepository _repository =
      CadastrosRepository();

  final TextEditingController _busca =
      TextEditingController();

  List<PontoInteresse> _pontos = [];

  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    final pontos =
        await _repository.carregarPontos();

    if (!mounted) {
      return;
    }

    setState(() {
      _pontos = pontos;
      _carregando = false;
    });
  }

  Future<void> _criar() async {
    final id =
        DateTime.now().microsecondsSinceEpoch.toString();

    final resultado =
        await Navigator.push<PontoInteresse>(
      context,
      MaterialPageRoute(
        builder: (_) => PontoInteresseEditScreen(
          ponto: PontoInteresse(
            id: id,
            nome: '',
            descricao: '',
            localizacao: '',
          ),
        ),
      ),
    );

    if (resultado == null) {
      return;
    }

    await _repository.salvarPonto(resultado);

    if (mounted) {
      await _carregar();
    }
  }

  Future<void> _editar(
    PontoInteresse ponto,
  ) async {
    final resultado =
        await Navigator.push<PontoInteresse>(
      context,
      MaterialPageRoute(
        builder: (_) => PontoInteresseEditScreen(
          ponto: ponto,
        ),
      ),
    );

    if (resultado == null) {
      return;
    }

    await _repository.salvarPonto(resultado);

    if (mounted) {
      await _carregar();
    }
  }

  Future<void> _excluir(
    PontoInteresse ponto,
  ) async {
    final confirmar =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Excluir ponto de interesse?',
          ),
          content: Text(
            '"${ponto.nome}" será removido do cadastro-base.\n\n'
            'As cópias já incluídas nos Locais não serão alteradas.',
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
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    await _repository.removerPonto(ponto.id);

    if (mounted) {
      await _carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final termo =
        _busca.text.trim().toLowerCase();

    final filtrados = _pontos
        .where(
          (ponto) =>
              ponto.nome.toLowerCase().contains(termo),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pontos de Interesse',
        ),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _criar,
        icon: const Icon(Icons.add),
        label: const Text(
          'Criar Ponto de Interesse',
        ),
      ),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    8,
                  ),
                  child: TextField(
                    controller: _busca,
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Buscar ponto de interesse',
                      prefixIcon:
                          Icon(Icons.search),
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: filtrados.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum ponto de interesse cadastrado.',
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            100,
                          ),
                          itemCount:
                              filtrados.length,
                          itemBuilder:
                              (context, index) {
                            final ponto =
                                filtrados[index];

                            return Card(
                              child: ListTile(
                                leading:
                                    const Icon(
                                  Icons
                                      .place_outlined,
                                ),
                                title: Text(
                                  ponto.nome.isEmpty
                                      ? 'Ponto sem nome'
                                      : ponto.nome,
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                                subtitle: Text(
                                  ponto.descricao.isEmpty
                                      ? 'Sem descrição'
                                      : ponto.descricao,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                ),
                                onTap: () =>
                                    _editar(ponto),
                                trailing:
                                    IconButton(
                                  tooltip:
                                      'Excluir',
                                  icon: const Icon(
                                    Icons
                                        .delete_outline,
                                  ),
                                  onPressed: () =>
                                      _excluir(ponto),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
