import 'package:flutter/material.dart';

import '../../models/criatura.dart';
import '../../models/encontro.dart';
import '../../models/encontro_npc.dart';
import '../../models/evento.dart';
import '../../models/grupo.dart';
import '../../models/grupo_npc.dart';
import '../../models/periodo_dia.dart';
import '../../repositories/criaturas_repository.dart';
import '../../repositories/npcs_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/item.dart';
import '../../models/npc.dart';
import '../../models/ponto_interesse.dart';
import '../../repositories/itens_repository.dart';
import '../../repositories/cadastros_repository.dart';
import '../bestiario/criatura_editar_screen.dart';
import '../npcs/npc_edit_screen.dart';
import '../itens/item_editar_screen.dart';
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
  static const Color _texto = Color(0xFF252525);
  static const Color _textoSecundario = Color(0xFF66625B);

  late final TextEditingController _nome;
  late final TextEditingController _descricao;
  late final TextEditingController _efeitos;
  late final TextEditingController _nivelMin;
  late final TextEditingController _nivelMax;

  late final TextEditingController _dadoEncontros;
  late final TextEditingController _dadoEventos;

  Grupo _encontrosCriaturas = const Grupo(
    id: '',
    nome: '',
    diurno: [],
    noturno: [],
    pesca: [],
    surfe: [],
  );
  GrupoNPC _encontrosAliados = const GrupoNPC();
  GrupoNPC _encontrosInimigos = const GrupoNPC();

  String _nomeCriatura = 'Criatura';
  String _menuAliados = 'Aliados';
  String _menuInimigos = 'Inimigos';

  List<Evento> _eventos = [];
  List<NPC> _personagens = []; // Compatibilidade com registros antigos

  List<Item> _itens = [];

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

    _nivelMin = TextEditingController(
      text: widget.ponto.nivelMinCriatura.toString(),
    );

    _nivelMax = TextEditingController(
      text: widget.ponto.nivelMaxCriatura.toString(),
    );

    _dadoEncontros = TextEditingController(
      text: widget.ponto.dadoEncontros,
    );

    _dadoEventos = TextEditingController(
      text: widget.ponto.dadoEventos,
    );

    _encontrosCriaturas = widget.ponto.encontrosCriaturas;
    _encontrosAliados = widget.ponto.encontrosAliados;
    _encontrosInimigos = widget.ponto.encontrosInimigos;

    _carregarNomesConfigurados();

    _eventos = List<Evento>.from(widget.ponto.eventos);

    _personagens = List<NPC>.from(widget.ponto.npcs);

    _itens = List<Item>.from(widget.ponto.itens);
  }

  @override
  void dispose() {
    _nome.dispose();
    _descricao.dispose();

    _efeitos.dispose();
    _nivelMin.dispose();
    _nivelMax.dispose();
    _dadoEncontros.dispose();
    _dadoEventos.dispose();

    super.dispose();
  }

  Future<void> _carregarNomesConfigurados() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _nomeCriatura = prefs.getString('nome_criatura') ?? 'Criatura';
      _menuAliados = prefs.getString('menu_aliados') ?? 'Aliados';
      _menuInimigos = prefs.getString('menu_inimigos') ?? 'Inimigos';
    });
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
        builder: (_) => _ItemQuantidadeDialog(item: copia),
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
      builder: (_) => _ItemQuantidadeDialog(item: item),
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
      nivelMinCriatura: int.tryParse(_nivelMin.text.trim()) ?? 0,
      nivelMaxCriatura: int.tryParse(_nivelMax.text.trim()) ?? 0,
      eventos: List<Evento>.from(_eventos),
      npcs: List<NPC>.from(_personagens),
      aliados: const [],
      inimigos: const [],
      criaturas: const [],
      nivelCriatura: '',
      itens: List<Item>.from(_itens),
      encontros: const [],
      dadoEncontros: _dadoEncontros.text.trim(),
      dadoEventos: _dadoEventos.text.trim(),
      encontrosCriaturas: _encontrosCriaturas,
      encontrosAliados: _encontrosAliados,
      encontrosInimigos: _encontrosInimigos,
    );

    Navigator.pop(context, ponto);
  }

  Future<void> _adicionarEncontro() async {
    final repo = CriaturasRepository();
    final criaturas = await repo.carregar();
    if (!mounted) return;

    if (criaturas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma criatura cadastrada.')),
      );
      return;
    }

    final resultado = await showDialog<Encontro>(
      context: context,
      builder: (_) => _EncontroDialog(
        criaturas: criaturas,
        encontro: null,
        nomeCriatura: _nomeCriatura,
      ),
    );

    if (resultado == null || !mounted) return;

    setState(() {
      _encontrosCriaturas = Grupo(
        id: _encontrosCriaturas.id,
        nome: _encontrosCriaturas.nome,
        diurno: [..._encontrosCriaturas.diurno, resultado],
        noturno: _encontrosCriaturas.noturno,
        pesca: _encontrosCriaturas.pesca,
        surfe: _encontrosCriaturas.surfe,
      );
    });
  }

  Future<void> _excluirEncontro(Encontro encontro) async {
    final confirmar = await _confirmar(
      'Excluir encontro?',
      'O encontro com "${encontro.criatura.nome}" será removido.',
    );
    if (!confirmar || !mounted) return;

    setState(() {
      _encontrosCriaturas = Grupo(
        id: _encontrosCriaturas.id,
        nome: _encontrosCriaturas.nome,
        diurno: _encontrosCriaturas.diurno.where((e) => e != encontro).toList(),
        noturno: _encontrosCriaturas.noturno,
        pesca: _encontrosCriaturas.pesca,
        surfe: _encontrosCriaturas.surfe,
      );
    });
  }

  Future<void> _adicionarNPC({required bool aliado}) async {
    final repo = NPCsRepository();
    final npcs = await repo.carregar();
    if (!mounted) return;

    if (npcs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum personagem cadastrado.')),
      );
      return;
    }

    final resultado = await showDialog<EncontroNPC>(
      context: context,
      builder: (_) => _NPCDialog(
        npcs: npcs,
        encontro: null,
        tipo: aliado ? _menuAliados : _menuInimigos,
      ),
    );

    if (resultado == null || !mounted) return;

    setState(() {
      if (aliado) {
        _encontrosAliados = GrupoNPC(
          diurno: [..._encontrosAliados.diurno, resultado],
          noturno: _encontrosAliados.noturno,
          pesca: _encontrosAliados.pesca,
          surfe: _encontrosAliados.surfe,
        );
      } else {
        _encontrosInimigos = GrupoNPC(
          diurno: [..._encontrosInimigos.diurno, resultado],
          noturno: _encontrosInimigos.noturno,
          pesca: _encontrosInimigos.pesca,
          surfe: _encontrosInimigos.surfe,
        );
      }
    });
  }

  Future<void> _excluirNPC(EncontroNPC encontro, {required bool aliado}) async {
    final confirmar = await _confirmar(
      'Excluir personagem?',
      '"" será removido.',
    );
    if (!confirmar || !mounted) return;

    setState(() {
      if (aliado) {
        _encontrosAliados = GrupoNPC(
          diurno: _encontrosAliados.diurno.where((e) => e != encontro).toList(),
          noturno: _encontrosAliados.noturno,
          pesca: _encontrosAliados.pesca,
          surfe: _encontrosAliados.surfe,
        );
      } else {
        _encontrosInimigos = GrupoNPC(
          diurno:
              _encontrosInimigos.diurno.where((e) => e != encontro).toList(),
          noturno: _encontrosInimigos.noturno,
          pesca: _encontrosInimigos.pesca,
          surfe: _encontrosInimigos.surfe,
        );
      }
    });
  }

  Widget _buildEncontros() {
    final listaCriaturas = _encontrosCriaturas.diurno;
    final listaAliados = _encontrosAliados.diurno;
    final listaInimigos = _encontrosInimigos.diurno;

    return _secao(
      'Encontros',
      Icons.pets,
      _vermelho,
      [
        TextField(
          controller: _dadoEncontros,
          maxLines: 1,
          decoration: InputDecoration(
            labelText: 'Resultado dos dados',
            hintText: 'Ex.: 1-3 Nada, 4-5 Criatura, 6 Personagem',
            prefixIcon: const Icon(Icons.casino_outlined),
            filled: true,
            fillColor: const Color(0xFFF8F7F3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _borda),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _borda),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (listaCriaturas.isEmpty)
          const Text(
            'Nenhuma criatura cadastrada.',
            style: TextStyle(color: _textoSecundario),
          ),
        ...listaCriaturas.map(
          (e) => _linhaLista(
            titulo: e.criatura.nome,
            subtitulo: _resumoEncontro(e),
            icone: Icons.pets,
            cor: _vermelho,
            onTap: () {},
            onDelete: () => _excluirEncontro(e),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _adicionarEncontro,
                icon: const Icon(Icons.library_add_outlined),
                label: Text('Adicionar $_nomeCriatura'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _criarCriatura,
                icon: const Icon(Icons.add),
                label: Text('Criar $_nomeCriatura'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (listaAliados.isEmpty)
          Text('Nenhum cadastro de ${_menuAliados.toLowerCase()}.',
              style: const TextStyle(color: _textoSecundario)),
        ...listaAliados.map(
          (e) => _linhaLista(
            titulo: e.npc.nome,
            subtitulo: _resumoNPC(e),
            icone: Icons.person_outline,
            cor: _azul,
            onTap: () {},
            onDelete: () => _excluirNPC(e, aliado: true),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _adicionarNPC(aliado: true),
                icon: const Icon(Icons.library_add_outlined),
                label: Text('Adicionar $_menuAliados'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _criarNPC(aliado: true),
                icon: const Icon(Icons.add),
                label: Text('Criar $_menuAliados'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (listaInimigos.isEmpty)
          Text('Nenhum cadastro de ${_menuInimigos.toLowerCase()}.',
              style: const TextStyle(color: _textoSecundario)),
        ...listaInimigos.map(
          (e) => _linhaLista(
            titulo: e.npc.nome,
            subtitulo: _resumoNPC(e),
            icone: Icons.groups_2_outlined,
            cor: _vermelho,
            onTap: () {},
            onDelete: () => _excluirNPC(e, aliado: false),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _adicionarNPC(aliado: false),
                icon: const Icon(Icons.library_add_outlined),
                label: Text('Adicionar $_menuInimigos'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _criarNPC(aliado: false),
                icon: const Icon(Icons.add),
                label: Text('Criar $_menuInimigos'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _resumoEncontro(Encontro e) {
    final partes = <String>[];
    if (e.raro) partes.add('Raro');
    if (e.periodo != null) partes.add(e.periodo!.texto);
    if (e.nivelFixo != null) partes.add('Nível ${e.nivelFixo}');
    if (e.condicao.trim().isNotEmpty) partes.add(e.condicao.trim());
    return partes.isEmpty ? 'Sem restrições' : partes.join(' • ');
  }

  String _resumoNPC(EncontroNPC e) {
    final partes = <String>[];
    if (e.raro) partes.add('Raro');
    if (e.periodo != null) partes.add(e.periodo!.texto);
    return partes.isEmpty ? 'Sem restrições' : partes.join(' • ');
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
        builder: (_) => CriaturaEditarScreen(criatura: nova, novo: true),
      ),
    );

    if (resultado == null || !mounted) return;

    setState(() {
      _encontrosCriaturas = Grupo(
        id: _encontrosCriaturas.id,
        nome: _encontrosCriaturas.nome,
        diurno: [
          ..._encontrosCriaturas.diurno,
          Encontro(
            criatura: resultado,
            condicao: '',
            raro: false,
            periodo: null,
            leguaMin: null,
            leguaMax: null,
            nivelFixo: null,
          ),
        ],
        noturno: _encontrosCriaturas.noturno,
        pesca: _encontrosCriaturas.pesca,
        surfe: _encontrosCriaturas.surfe,
      );
    });
  }

  Future<void> _criarNPC({required bool aliado}) async {
    final novo = NPC(
      id: '',
      nome: '',
      tipo: aliado ? _menuAliados : _menuInimigos,
      descricao: '',
    );

    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NPCEditScreen(npc: novo, novo: true),
      ),
    );

    if (resultado != true || !mounted) return;

    final npcs = await NPCsRepository().carregar();
    if (!mounted) return;

    final candidatos = npcs
        .where((n) => n.cadastroBaseId == null && n.nome.trim().isNotEmpty)
        .toList();

    if (candidatos.isEmpty) return;

    final escolhido = await showDialog<NPC>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Selecionar personagem criado'),
        content: SizedBox(
          width: 520,
          height: 420,
          child: ListView.separated(
            itemCount: candidatos.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final n = candidatos[i];
              return ListTile(
                title: Text(n.nome),
                onTap: () => Navigator.pop(ctx, n),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (escolhido == null || !mounted) return;

    final encontro = EncontroNPC(
      npc: escolhido,
      raro: false,
      periodo: null,
      leguaMin: null,
      leguaMax: null,
    );

    setState(() {
      if (aliado) {
        _encontrosAliados = GrupoNPC(
          diurno: [..._encontrosAliados.diurno, encontro],
          noturno: _encontrosAliados.noturno,
          pesca: _encontrosAliados.pesca,
          surfe: _encontrosAliados.surfe,
        );
      } else {
        _encontrosInimigos = GrupoNPC(
          diurno: [..._encontrosInimigos.diurno, encontro],
          noturno: _encontrosInimigos.noturno,
          pesca: _encontrosInimigos.pesca,
          surfe: _encontrosInimigos.surfe,
        );
      }
    });
  }

  Future<void> _adicionarEventoBase() async {
    final cadastros = await CadastrosRepository().carregarEventos();
    if (!mounted) return;

    if (cadastros.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum evento-base cadastrado.')),
      );
      return;
    }

    cadastros.sort(
      (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
    );

    final escolhido = await showDialog<Evento>(
      context: context,
      builder: (ctx) => _SelecionarEventoDialog(eventos: cadastros),
    );

    if (escolhido == null || !mounted) return;

    setState(() {
      _eventos.add(escolhido);
    });
  }

  Future<void> _criarItemBase() async {
    final resultado = await Navigator.push<Item>(
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

    if (resultado == null || !mounted) return;

    final copia = resultado.copyWith(
      quantidade: 1,
      localizacao: '',
    );

    final ajustado = await showDialog<Item>(
      context: context,
      builder: (_) => _ItemQuantidadeDialog(item: copia),
    );

    if (ajustado == null || !mounted) return;

    setState(() {
      _itens.add(ajustado);
    });
  }

  Future<void> _criarEventoBase() async {
    final resultado = await Navigator.push<Evento>(
      context,
      MaterialPageRoute(
        builder: (_) => const EventoEditScreen(),
      ),
    );

    if (resultado == null || !mounted) return;

    setState(() {
      _eventos.add(resultado);
    });
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
        TextField(
          controller: _dadoEventos,
          maxLines: 1,
          decoration: InputDecoration(
            labelText: 'Resultado dos dados',
            hintText: 'Ex.: 1-2 Nada, 3-5 Criatura, 6 Personagem',
            prefixIcon: const Icon(Icons.casino_outlined),
            filled: true,
            fillColor: const Color(0xFFF8F7F3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _borda),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _borda),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_eventos.isEmpty)
          const Text(
            'Nenhum Cadastro',
            style: TextStyle(
              color: _textoSecundario,
            ),
          ),
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
                onPressed: _adicionarEventoBase,
                icon: const Icon(Icons.library_add_outlined),
                label: const Text('Adicionar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _criarEventoBase,
                icon: const Icon(Icons.add),
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
          const Text(
            'Nenhum Cadastro',
            style: TextStyle(
              color: _textoSecundario,
            ),
          ),
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
                icon: const Icon(Icons.library_add_outlined),
                label: const Text('Adicionar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _criarItemBase,
                icon: const Icon(Icons.add),
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
                Row(
                  children: [
                    Expanded(
                      child: _campoTexto(
                        label: 'Nível mínimo',
                        controller: _nivelMin,
                        icone: Icons.arrow_downward,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _campoTexto(
                        label: 'Nível máximo',
                        controller: _nivelMax,
                        icone: Icons.arrow_upward,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
            _buildEncontros(),
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

  const _ItemDialog() : item = null;

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

class _EncontroDialog extends StatefulWidget {
  final List<Criatura> criaturas;
  final Encontro? encontro;
  final String nomeCriatura;

  const _EncontroDialog({
    required this.criaturas,
    this.encontro,
    required this.nomeCriatura,
  });

  @override
  State<_EncontroDialog> createState() => _EncontroDialogState();
}

class _EncontroDialogState extends State<_EncontroDialog> {
  late Criatura _criatura;
  late final TextEditingController _condicao;
  late final TextEditingController _leguaMin;
  late final TextEditingController _leguaMax;
  late final TextEditingController _nivelFixo;
  late final TextEditingController _buscaCriatura;

  bool _raro = false;
  PeriodoDia? _periodo;

  @override
  void initState() {
    super.initState();
    _criatura = widget.encontro?.criatura ?? widget.criaturas.first;
    _condicao = TextEditingController(text: widget.encontro?.condicao ?? '');
    _leguaMin = TextEditingController(
        text: widget.encontro?.leguaMin?.toString() ?? '');
    _leguaMax = TextEditingController(
        text: widget.encontro?.leguaMax?.toString() ?? '');
    _nivelFixo = TextEditingController(
        text: widget.encontro?.nivelFixo?.toString() ?? '');
    _buscaCriatura = TextEditingController();
    _raro = widget.encontro?.raro ?? false;
    _periodo = widget.encontro?.periodo;
  }

  @override
  void dispose() {
    _condicao.dispose();
    _leguaMin.dispose();
    _leguaMax.dispose();
    _nivelFixo.dispose();
    _buscaCriatura.dispose();
    super.dispose();
  }

  List<Criatura> _criaturasFiltradas() {
    final busca = _buscaCriatura.text.trim().toLowerCase();
    if (busca.isEmpty) return const [];
    final resultados = widget.criaturas.where((c) {
      final nome = c.nome.toLowerCase();
      final numero = c.numero.toString();
      return nome.contains(busca) || numero.contains(busca);
    }).toList();
    resultados.sort((a, b) {
      final c1 = (a.numero ?? 999999).compareTo(b.numero ?? 999999);
      if (c1 != 0) return c1;
      return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
    });
    return resultados.take(20).toList();
  }

  @override
  Widget build(BuildContext context) {
    final resultados = _criaturasFiltradas();

    return AlertDialog(
      title: Text(
          widget.encontro == null ? 'Adicionar encontro' : 'Editar encontro'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _buscaCriatura,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Buscar ',
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              if (resultados.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 280),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFD8D3C7)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: resultados.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final c = resultados[index];
                      return ListTile(
                        dense: true,
                        title: Text(c.nome),
                        onTap: () {
                          setState(() {
                            _criatura = c;
                            _buscaCriatura.clear();
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F7F3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD8D3C7)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.pets, color: Color(0xFFD64545)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _criatura.nome,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PeriodoDia?>(
                initialValue: _periodo,
                decoration: const InputDecoration(
                  labelText: 'Período',
                  prefixIcon: Icon(Icons.schedule),
                ),
                items: [
                  const DropdownMenuItem<PeriodoDia?>(
                    value: null,
                    child: Text('Qualquer'),
                  ),
                  ...PeriodoDia.values
                      .where((p) => p != PeriodoDia.qualquer)
                      .map((p) => DropdownMenuItem<PeriodoDia?>(
                            value: p,
                            child: Text(p.texto),
                          )),
                ],
                onChanged: (p) => setState(() => _periodo = p),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nivelFixo,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nível fixo',
                  hintText: 'Vazio = usa faixa do Ponto',
                ),
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Encontro raro'),
                value: _raro,
                onChanged: (v) => setState(() => _raro = v),
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
            Navigator.pop(
              context,
              Encontro(
                criatura: _criatura,
                condicao: _condicao.text.trim(),
                raro: _raro,
                periodo: _periodo,
                leguaMin: int.tryParse(_leguaMin.text.trim()),
                leguaMax: int.tryParse(_leguaMax.text.trim()),
                nivelFixo: int.tryParse(_nivelFixo.text.trim()),
              ),
            );
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class _NPCDialog extends StatefulWidget {
  final List<NPC> npcs;
  final EncontroNPC? encontro;
  final String tipo;

  const _NPCDialog({
    required this.npcs,
    this.encontro,
    required this.tipo,
  });

  @override
  State<_NPCDialog> createState() => _NPCDialogState();
}

class _NPCDialogState extends State<_NPCDialog> {
  NPC? _npc;
  late final TextEditingController _leguaMin;
  late final TextEditingController _leguaMax;
  late final TextEditingController _busca;

  bool _raro = false;
  PeriodoDia? _periodo;

  @override
  void initState() {
    super.initState();
    _npc = widget.encontro?.npc;
    _leguaMin = TextEditingController(
        text: widget.encontro?.leguaMin?.toString() ?? '');
    _leguaMax = TextEditingController(
        text: widget.encontro?.leguaMax?.toString() ?? '');
    _busca = TextEditingController();
    _raro = widget.encontro?.raro ?? false;
    _periodo = widget.encontro?.periodo;
  }

  @override
  void dispose() {
    _leguaMin.dispose();
    _leguaMax.dispose();
    _busca.dispose();
    super.dispose();
  }

  List<NPC> _filtrados() {
    final termo = _busca.text.trim().toLowerCase();
    if (termo.isEmpty) return widget.npcs;
    return widget.npcs
        .where((n) =>
            n.nome.toLowerCase().contains(termo) ||
            n.descricao.toLowerCase().contains(termo))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final lista = _filtrados();

    return AlertDialog(
      title: Text(
        widget.encontro == null
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
                controller: _busca,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Buscar personagem',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 260),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFD8D3C7)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: lista.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final n = lista[index];
                    return ListTile(
                      dense: true,
                      title: Text(n.nome),
                      onTap: () => setState(() => _npc = n),
                    );
                  },
                ),
              ),
              if (_npc != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7F3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD8D3C7)),
                  ),
                  child: Text(
                    _npc!.nome,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<PeriodoDia?>(
                initialValue: _periodo,
                decoration: const InputDecoration(
                  labelText: 'Período',
                  prefixIcon: Icon(Icons.schedule),
                ),
                items: [
                  const DropdownMenuItem<PeriodoDia?>(
                    value: null,
                    child: Text('Qualquer'),
                  ),
                  ...PeriodoDia.values
                      .where((p) => p != PeriodoDia.qualquer)
                      .map((p) => DropdownMenuItem<PeriodoDia?>(
                            value: p,
                            child: Text(p.texto),
                          )),
                ],
                onChanged: (p) => setState(() => _periodo = p),
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Encontro raro'),
                value: _raro,
                onChanged: (v) => setState(() => _raro = v),
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
          onPressed: _npc == null
              ? null
              : () {
                  Navigator.pop(
                    context,
                    EncontroNPC(
                      npc: _npc!,
                      raro: _raro,
                      periodo: _periodo,
                      leguaMin: int.tryParse(_leguaMin.text.trim()),
                      leguaMax: int.tryParse(_leguaMax.text.trim()),
                    ),
                  );
                },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class _SelecionarEventoDialog extends StatefulWidget {
  final List<Evento> eventos;

  const _SelecionarEventoDialog({required this.eventos});

  @override
  State<_SelecionarEventoDialog> createState() =>
      _SelecionarEventoDialogState();
}

class _SelecionarEventoDialogState extends State<_SelecionarEventoDialog> {
  final TextEditingController _busca = TextEditingController();

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final termo = _busca.text.trim().toLowerCase();

    final eventos = widget.eventos
        .where((e) => e.nome.toLowerCase().contains(termo))
        .toList();

    return AlertDialog(
      title: const Text('Selecionar evento'),
      content: SizedBox(
        width: 520,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: _busca,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Buscar evento',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: eventos.isEmpty
                  ? const Center(child: Text('Nenhum evento encontrado.'))
                  : ListView.separated(
                      itemCount: eventos.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final e = eventos[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFE07A32),
                          ),
                          title: Text(e.nome),
                          subtitle: Text(
                            e.descricao.isEmpty ? 'Sem descrição' : e.descricao,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => Navigator.pop(context, e),
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

class _ItemQuantidadeDialog extends StatefulWidget {
  final Item item;

  const _ItemQuantidadeDialog({required this.item});

  @override
  State<_ItemQuantidadeDialog> createState() => _ItemQuantidadeDialogState();
}

class _ItemQuantidadeDialogState extends State<_ItemQuantidadeDialog> {
  late final TextEditingController _quantidade;
  late final TextEditingController _localizacao;

  @override
  void initState() {
    super.initState();
    _quantidade = TextEditingController(
      text: widget.item.quantidade.toString(),
    );
    _localizacao = TextEditingController(
      text: widget.item.localizacao,
    );
  }

  @override
  void dispose() {
    _quantidade.dispose();
    _localizacao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item.nome.isEmpty ? 'Item' : widget.item.nome),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _quantidade,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantidade',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _localizacao,
              decoration: const InputDecoration(
                labelText: 'Localização',
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
            final qtd = int.tryParse(_quantidade.text.trim());
            if (qtd == null || qtd < 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Quantidade deve ser no mínimo 1.'),
                ),
              );
              return;
            }
            Navigator.pop(
              context,
              widget.item.copyWith(
                quantidade: qtd,
                localizacao: _localizacao.text.trim(),
              ),
            );
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
