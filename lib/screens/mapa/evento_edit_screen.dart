import 'package:flutter/material.dart';

import '../bestiario/criatura_editar_screen.dart';
import '../npcs/npc_edit_screen.dart';
import '../itens/item_editar_screen.dart';
import '../../models/npc.dart';
import '../../repositories/npcs_repository.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/evento.dart';
import '../../models/item.dart';
import '../../models/criatura.dart';
import '../../repositories/itens_repository.dart';
import '../../repositories/criaturas_repository.dart';

class EventoEditScreen extends StatefulWidget {
  final Evento? evento;

  const EventoEditScreen({super.key, this.evento});

  @override
  State<EventoEditScreen> createState() => _EventoEditScreenState();
}

class _EventoEditScreenState extends State<EventoEditScreen> {
  final CriaturasRepository _criaturasRepository = CriaturasRepository();

  late final TextEditingController _nome;
  late final TextEditingController _descricao;
  late final TextEditingController _inicio;
  late final TextEditingController _duracao;
  late final TextEditingController _efeitos;

  Criatura? _criatura;
  String _nivelCriatura = '';
  String _nomeCriatura = 'Criatura';
  String _nomePersonagens = 'Personagens';
  String _nomeAliados = 'Aliados';
  String _nomeInimigos = 'Inimigos';
  List<String> _aliados = [];
  List<String> _inimigos = [];
  List<NPC> _personagensDisponiveis = [];
  List<Item> _itens = [];

  @override
  void initState() {
    super.initState();

    final evento = widget.evento;
    _nome = TextEditingController(text: evento?.nome ?? '');
    _descricao = TextEditingController(text: evento?.descricao ?? '');
    _inicio = TextEditingController(text: evento?.inicio ?? '');
    _duracao = TextEditingController(text: evento?.duracao ?? '');
    _efeitos = TextEditingController(text: evento?.efeito ?? '');

    _criatura = evento?.criatura;
    _nivelCriatura = evento?.nivelCriatura ?? '';
    _aliados = List<String>.from(evento?.aliados ?? const []);
    _inimigos = List<String>.from(evento?.inimigos ?? const []);
    _itens = List<Item>.from(evento?.itens ?? const []);

    _carregarNomeCriatura();
  }

  Future<void> _carregarNomeCriatura() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    String carregarNome(String chave, String padrao) {
      final valor = prefs.getString(chave)?.trim();
      return valor == null || valor.isEmpty ? padrao : valor;
    }

