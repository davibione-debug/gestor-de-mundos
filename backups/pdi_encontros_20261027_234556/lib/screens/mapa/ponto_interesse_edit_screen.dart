import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../geradores/progressao.dart';
import '../../models/encontro_npc.dart';
import '../../models/evento.dart';
import '../../models/item.dart';
import '../../models/npc.dart';
import '../../models/criatura.dart';
import '../../models/ponto_interesse.dart';
import '../../models/grupo.dart';
import '../../repositories/criaturas_repository.dart';
import '../../repositories/itens_repository.dart';
import '../../repositories/cadastros_repository.dart';
import '../../repositories/npcs_repository.dart';
import '../npcs/npc_edit_screen.dart';
import '../itens/item_editar_screen.dart';
import '../bestiario/criatura_editar_screen.dart';
import 'evento_edit_screen.dart';

class PontoInteresseEditScreen extends StatefulWidget {
  final PontoInteresse ponto;

  const PontoInteresseEditScreen({
    super.key,
    required this.ponto,
  });

  @override
  State<PontoInteresseEditScreen> createState() =>
      _PontoInteresseEditScreenState();
}

class _PontoInteresseEditScreenState extends State<PontoInteresseEditScreen> {
  static const Color _fundo = Color(0xFFF4F1E8);
  static const Color _card = Colors.white;
  static const Color _borda = Color(0xFFD8D3C7);
  static const Color _vermelho = Color(0xFFD64545);
  static const Color _azul = Color(0xFF3D73C9);
  static const Color _amarelo = Color(0xFFE3B341);
  static const Color _laranja = Color(0xFFE07A32);
  static const Color _verde = Color(0xFF4D9B62);
  static const Color _roxo = Color(0xFF7856A8);
  static const Color _texto = Color(0xFF252525);
  static const Color _textoSecundario = Color(0xFF66625B);

  final CriaturasRepository _criaturasRepository = CriaturasRepository();

  late final TextEditingController _nome;
  late final TextEditingController _descricao;
  late final TextEditingController _efeitos;
  late final TextEditingController _nivelCriatura;

  List<Evento> _eventos = [];
  List<NPC> _personagens = [];
  List<Item> _itens = [];
  List<Criatura> _criaturas = [];
  List<Criatura> _criaturasDisponiveis = [];
  List<Grupo> _encontros = [];

  String _rotuloCriatura = 'Criatura';

  @override
  void initState() {
    super.initState();

    _nome = TextEditingController(
      text: widget.ponto.nome,
    );

    _descricao = TextEditingController(
      text: widget.ponto.descricao,
    );

    _efeitos = TextEditingController(
      text: widget.ponto.efeitos,
    );

    _nivelCriatura = TextEditingController(
      text: widget.ponto.nivelCriatura,
    );

    _eventos = List<Evento>.from(widget.ponto.eventos);

    _personagens = List<NPC>.from(widget.ponto.npcs);

    _itens = List<Item>.from(widget.ponto.itens);

    _encontros = List<Grupo>.from(widget.ponto.encontros);
    _criaturas = List<Criatura>.from(widget.ponto.criaturas);

    _carregarConfiguracao();
    _carregarDados();
  }

  @override
  void dispose() {
    _nome.dispose();
    _descricao.dispose();

    _efeitos.dispose();
    _nivelCriatura.dispose();
    super.dispose();
  }

