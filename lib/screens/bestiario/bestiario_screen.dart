import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/criatura.dart';
import '../../repositories/criaturas_repository.dart';
import 'criatura_detalhe_screen.dart';
import 'criatura_editar_screen.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  final CriaturasRepository _repository = CriaturasRepository();

  final TextEditingController _pesquisaController = TextEditingController();

  List<Criatura> _criaturas = [];

  bool _carregando = true;
  String _nomeMenu = 'Bestiário';
  String _pesquisa = '';

  @override
  void initState() {
    super.initState();
    _carregar();
    _carregarNomeMenu();
    _pesquisaController.addListener(_atualizarPesquisa);
  }

  @override
  void dispose() {
    _pesquisaController.removeListener(_atualizarPesquisa);
    _pesquisaController.dispose();
    super.dispose();
  }

  Future<void> _carregarNomeMenu() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      final nome = prefs.getString('menu_bestiario')?.trim() ?? '';
      _nomeMenu = nome.isEmpty ? 'Bestiário' : nome;
    });
  }

  Future<void> _carregar() async {
    try {
      final criaturas = await _repository.carregar();

      _ordenarCriaturas(criaturas);

      if (!mounted) {
        return;
      }

      setState(() {
        _criaturas = criaturas;
        _carregando = false;
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
            'Erro ao carregar Criatura: $e',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _ordenarCriaturas(List<Criatura> criaturas) {
    criaturas.sort((a, b) {
      final numeroA = a.numero;
      final numeroB = b.numero;

      if (numeroA != null && numeroB != null) {
        return numeroA.compareTo(numeroB);
      }

      if (numeroA != null) {
        return -1;
      }

      if (numeroB != null) {
        return 1;
      }

      return a.nome.toLowerCase().compareTo(
            b.nome.toLowerCase(),
          );
    });
  }

  Future<void> _adicionarCriatura() async {
    final novoCriatura = Criatura(
      nome: '',
      numero: null,
      nivel: 1,
      lendario: false,
      tipos: const [],
      superEfetivo: '',
      poucoEfetivo: '',
      imune: '',
      efetividadeTipo: '',
      forca: 0,
      habilidade: 0,
      resistencia: 0,
      armadura: 0,
      defesaEspecial: 0,
      poderDeFogo: 0,
      moves: const [],
      pontosMoveProgressao: 0,
      poderes: const [],
      poderesExtras: 0,
      pv: 0,
      pe: 0,
      localizacao: '',
    );

    final resultado = await Navigator.push<Criatura>(
      context,
      MaterialPageRoute(
        builder: (_) => CriaturaEditarScreen(
          criatura: novoCriatura,
          novo: true,
        ),
      ),
    );

    if (resultado != null && mounted) {
      await _carregar();
    }
  }

  Future<void> _editarCriatura(
    Criatura criatura,
  ) async {
    final resultado = await Navigator.push<Criatura>(
      context,
      MaterialPageRoute(
        builder: (_) => CriaturaEditarScreen(
          criatura: criatura,
        ),
      ),
    );

    if (resultado != null && mounted) {
      await _carregar();
    }
  }

  Future<bool> _confirmarExclusao(
    Criatura criatura,
  ) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Criatura?'),
          content: Text(
            'O Criatura "${criatura.nome}" será removido apenas do armazenamento local do aplicativo.\n\nA planilha não será alterada.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    return resultado == true;
  }

  Future<void> _excluirCriatura(
    Criatura criatura,
  ) async {
    final confirmar = await _confirmarExclusao(criatura);

    if (!confirmar || !mounted) {
      return;
    }

    await _repository.remover(criatura.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _criaturas.removeWhere(
        (item) => item.id == criatura.id,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Criatura ${criatura.nome} excluído.',
        ),
      ),
    );
  }

  void _atualizarPesquisa() {
    setState(() {
      _pesquisa = _pesquisaController.text.trim().toLowerCase();
    });
  }

  List<Criatura> get _criaturasFiltrados {
    final filtrados = _pesquisa.isEmpty
        ? List<Criatura>.from(_criaturas)
        : _criaturas.where((criatura) {
            return criatura.nome.toLowerCase().contains(_pesquisa);
          }).toList();

    _ordenarCriaturas(filtrados);

    return filtrados;
  }

  Future<void> _abrirCriatura(
    Criatura criatura,
  ) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CriaturaDetalheScreen(
          criatura: criatura,
          nivelAlteravel: true,
          onDelete: () => _excluirCriatura(criatura),
        ),
      ),
    );

    if (resultado == true && mounted) {
      await _carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    if (_carregando) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_nomeMenu),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_criaturas.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_nomeMenu),
        ),
        body: const Center(
          child: Text(
            'Nenhum cadastro.',
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _adicionarCriatura,
          icon: const Icon(Icons.add),
          label: const Text('Adicionar Cadastro'),
        ),
      );
    }

    final criaturasFiltrados = _criaturasFiltrados;

    return Scaffold(
      appBar: AppBar(
        title: Text(_nomeMenu),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _carregar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            100,
          ),
          itemCount: criaturasFiltrados.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildPesquisa(
                tema,
                cores,
                criaturasFiltrados.length,
              );
            }

            final criatura = criaturasFiltrados[index - 1];

            return Padding(
              padding: const EdgeInsets.only(
                bottom: 8,
              ),
              child: _buildCriaturaResumo(
                criatura,
                tema,
                cores,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionarCriatura,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Cadastro'),
      ),
    );
  }

  Widget _buildPesquisa(
    ThemeData tema,
    ColorScheme cores,
    int quantidade,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.search,
                size: 20,
                color: cores.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Pesquisar',
                style: tema.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '$quantidade Cadastros',
                style: tema.textTheme.bodySmall?.copyWith(
                  color: cores.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _pesquisaController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Digite o nome do Criatura...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _pesquisaController.text.isNotEmpty
                  ? IconButton(
                      tooltip: 'Limpar pesquisa',
                      onPressed: () {
                        _pesquisaController.clear();
                      },
                      icon: const Icon(
                        Icons.clear,
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
          if (_pesquisa.isNotEmpty && _criaturasFiltrados.isEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cores.surfaceContainerHighest.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 40,
                    color: cores.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nenhum Criatura encontrado',
                    style: tema.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Não há Criatura com o nome '
                    '“$_pesquisa”.',
                    textAlign: TextAlign.center,
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: cores.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCriaturaResumo(
    Criatura criatura,
    ThemeData tema,
    ColorScheme cores,
  ) {
    final numeroTexto = criatura.numero == null
        ? null
        : '#${criatura.numero!.toString().padLeft(3, '0')}';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _abrirCriatura(criatura),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          child: Row(
            children: [
              if (numeroTexto != null)
                SizedBox(
                  width: 46,
                  child: Text(
                    numeroTexto,
                    style: tema.textTheme.titleSmall?.copyWith(
                      color: cores.onSurfaceVariant,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      criatura.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (criatura.tipos.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: criatura.tipos
                            .map(
                              (tipo) => _buildTipoChip(
                                tipo,
                                cores,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Editar Criatura',
                onPressed: () => _editarCriatura(criatura),
                icon: const Icon(
                  Icons.edit,
                ),
              ),
              const Icon(
                Icons.chevron_right,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipoChip(
    String tipo,
    ColorScheme cores,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: cores.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tipo,
        style: TextStyle(
          color: cores.onSecondaryContainer,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