    setState(() {
      _nomeCriatura = carregarNome('nome_criatura', 'Criatura');
      _nomePersonagens = carregarNome('menu_personagens', 'Personagens');
      _nomeAliados = carregarNome('menu_aliados', 'Aliados');
      _nomeInimigos = carregarNome('menu_inimigos', 'Inimigos');
    });
  }

  @override
  void dispose() {
    _nome.dispose();
    _descricao.dispose();
    _inicio.dispose();
    _duracao.dispose();
    _efeitos.dispose();
    super.dispose();
  }

  Widget _campo(String titulo, TextEditingController controller,
      {int linhas = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        minLines: linhas,
        maxLines: linhas == 1 ? 1 : null,
        decoration: InputDecoration(
          labelText: titulo,
          border: const OutlineInputBorder(),
          alignLabelWithHint: linhas > 1,
        ),
      ),
    );
  }

  Widget _secao(String titulo, List<Widget> filhos) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14),
            ...filhos,
          ],
        ),
      ),
    );
  }

  Future<T?> _escolher<T>({
    required String titulo,
    required List<T> opcoes,
    required String Function(T) rotulo,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: SizedBox(
          width: double.maxFinite,
          child: opcoes.isEmpty
              ? const Text('Nenhum cadastro disponÁƒÂ­vel.')
              : ListView(
                  shrinkWrap: true,
                  children: opcoes
                      .map((opcao) => ListTile(
                            title: Text(rotulo(opcao)),
                            onTap: () => Navigator.pop(context, opcao),
                          ))
                      .toList(),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _adicionarCriatura() async {
    final lista = await _criaturasRepository.carregar();
    if (!mounted) return;

    final escolhida = await _escolher<Criatura>(
      titulo: 'Adicionar $_nomeCriatura',
      opcoes: lista,
      rotulo: (c) => c.nome,
    );

    if (escolhida == null || !mounted) return;

    setState(() {
      _criatura = escolhida.comNivel(escolhida.nivel,
          valoresPlanilhaFixos: escolhida.valoresPlanilhaFixos);
      if (_nivelCriatura.isEmpty) {
        _nivelCriatura = escolhida.nivel.toString();
      }
    });
  }

  Future<void> _criarCriatura() async {
    final nova = Criatura(
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
          criatura: nova,
          novo: true,
        ),
      ),
    );

    if (resultado != null && mounted) {
      setState(() {
        _criatura = resultado;
        _nivelCriatura = resultado.nivel.toString();
      });
    }
  }

  Future<void> _editarCriatura() async {
    final criaturaAtual = _criatura;
    if (criaturaAtual == null) return;

    final resultado = await Navigator.push<Criatura>(
      context,
      MaterialPageRoute(
        builder: (_) => CriaturaEditarScreen(
          criatura: criaturaAtual,
          salvarNoRepositorio: false,
        ),
      ),
    );

    if (resultado != null && mounted) {
      setState(() {
        _criatura = resultado.comNivel(
          resultado.nivel,
          valoresPlanilhaFixos: resultado.valoresPlanilhaFixos,
        );
        _nivelCriatura = resultado.nivel.toString();
      });
    }
  }

  Future<void> _adicionarPersonagem(bool aliado) async {
    final personagens = await NPCsRepository().carregar();
    if (!mounted) return;

    final bases = personagens
        .where((p) => p.cadastroBaseId == null)
        .where((p) => p.id.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

    final escolhidos = await showDialog<List<NPC>>(
      context: context,
      builder: (dialogContext) {
        final selecionados = <String>{};
        var filtro = '';
        return StatefulBuilder(
          builder: (context, atualizarDialogo) => AlertDialog(
            title: Text('Adicionar ${aliado ? _nomeAliados : _nomeInimigos}'),
            content: SizedBox(
              width: double.maxFinite,
              height: 420,
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Buscar $_nomePersonagens',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (valor) =>
                        atualizarDialogo(() => filtro = valor),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: bases
                          .where((p) => p.nome
                              .toLowerCase()
                              .contains(filtro.toLowerCase()))
                          .map((p) => CheckboxListTile(
                                value: selecionados.contains(p.id),
                                title: Text(p.nome),
                                onChanged: (marcado) => atualizarDialogo(() {
                                  if (marcado == true) {
                                    selecionados.add(p.id);
                                  } else {
                                    selecionados.remove(p.id);
                                  }
                                }),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(
                  dialogContext,
                  bases.where((p) => selecionados.contains(p.id)).toList(),
                ),
                child: const Text('Adicionar selecionados'),
              ),
            ],
          ),
        );
      },
    );

    if (escolhidos == null || !mounted) return;

    setState(() {
      final destino = aliado ? _aliados : _inimigos;
      for (final personagem in escolhidos) {
        if (!destino.contains(personagem.id)) {
          destino.add(personagem.id);
        }
      }
      _personagensDisponiveis = bases;
    });
  }

  Future<void> _criarPersonagem(bool aliado) async {
    final novo = NPC(
      id: '',
      nome: '',
      tipo: aliado ? 'Aliado' : 'Inimigo',
      descricao: '',
    );

    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NPCEditScreen(npc: novo, novo: true),
      ),
    );

    if (!mounted) return;

    final personagens = await NPCsRepository().carregar();
    if (!mounted) return;

    final bases = personagens
        .where((p) => p.cadastroBaseId == null && p.id.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

    final escolhidos = await showDialog<List<NPC>>(
      context: context,
      builder: (dialogContext) {
        final selecionados = <String>{};
        var filtro = '';
        return StatefulBuilder(
          builder: (context, atualizarDialogo) => AlertDialog(
            title: const Text('Selecionar Personagem criado'),
            content: SizedBox(
              width: double.maxFinite,
              height: 420,
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Buscar $_nomePersonagens',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (valor) =>
                        atualizarDialogo(() => filtro = valor),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: bases
                          .where((p) => p.nome
                              .toLowerCase()
                              .contains(filtro.toLowerCase()))
                          .map((p) => CheckboxListTile(
                                value: selecionados.contains(p.id),
                                title: Text(p.nome),
                                onChanged: (marcado) => atualizarDialogo(() {
                                  if (marcado == true) {
                                    selecionados.add(p.id);
                                  } else {
                                    selecionados.remove(p.id);
                                  }
                                }),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(
                  dialogContext,
                  bases.where((p) => selecionados.contains(p.id)).toList(),
                ),
                child: const Text('Adicionar selecionados'),
              ),
            ],
          ),
        );
      },
    );

    if (escolhidos == null || !mounted) return;
    setState(() {
      final destino = aliado ? _aliados : _inimigos;
      for (final personagem in escolhidos) {
        if (!destino.contains(personagem.id)) {
          destino.add(personagem.id);
        }
      }
      _personagensDisponiveis = bases;
    });
  }

  Future<void> _adicionarItem() async {
    final lista = await ItensRepository().carregar();
    if (!mounted) return;

    final escolhido = await showDialog<Item>(
      context: context,
      builder: (_) => _SelecionarItemEventoDialog(itens: lista),
    );

    if (escolhido == null || !mounted) return;

    final quantidade = await _solicitarQuantidade();
    if (quantidade == null || !mounted) return;

    setState(() {
      _itens.add(escolhido.copyWith(quantidade: quantidade));
    });
  }

  Future<int?> _solicitarQuantidade({int inicial = 1}) async {
    final controller = TextEditingController(text: inicial.toString());

    final resultado = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Quantidade do item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Quantidade',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final valor = int.tryParse(controller.text.trim());
              if (valor == null || valor < 1) return;
              Navigator.pop(dialogContext, valor);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    controller.dispose();
    return resultado;
  }

  Future<void> _criarItem() async {
    final criado = await Navigator.push<Item>(
      context,
      MaterialPageRoute(
        builder: (_) => ItemEditarScreen(
          item: const Item(
            nome: '',
            tipo: '',
            custoEmCreditos: 0,
            efeito: '',
          ),
          novo: true,
        ),
      ),
    );

    if (criado == null || !mounted) return;

    final quantidade = await _solicitarQuantidade();
    if (quantidade == null || !mounted) return;

    setState(() {
      _itens.add(criado.copyWith(quantidade: quantidade));
    });
  }

  List<Widget> _tilesPersonagens(List<String> ids, bool aliado) {
    return [
      if (ids.isNotEmpty)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ids.map((id) {
            final personagem =
                _personagensDisponiveis.where((p) => p.id == id).firstOrNull;
            final nome = personagem?.nome ?? id;
            return SizedBox(
              width: 104,
              height: 104,
              child: Card(
                child: InkWell(
                  onTap: () => setState(() {
                    (aliado ? _aliados : _inimigos).remove(id);
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Center(
                      child: Text(
                        nome,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
    ];
  }

  void _salvar() {
    final antigo = widget.evento;

    Navigator.pop(
      context,
      Evento(
        id: antigo?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        nome: _nome.text.trim(),
        descricao: _descricao.text.trim(),
        cadastroBaseId: antigo?.cadastroBaseId,
        localizacao: antigo?.localizacao ?? '',
        localizacaoTipo: antigo?.localizacaoTipo ?? 'nenhuma',
        localizacaoId: antigo?.localizacaoId ?? '',
        legua: antigo?.legua,
        efeito: _efeitos.text.trim(),
        inicio: _inicio.text.trim(),
        duracao: _duracao.text.trim(),
        aliados: List<String>.from(_aliados),
        inimigos: List<String>.from(_inimigos),
        criatura: _criatura,
        nivelCriatura: _nivelCriatura,
        itens: List<Item>.from(_itens),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evento')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _campo('Nome', _nome),
            _campo('Descrição', _descricao, linhas: 3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _campo('Início', _inicio)),
                const SizedBox(width: 10),
                Expanded(child: _campo('Duração', _duracao)),
              ],
            ),
            _campo('Efeitos', _efeitos, linhas: 3),
            _secao(_nomeCriatura, [
              if (_criatura != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _editarCriatura,
                        icon: const Icon(Icons.pets),
                        label: Text(
                          _criatura!.nome,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Editar criatura',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: _editarCriatura,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _adicionarCriatura,
                      child: const Text('Adicionar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: _criarCriatura,
                      child: const Text('Criar'),
                    ),
                  ),
                ],
              ),
            ]),
            _secao(_nomeAliados, [
              ..._tilesPersonagens(_aliados, true),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _adicionarPersonagem(true),
                      child: const Text('Adicionar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () => _criarPersonagem(true),
                      child: const Text('Criar'),
                    ),
                  ),
                ],
              ),
            ]),
            _secao(_nomeInimigos, [
              ..._tilesPersonagens(_inimigos, false),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _adicionarPersonagem(false),
                      child: const Text('Adicionar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () => _criarPersonagem(false),
                      child: const Text('Criar'),
                    ),
                  ),
                ],
              ),
            ]),
            _secao('Item', [
              if (_itens.isNotEmpty)
                ..._itens.asMap().entries.map(
                      (entrada) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${entrada.value.nome} x${entrada.value.quantidade}',
                        ),
                        trailing: Wrap(
                          spacing: 0,
                          children: [
                            IconButton(
                              tooltip: 'Alterar quantidade',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () async {
                                final quantidade = await _solicitarQuantidade(
                                  inicial: entrada.value.quantidade,
                                );
                                if (quantidade == null || !mounted) return;
                                setState(() {
                                  _itens[entrada.key] = entrada.value.copyWith(
                                    quantidade: quantidade,
                                  );
                                });
                              },
                            ),
                            IconButton(
                              tooltip: 'Remover',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => setState(
                                () => _itens.removeAt(entrada.key),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _adicionarItem,
                      child: const Text('Adicionar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: _criarItem,
                      child: const Text('Criar'),
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Evento'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelecionarItemEventoDialog extends StatefulWidget {
  final List<Item> itens;

  const _SelecionarItemEventoDialog({required this.itens});

  @override
  State<_SelecionarItemEventoDialog> createState() =>
      _SelecionarItemEventoDialogState();
}

class _SelecionarItemEventoDialogState
    extends State<_SelecionarItemEventoDialog> {
  final TextEditingController _busca = TextEditingController();

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final termo = _busca.text.trim().toLowerCase();
    final itens = widget.itens
        .where((item) => item.nome.toLowerCase().contains(termo))
        .toList()
      ..sort(
        (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
      );

    return AlertDialog(
      title: const Text('Adicionar Item'),
      content: SizedBox(
        width: 520,
        height: 460,
        child: Column(
          children: [
            TextField(
              controller: _busca,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Buscar item',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: itens.isEmpty
                  ? const Center(child: Text('Nenhum item encontrado.'))
                  : ListView.separated(
                      itemCount: itens.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = itens[index];
                        return ListTile(
                          leading: const Icon(Icons.inventory_2_outlined),
                          title: Text(item.nome),
                          subtitle: Text(
                            item.tipo.isEmpty ? 'Sem tipo' : item.tipo,
                          ),
                          onTap: () => Navigator.pop(context, item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