  Future<void> _carregarConfiguracao() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _rotuloCriatura = prefs.getString('nome_criatura') ?? 'Criatura';
    });
  }

  Future<void> _carregarDados() async {
    final criaturas = await _criaturasRepository.carregar();

    if (!mounted) {
      return;
    }

    criaturas.sort(
      (a, b) => a.nome.toLowerCase().compareTo(
            b.nome.toLowerCase(),
          ),
    );

    setState(() {
      _criaturasDisponiveis = criaturas;
    });
  }

  Future<void> _adicionarEventoExistente() async {
    final eventos = await CadastrosRepository().carregarEventos();
    if (!mounted) return;

    final evento = await _selecionarRegistro<Evento>(
      titulo: 'Adicionar evento',
      registros: eventos,
      nome: (e) => e.nome,
      detalhe: (e) => e.descricao,
    );

    if (evento == null || !mounted) return;

    setState(() {
      if (!_eventos.any((e) => e.id == evento.id)) {
        _eventos.add(evento);
      }
    });
  }

  Future<void> _criarEventoBase() async {
    final evento = await Navigator.push<Evento>(
      context,
      MaterialPageRoute(builder: (_) => const EventoEditScreen()),
    );
    if (evento == null || !mounted) return;

    await CadastrosRepository().salvarEvento(evento);
    if (!mounted) return;

    setState(() {
      _eventos.add(evento);
    });
  }

  Future<void> _adicionarPersonagemExistente() async {
    final personagens = await NPCsRepository().carregar();
    if (!mounted) return;

    final bases = personagens
        .where((p) => p.cadastroBaseId == null && p.id.trim().isNotEmpty)
        .toList();

    final npc = await _selecionarRegistro<NPC>(
      titulo: 'Adicionar personagem',
      registros: bases,
      nome: (p) => p.nome,
      detalhe: (p) => p.descricao,
    );

    if (npc == null || !mounted) return;

    setState(() {
      if (!_personagens.any((p) => p.id == npc.id)) {
        _personagens.add(npc);
      }
    });
  }

  Future<void> _criarPersonagemBase() async {
    final antes = (await NPCsRepository().carregar()).map((p) => p.id).toSet();

    if (!mounted) return;

    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NPCEditScreen(
          npc: NPC(id: '', nome: '', tipo: 'Personagem', descricao: ''),
          novo: true,
        ),
      ),
    );

    if (!mounted) return;

    final depois = await NPCsRepository().carregar();
    final novos = depois
        .where((p) =>
            p.cadastroBaseId == null &&
            p.id.trim().isNotEmpty &&
            !antes.contains(p.id))
        .toList();

    if (novos.isEmpty) return;

    final npc = novos.last;
    setState(() {
      if (!_personagens.any((p) => p.id == npc.id)) {
        _personagens.add(npc);
      }
    });
  }

  Future<void> _criarItemBase() async {
    final antes = await ItensRepository().carregar();
    if (!mounted) return;

    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ItemEditarScreen(
          item: const Item(
            nome: '',
            tipo: '',
            descricao: '',
            custoEmCreditos: 0,
            efeito: '',
            localizacao: '',
            quantidade: 1,
          ),
          novo: true,
        ),
      ),
    );

    if (!mounted) return;

    final depois = await ItensRepository().carregar();
    final novos = depois
        .where((item) => !antes.any((anterior) =>
            anterior.nome.trim().toLowerCase() ==
            item.nome.trim().toLowerCase()))
        .toList();

    if (novos.isEmpty) {
      await _editarItem();
      return;
    }

    final escolhido = novos.last;
    if (!mounted) return;

    final resultado = await showDialog<Item>(
      context: context,
      builder: (_) => _ItemDialog(
        item: escolhido.copyWith(quantidade: 1, localizacao: ''),
      ),
    );

    if (resultado == null || !mounted) return;
    setState(() => _itens.add(resultado));
  }

  Future<void> _criarCriaturaBase() async {
    final nova = Criatura(
      nome: '',
      nivel: 1,
      tipos: const [],
      forca: 0,
      habilidade: 0,
      resistencia: 0,
      armadura: 0,
      defesaEspecial: 0,
      poderDeFogo: 0,
      poderes: const [],
    );

    final resultado = await Navigator.push<Criatura>(
      context,
      MaterialPageRoute(
        builder: (_) => CriaturaEditarScreen(
          criatura: nova,
          novo: true,
          salvarNoRepositorio: true,
        ),
      ),
    );

    if (resultado == null || !mounted) return;

    final baseAtualizada = await _criaturasRepository.carregar();
    if (!mounted) return;

    setState(() {
      _criaturasDisponiveis = baseAtualizada;
      _criaturas.add(resultado);
    });
  }

  Future<T?> _selecionarRegistro<T>({
    required String titulo,
    required List<T> registros,
    required String Function(T) nome,
    required String Function(T) detalhe,
  }) async {
    if (registros.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum Cadastro disponível.')),
      );
      return null;
    }

    final busca = TextEditingController();
    try {
      return await showDialog<T>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, atualizar) {
            final filtrados = registros.where((registro) {
              return nome(registro)
                  .toLowerCase()
                  .contains(busca.text.trim().toLowerCase());
            }).toList()
              ..sort((a, b) => nome(a).toLowerCase().compareTo(
                    nome(b).toLowerCase(),
                  ));

            return AlertDialog(
              title: Text(titulo),
              content: SizedBox(
                width: double.maxFinite,
                height: 420,
                child: Column(
                  children: [
                    TextField(
                      controller: busca,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Buscar por nome',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (_) => atualizar(() {}),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtrados.length,
                        itemBuilder: (_, index) {
                          final registro = filtrados[index];
                          final complemento = detalhe(registro);
                          return ListTile(
                            title: Text(nome(registro)),
                            subtitle: complemento.trim().isEmpty
                                ? null
                                : Text(complemento),
                            onTap: () => Navigator.pop(
                              dialogContext,
                              registro,
                            ),
                          );
                        },
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
              ],
            );
          },
        ),
      );
    } finally {
      busca.dispose();
    }
  }

  Future<void> _editarEvento({
    Evento? evento,
  }) async {
    final resultado = await Navigator.push<Evento>(
      context,
      MaterialPageRoute(
        builder: (_) => EventoEditScreen(
          evento: evento,
        ),
      ),
    );

    if (resultado == null || !mounted) {
      return;
    }

    setState(() {
      if (evento == null) {
        _eventos.add(resultado);
      } else {
        final indice = _eventos.indexWhere(
          (item) => item.id == evento.id,
        );

        if (indice >= 0) {
          _eventos[indice] = resultado;
        } else {
          _eventos.add(resultado);
        }
      }
    });
  }

  Future<void> _editarNPC({NPC? npc}) async {
    final resultado = await showDialog<EncontroNPC>(
      context: context,
      builder: (_) => _NPCDialog(
        npc: npc,
        tipo: 'Personagem',
      ),
    );

    if (resultado == null || !mounted) return;

    setState(() {
      if (npc == null) {
        _personagens.add(resultado.npc);
      } else {
        final indice = _personagens.indexWhere((item) => item.id == npc.id);
        if (indice >= 0) {
          _personagens[indice] = resultado.npc;
        } else {
          _personagens.add(resultado.npc);
        }
      }
    });
  }

  Future<void> _editarItem({
    Item? item,
  }) async {
    if (item == null) {
      final itensBase = await ItensRepository().carregar();

      if (!mounted) {
        return;
      }

      if (itensBase.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum Cadastro'),
          ),
        );
        return;
      }

      final itemBase = await showDialog<Item>(
        context: context,
        builder: (context) => _SelecionarItemDialog(
          itens: itensBase,
        ),
      );

      if (itemBase == null || !mounted) {
        return;
      }

      final copia = itemBase.copyWith(
        quantidade: 1,
        localizacao: '',
      );

      final resultado = await showDialog<Item>(
        context: context,
        builder: (_) => _ItemDialog(item: copia),
      );

      if (resultado == null || !mounted) {
        return;
      }

      setState(() {
        _itens.add(resultado);
      });
      return;
    }

    final resultado = await showDialog<Item>(
      context: context,
      builder: (_) => _ItemDialog(
        item: item,
      ),
    );

    if (resultado == null || !mounted) {
      return;
    }

    setState(() {
      final indice = _itens.indexWhere(
        (valor) => valor.nome == item.nome,
      );

      if (indice >= 0) {
        _itens[indice] = resultado;
      }
    });
  }

  Future<void> _excluirEvento(Evento evento) async {
    final confirmar = await _confirmar(
      'Excluir evento?',
      'O evento "" será removido deste ponto.',
    );

    if (confirmar && mounted) {
      setState(() {
        _eventos.removeWhere(
          (valor) => valor.id == evento.id,
        );
      });
    }
  }

  Future<void> _excluirNPC(NPC npc) async {
    final confirmar = await _confirmar(
      'Excluir personagem?',
      'O personagem "${npc.nome}" será removido deste ponto.',
    );

    if (confirmar && mounted) {
      setState(() {
        _personagens.removeWhere((valor) => valor.id == npc.id);
      });
    }
  }

  Future<void> _adicionarCriaturaExistente() async {
    final criaturas = await _criaturasRepository.carregar();
    if (!mounted) return;

    final resultado = await showDialog<Criatura>(
      context: context,
      builder: (_) => _CriaturaDialog(
        criaturas: criaturas,
        nivelPadrao: _nivelCriatura.text.trim().isEmpty
            ? '1'
            : _nivelCriatura.text.trim(),
      ),
    );

    if (resultado == null || !mounted) return;

    setState(() {
      _criaturasDisponiveis = criaturas;
      _criaturas.add(resultado);
    });
  }

  Future<void> _editarCriatura({
    Criatura? criatura,
  }) async {
    final criaturas = List<Criatura>.from(
      _criaturasDisponiveis,
    );

    if (criaturas.isEmpty) {
      final carregados = await _criaturasRepository.carregar();

      if (!mounted) {
        return;
      }

      criaturas.addAll(carregados);
      criaturas.sort(
        (a, b) => a.nome.toLowerCase().compareTo(
              b.nome.toLowerCase(),
            ),
      );
    }

    if (criaturas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nenhum Cadastro',
          ),
        ),
      );
      return;
    }

    final resultado = await showDialog<Criatura>(
      context: context,
      builder: (_) => _CriaturaDialog(
        criaturas: criaturas,
        criatura: criatura,
        nivelPadrao: _nivelCriatura.text.trim().isEmpty
            ? '1'
            : _nivelCriatura.text.trim(),
      ),
    );

    if (resultado == null || !mounted) {
      return;
    }

    setState(() {
      if (criatura == null) {
        _criaturas.add(resultado);
      } else {
        final indice = _criaturas.indexWhere(
          (valor) => valor.id == criatura.id,
        );

        if (indice >= 0) {
          _criaturas[indice] = resultado;
        } else {
          _criaturas.add(resultado);
        }
      }
    });
  }

  Future<void> _excluirItem(Item item) async {
    final confirmar = await _confirmar(
      'Excluir item?',
      'O item "${item.nome}" será removido deste ponto.',
    );

    if (confirmar && mounted) {
      setState(() {
        _itens.removeWhere(
          (valor) => valor.nome == item.nome,
        );
      });
    }
  }

  Future<void> _excluirCriatura(Criatura criatura) async {
    final confirmar = await _confirmar(
      'Excluir Criatura?',
      '${criatura.nome} nível ${criatura.nivel} será removido deste ponto.',
    );

    if (confirmar && mounted) {
      setState(() {
        _criaturas.remove(criatura);
      });
    }
  }

  Future<bool> _confirmar(
    String titulo,
    String mensagem,
  ) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _vermelho,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    return resultado == true;
  }

  void _salvar() {
    final nome = _nome.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Informe o nome do ponto de interesse.',
          ),
        ),
      );
      return;
    }

    final ponto = PontoInteresse(
      id: widget.ponto.id.isNotEmpty
          ? widget.ponto.id
          : DateTime.now().microsecondsSinceEpoch.toString(),
      nome: nome,
      descricao: _descricao.text.trim(),
      efeitos: _efeitos.text.trim(),
      cadastroBaseId: widget.ponto.cadastroBaseId,
      localizacao: widget.ponto.localizacao,
      localizacaoTipo: widget.ponto.localizacaoTipo,
      localizacaoId: widget.ponto.localizacaoId,
      leguas: widget.ponto.leguas,
      eventos: List<Evento>.from(_eventos),
      npcs: [
        ..._personagens,
      ],
      criaturas: List<Criatura>.from(_criaturas),
      nivelCriatura: _nivelCriatura.text.trim(),
      itens: List<Item>.from(_itens),
      encontros: List<Grupo>.from(_encontros),
    );

    Navigator.pop(context, ponto);
  }

  Widget _campoTexto({
    required String label,
    required TextEditingController controller,
    required IconData icone,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icone),
        filled: true,
        fillColor: _card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _borda),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _borda),
        ),
      ),
    );
  }

  Widget _secao(
    String titulo,
    IconData icone,
    Color cor,
    List<Widget> filhos,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: cor.withAlpha(24),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icone,
                  color: cor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: _texto,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...filhos,
        ],
      ),
    );
  }

  Widget _linhaLista({
    required String titulo,
    required String subtitulo,
    required IconData icone,
    required Color cor,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF8F7F3),
      child: ListTile(
        leading: Icon(
          icone,
          color: cor,
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: subtitulo.isEmpty
            ? null
            : Text(
                subtitulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
        onTap: onTap,
        trailing: IconButton(
          tooltip: 'Excluir',
          icon: const Icon(
            Icons.delete_outline,
            color: _vermelho,
          ),
          onPressed: onDelete,
        ),
      ),
    );
  }

  Widget _buildEventos() {
    return _secao(
      'Eventos',
      Icons.warning_amber_rounded,
      _laranja,
      [
        if (_eventos.isEmpty)
          const Text('Nenhum Cadastro',
              style: TextStyle(color: _textoSecundario)),
        ..._eventos.map(
          (evento) => _linhaLista(
            titulo: evento.nome,
            subtitulo: evento.descricao,
            icone: Icons.warning_amber_rounded,
            cor: _laranja,
            onTap: () => _editarEvento(evento: evento),
            onDelete: () => _excluirEvento(evento),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _adicionarEventoExistente,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: _criarEventoBase,
                icon: const Icon(Icons.create_outlined),
                label: const Text('Criar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPersonagens() {
    return _secao(
      'Aliados',
      Icons.people_outline,
      _verde,
      [
        if (_personagens.isEmpty)
          const Text(
            'Nenhum personagem cadastrado.',
            style: TextStyle(color: _textoSecundario),
          ),
        ..._personagens.map(
          (npc) => _linhaLista(
            titulo: npc.nome,
            subtitulo: npc.descricao,
            icone: Icons.person_outline,
            cor: _verde,
            onTap: () => _editarNPC(npc: npc),
            onDelete: () => _excluirNPC(npc),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _adicionarPersonagemExistente,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: _criarPersonagemBase,
                icon: const Icon(Icons.create_outlined),
                label: const Text('Criar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItens() {
    return _secao(
      'Itens',
      Icons.inventory_2_outlined,
      _amarelo,
      [
        if (_itens.isEmpty)
          const Text('Nenhum Cadastro',
              style: TextStyle(color: _textoSecundario)),
        ..._itens.map(
          (item) => _linhaLista(
            titulo: '${item.nome} (Qtd: ${item.quantidade})',
            subtitulo: [
              if (item.tipo.isNotEmpty) item.tipo,
              if (item.efeito.isNotEmpty) item.efeito,
              if (item.localizacao.trim().isNotEmpty)
                'Localização: ${item.localizacao.trim()}',
            ].join(' – '),
            icone: Icons.inventory_2_outlined,
            cor: _amarelo,
            onTap: () => _editarItem(item: item),
            onDelete: () => _excluirItem(item),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _editarItem(),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: _criarItemBase,
                icon: const Icon(Icons.create_outlined),
                label: const Text('Criar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEncontrosPdi() {
    return _secao(
      'Encontros',
      Icons.catching_pokemon,
      _vermelho,
      [
        if (_encontros.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Nenhum grupo de encontros cadastrado.'),
          ),
        ..._encontros.asMap().entries.map(
              (entrada) => Card(
                elevation: 0,
                child: ListTile(
                  leading: const Icon(Icons.catching_pokemon),
                  title: Text(entrada.value.nome),
                  subtitle: Text(
                    'Diurno: ${entrada.value.diurno.length} | '
                    'Noturno: ${entrada.value.noturno.length} | '
                    'Pesca: ${entrada.value.pesca.length} | '
                    'Aquático: ${entrada.value.surfe.length}',
                  ),
                  trailing: IconButton(
                    tooltip: 'Remover grupo',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() => _encontros.removeAt(entrada.key));
                    },
                  ),
                ),
              ),
            ),
        OutlinedButton.icon(
          onPressed: _adicionarGrupoEncontro,
          icon: const Icon(Icons.add),
          label: const Text('Adicionar grupo'),
        ),
      ],
    );
  }

  Future<void> _adicionarGrupoEncontro() async {
    final nomeController = TextEditingController();
    final nome = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo grupo de encontros'),
        content: TextField(
          controller: nomeController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nome do grupo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final valor = nomeController.text.trim();
              if (valor.isNotEmpty) Navigator.pop(context, valor);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    nomeController.dispose();

    if (nome == null || !mounted) return;

    setState(() {
      _encontros.add(
        Grupo(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          nome: nome,
          diurno: const [],
          noturno: const [],
          pesca: const [],
          surfe: const [],
        ),
      );
    });
  }

  Widget _buildCriaturas() {
    return _secao(
      _rotuloCriatura,
      Icons.catching_pokemon,
      _roxo,
      [
        if (_criaturas.isEmpty)
          const Text('Nenhum Cadastro',
              style: TextStyle(color: _textoSecundario)),
        ..._criaturas.map(
          (criatura) => _linhaLista(
            titulo: '${criatura.nome} – Nível ${criatura.nivel}',
            subtitulo: criatura.textoMoves,
            icone: Icons.catching_pokemon,
            cor: _roxo,
            onTap: () => _editarCriatura(criatura: criatura),
            onDelete: () => _excluirCriatura(criatura),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _adicionarCriaturaExistente,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: _criarCriaturaBase,
                icon: const Icon(Icons.create_outlined),
                label: const Text('Criar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: _fundo,
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: _vermelho,
              secondary: _amarelo,
              surface: _card,
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _vermelho,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.ponto.id.isEmpty
                ? 'Criar Ponto de Interesse'
                : 'Editar Ponto de Interesse',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            32,
          ),
          children: [
            _secao(
              'Características',
              Icons.place_outlined,
              _azul,
              [
                _campoTexto(
                  label: 'Nome',
                  controller: _nome,
                  icone: Icons.place_outlined,
                ),
                const SizedBox(height: 12),
                _campoTexto(
                  label: 'Descrição',
                  controller: _descricao,
                  icone: Icons.notes_outlined,
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                _campoTexto(
                  label: 'Efeitos',
                  controller: _efeitos,
                  icone: Icons.auto_awesome_outlined,
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
              ],
            ),
            _buildEncontrosPdi(),
            _buildCriaturas(),
            _buildPersonagens(),
            _buildItens(),
            _buildEventos(),
            const SizedBox(height: 4),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _vermelho,
                  foregroundColor: Colors.white,
                ),
                onPressed: _salvar,
                icon: const Icon(Icons.save),
                label: const Text(
                  'Salvar alterações',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CriaturaDialog extends StatefulWidget {
  final List<Criatura> criaturas;
  final Criatura? criatura;
  final String nivelPadrao;

  const _CriaturaDialog({
    required this.criaturas,
    this.criatura,
    required this.nivelPadrao,
  });

  @override
  State<_CriaturaDialog> createState() => _CriaturaDialogState();
}

class _CriaturaDialogState extends State<_CriaturaDialog> {
  late Criatura _criatura;
  late final TextEditingController _nivel;
  late final TextEditingController _busca;

  @override
  void initState() {
    super.initState();

    final ordenados = List<Criatura>.from(widget.criaturas)
      ..sort(_compararCriaturas);

    _criatura = widget.criatura != null
        ? ordenados.firstWhere(
            (item) => item.id == widget.criatura!.id,
            orElse: () => ordenados.first,
          )
        : ordenados.first;

    _nivel = TextEditingController(
      text: widget.criatura?.nivel.toString() ?? widget.nivelPadrao,
    );

    _busca = TextEditingController();
  }

  @override
  void dispose() {
    _nivel.dispose();
    _busca.dispose();
    super.dispose();
  }

  int _compararCriaturas(
    Criatura a,
    Criatura b,
  ) {
    final numeroA = a.numero ?? 999999;
    final numeroB = b.numero ?? 999999;

    final comparacaoNumero = numeroA.compareTo(numeroB);

    if (comparacaoNumero != 0) {
      return comparacaoNumero;
    }

    return a.nome.toLowerCase().compareTo(
          b.nome.toLowerCase(),
        );
  }

  List<Criatura> _criaturasFiltrados() {
    final busca = _busca.text.trim().toLowerCase();

    final lista = widget.criaturas.where((criatura) {
      if (busca.isEmpty) {
        return true;
      }

      return criatura.nome.toLowerCase().contains(busca);
    }).toList();

    lista.sort(_compararCriaturas);

    return lista;
  }

  String _nomeCriatura(Criatura criatura) {
    final numero = criatura.numero;

    if (numero == null) {
      return criatura.nome;
    }

    return '#${numero.toString().padLeft(3, '0')} ${criatura.nome}';
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _criaturasFiltrados();

    return AlertDialog(
      title: Text(
        widget.criatura == null ? 'Adicionar Criatura' : 'Editar Criatura',
      ),
      content: SizedBox(
        width: 520,
        height: 520,
        child: Column(
          children: [
            TextField(
              controller: _busca,
              decoration: const InputDecoration(
                labelText: 'Buscar Criatura por nome',
                hintText: 'Ex.: Bulbasaur, saur...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtrados.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum Cadastro',
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtrados.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final criatura = filtrados[index];

                        final selecionado = criatura.id == _criatura.id;

                        return ListTile(
                          selected: selecionado,
                          leading: const Icon(
                            Icons.catching_pokemon,
                          ),
                          title: Text(
                            _nomeCriatura(criatura),
                            style: TextStyle(
                              fontWeight: selecionado
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                          ),
                          trailing: selecionado
                              ? const Icon(
                                  Icons.check,
                                  color: _CriaturaDialogState._corSelecao,
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              _criatura = criatura;
                            });
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nivel,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nível',
                prefixIcon: Icon(Icons.trending_up),
                border: OutlineInputBorder(),
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
        FilledButton(
          onPressed: () {
            final nivel = int.tryParse(_nivel.text.trim());

            if (nivel == null || nivel < 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Informe um nível válido.',
                  ),
                ),
              );
              return;
            }

            final criaturaNivelado = _criatura.comNivel(nivel);

            final criaturaFinal = Progressao.aplicarProgressaoNivel(
              criaturaNivelado,
            );

            Navigator.pop(
              context,
              criaturaFinal,
            );
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  static const Color _corSelecao = Color(0xFF7856A8);
}

class _NPCDialog extends StatefulWidget {
  final NPC? npc;
  final String tipo;

  const _NPCDialog({
    required this.npc,
    required this.tipo,
  });

  @override
  State<_NPCDialog> createState() => _NPCDialogState();
}

class _NPCDialogState extends State<_NPCDialog> {
  late final TextEditingController _nome;
  late final TextEditingController _descricao;
  late final TextEditingController _localizacao;
  late final TextEditingController _pv;
  late final TextEditingController _nivelCriatura;

  @override
  void initState() {
    super.initState();

    final npc = widget.npc;

    _nome = TextEditingController(
      text: npc?.nome ?? '',
    );

    _descricao = TextEditingController(
      text: npc?.descricao ?? '',
    );

    _localizacao = TextEditingController(
      text: npc?.localizacao ?? '',
    );

    _pv = TextEditingController(
      text: npc?.pv.toString() ?? '0',
    );

    _nivelCriatura = TextEditingController(
      text: npc?.nivelCriatura ?? '',
    );
  }

  @override
  void dispose() {
    _nome.dispose();
    _descricao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.npc == null
            ? 'Adicionar ${widget.tipo}'
            : 'Editar ${widget.tipo}',
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nome,
                decoration: InputDecoration(
                  labelText: 'Nome do ${widget.tipo}',
                  prefixIcon: const Icon(
                    Icons.person_outline,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descricao,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _localizacao,
                decoration: const InputDecoration(
                  labelText: 'Localização',
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pv,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'PV',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _nivelCriatura,
                      decoration: const InputDecoration(
                        labelText: 'Nível dos Encontros',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final antigo = widget.npc;

            final npc = NPC(
              id: antigo?.id ??
                  DateTime.now().microsecondsSinceEpoch.toString(),
              nome: _nome.text.trim(),
              tipo: antigo?.tipo ?? widget.tipo,
              descricao: _descricao.text.trim(),
              localizacao: _localizacao.text.trim(),
              forca: antigo?.forca ?? 0,
              habilidade: antigo?.habilidade ?? 0,
              inteligencia: antigo?.inteligencia ?? 0,
              resistencia: antigo?.resistencia ?? 0,
              armadura: antigo?.armadura ?? 0,
              poderDeFogo: antigo?.poderDeFogo ?? 0,
              captura: antigo?.captura ?? 0,
              controle: antigo?.controle ?? 0,
              compreensao: antigo?.compreensao ?? 0,
              tratamento: antigo?.tratamento ?? 0,
              ecologia: antigo?.ecologia ?? 0,
              kit: antigo?.kit ?? '',
              manobras: antigo?.manobras ?? '',
              vantagens: antigo?.vantagens ?? '',
              desvantagens: antigo?.desvantagens ?? '',
              criaturas: antigo?.criaturas ?? const [],
              fichasCriatura: antigo?.fichasCriatura ?? const [],
              nivelCriatura: _nivelCriatura.text.trim(),
              inventario: antigo?.inventario ?? '',
              pv: int.tryParse(
                    _pv.text.trim(),
                  ) ??
                  antigo?.pv ??
                  0,
            );

            Navigator.pop(
              context,
              EncontroNPC(
                npc: npc,
                raro: false,
                periodo: null,
                leguaMin: null,
                leguaMax: null,
              ),
            );
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class _SelecionarItemDialog extends StatefulWidget {
  final List<Item> itens;

  const _SelecionarItemDialog({
    required this.itens,
  });

  @override
  State<_SelecionarItemDialog> createState() => _SelecionarItemDialogState();
}

class _SelecionarItemDialogState extends State<_SelecionarItemDialog> {
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
        .where(
          (item) => item.nome.toLowerCase().contains(termo),
        )
        .toList()
      ..sort(
        (a, b) => a.nome.toLowerCase().compareTo(
              b.nome.toLowerCase(),
            ),
      );

    return AlertDialog(
      title: const Text('Selecionar item'),
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
              child: ListView.separated(
                itemCount: itens.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = itens[index];

                  return ListTile(
                    leading: const Icon(
                      Icons.inventory_2_outlined,
                    ),
                    title: Text(item.nome),
                    subtitle: Text(
                      [
                        if (item.tipo.isNotEmpty) item.tipo,
                        if (item.efeito.isNotEmpty) item.efeito,
                      ].join(' – '),
                    ),
                    onTap: () => Navigator.pop(
                      context,
                      item,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemDialog extends StatefulWidget {
  final Item? item;

  const _ItemDialog({
    this.item,
  });

  @override
  State<_ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<_ItemDialog> {
  late final TextEditingController _nome;
  late final TextEditingController _tipo;
  late final TextEditingController _descricao;
  late final TextEditingController _custo;
  late final TextEditingController _efeito;
  late final TextEditingController _localizacao;
  late final TextEditingController _quantidade;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    _nome = TextEditingController(
      text: item?.nome ?? '',
    );

    _tipo = TextEditingController(
      text: item?.tipo ?? '',
    );

    _descricao = TextEditingController(
      text: item?.descricao ?? '',
    );

    _custo = TextEditingController(
      text: item?.custoEmCreditos.toString() ?? '0',
    );

    _efeito = TextEditingController(
      text: item?.efeito ?? '',
    );

    _localizacao = TextEditingController(
      text: item?.localizacao ?? '',
    );
    _quantidade = TextEditingController(
      text: (item?.quantidade ?? 1).toString(),
    );
  }

  @override
  void dispose() {
    _nome.dispose();
    _tipo.dispose();
    _descricao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.item == null ? 'Adicionar item' : 'Editar item',
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nome,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descricao,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _efeito,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Efeito',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _custo,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Custo'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _quantidade,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantidade'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _localizacao,
                decoration: const InputDecoration(labelText: 'Localização'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final antigo = widget.item;
            final quantidade = int.tryParse(_quantidade.text.trim());

            if (quantidade == null || quantidade < 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Quantidade deve ser no mínimo 1.'),
                ),
              );
              return;
            }

            final custo = int.tryParse(_custo.text.trim()) ??
                antigo?.custoEmCreditos ??
                0;

            final resultado = antigo?.copyWith(
                  nome: _nome.text.trim(),
                  tipo: _tipo.text.trim(),
                  descricao: _descricao.text.trim(),
                  custoEmCreditos: custo,
                  efeito: _efeito.text.trim(),
                  localizacao: _localizacao.text.trim(),
                  quantidade: quantidade,
                ) ??
                Item(
                  nome: _nome.text.trim(),
                  tipo: _tipo.text.trim(),
                  descricao: _descricao.text.trim(),
                  custoEmCreditos: custo,
                  efeito: _efeito.text.trim(),
                  localizacao: _localizacao.text.trim(),
                  quantidade: quantidade,
                );

            Navigator.pop(context, resultado);
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
