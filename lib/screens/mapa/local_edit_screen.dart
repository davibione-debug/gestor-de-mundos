import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../npcs/npc_edit_screen.dart';

import '../bestiario/criatura_editar_screen.dart';

import '../itens/item_editar_screen.dart';

import '../../models/encontro.dart';
import '../../models/encontro_npc.dart';
import '../../models/evento.dart';
import '../../models/grupo.dart';
import '../../models/grupo_npc.dart';
import '../../models/local.dart';
import '../../models/npc.dart';
import '../../models/periodo_dia.dart';
import '../../models/criatura.dart';
import '../../models/ponto_interesse.dart';
import 'ponto_interesse_edit_screen.dart';
import 'evento_edit_screen.dart';
import '../../repositories/locais_repository.dart';
import '../../repositories/cadastros_repository.dart';
import '../../repositories/criaturas_repository.dart';
import '../../repositories/npcs_repository.dart';
import '../../repositories/itens_repository.dart';
import '../../models/item.dart';

class LocalEditScreen extends StatefulWidget {
  final Local local;

  const LocalEditScreen({
    super.key,
    required this.local,
  });

  @override
  State<LocalEditScreen> createState() => _LocalEditScreenState();
}

class _LocalEditScreenState extends State<LocalEditScreen> {
  static const Color _fundo = Color(0xFFF4F1E8);
  static const Color _card = Colors.white;
  static const Color _borda = Color(0xFFD8D3C7);
  static const Color _vermelho = Color(0xFFD64545);
  static const Color _azul = Color(0xFF3D73C9);
  static const Color _amarelo = Color(0xFFE3B341);
  static const Color _laranja = Color(0xFFE07A32);
  static const Color _verde = Color(0xFF4D9B62);
  static const Color _texto = Color(0xFF252525);
  static const Color _textoSecundario = Color(0xFF66625B);

  final LocaisRepository _repository = LocaisRepository();
  final CriaturasRepository _criaturasRepository = CriaturasRepository();

  late Local _localAtual;

  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _regiaoController;
  late final TextEditingController _leguasController;
  late final TextEditingController _terrenoController;
  late final TextEditingController _nivelMinController;
  late final TextEditingController _nivelMaxController;

  late final TextEditingController _dadoDiurnoController;
  late final TextEditingController _dadoNoturnoController;
  late final TextEditingController _dadoPescaController;
  late final TextEditingController _dadoSurfeController;
  late final TextEditingController _dadoEventosController;

  List<Criatura> _criaturas = [];
  List<Local> _locaisConexao = [];
  final List<_ConexaoLocalEdicao> _conexoesEdicao = [];
  List<Item> _itens = [];
  final Map<String, String> _leguasPontosTexto = {};

  int _abaEncontro = 0;
  int _abaTreinador = 0;
  int _abaRocket = 0;

  String _menuAliados = 'Aliados';
  String _menuInimigos = 'Inimigos';
  String _nomeCriatura = 'Criatura';
  String _tituloCriaturas = 'Criaturas';

  final List<String> _modalidades = const [
    'Diurno',
    'Noturno',
    'Pesca',
    'Aquático',
  ];
  Future<void> _carregarMenuPersonagens() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _menuAliados = prefs.getString('menu_aliados')?.trim().isNotEmpty == true
          ? prefs.getString('menu_aliados')!.trim()
          : 'Aliados';
      _menuInimigos =
          prefs.getString('menu_inimigos')?.trim().isNotEmpty == true
              ? prefs.getString('menu_inimigos')!.trim()
              : 'Inimigos';
      _nomeCriatura =
          prefs.getString('nome_criatura')?.trim().isNotEmpty == true
              ? prefs.getString('nome_criatura')!.trim()
              : 'Criatura';
      _tituloCriaturas =
          prefs.getString('menu_criaturas')?.trim().isNotEmpty == true
              ? prefs.getString('menu_criaturas')!.trim()
              : 'Criaturas';
    });
  }

  @override
  void initState() {
    super.initState();
    _carregarMenuPersonagens();

    _localAtual = widget.local;

    for (final item in _localAtual.conexoes) {
      if (item is Map) {
        final direcao = item['direcao']?.toString() ?? 'Norte';
        _conexoesEdicao.add(
          _ConexaoLocalEdicao(
            direcao: const ['Norte', 'Sul', 'Leste', 'Oeste'].contains(direcao)
                ? direcao
                : 'Norte',
            leguas: item['leguas']?.toString() ?? '',
            localId: item['localId']?.toString(),
          ),
        );
      }
    }

    _carregarLocaisConexao();
    _itens = List<Item>.from(widget.local.itens);

    _nomeController = TextEditingController(
      text: widget.local.nome,
    );

    _regiaoController = TextEditingController(text: widget.local.regiaoId);
    _descricaoController = TextEditingController(
      text: widget.local.descricao,
    );

    _leguasController = TextEditingController(
      text: widget.local.leguas.toString(),
    );

    _terrenoController = TextEditingController(
      text: widget.local.terreno,
    );

    _nivelMinController = TextEditingController(
      text: widget.local.nivelMinCriatura.toString(),
    );

    _nivelMaxController = TextEditingController(
      text: widget.local.nivelMaxCriatura.toString(),
    );

    _dadoDiurnoController = TextEditingController(
      text: widget.local.dadoEncontroDiurno,
    );

    _dadoNoturnoController = TextEditingController(
      text: widget.local.dadoEncontroNoturno,
    );

    _dadoPescaController = TextEditingController(
      text: widget.local.dadoEncontroPesca,
    );

    _dadoSurfeController = TextEditingController(
      text: widget.local.dadoEncontroSurfe,
    );

    _dadoEventosController = TextEditingController(
      text: widget.local.dadoEventos,
    );

    _carregarCriaturas();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _regiaoController.dispose();
    _leguasController.dispose();
    _terrenoController.dispose();
    _nivelMinController.dispose();
    _nivelMaxController.dispose();
    _dadoDiurnoController.dispose();
    _dadoNoturnoController.dispose();
    _dadoPescaController.dispose();
    _dadoSurfeController.dispose();
    _dadoEventosController.dispose();
    for (final conexao in _conexoesEdicao) {
      conexao.dispose();
    }
    super.dispose();
  }

  Future<void> _carregarCriaturas() async {
    final criaturas = await _criaturasRepository.carregar();

    if (!mounted) {
      return;
    }

    setState(() {
      _criaturas = criaturas
        ..sort((a, b) {
          final comparacaoNumero = (a.numero ?? 999999).compareTo(
            b.numero ?? 999999,
          );
          if (comparacaoNumero != 0) return comparacaoNumero;
          return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
        });
    });
  }

  Grupo get _grupoEncontros {
    return _localAtual.encontros;
  }

  List<Encontro> _listaEncontros(int indice) {
    switch (indice) {
      case 0:
        return _grupoEncontros.diurno;
      case 1:
        return _grupoEncontros.noturno;
      case 2:
        return _grupoEncontros.pesca;
      case 3:
        return _grupoEncontros.surfe;
      default:
        return const [];
    }
  }

  TextEditingController _dadoController(int indice) {
    switch (indice) {
      case 0:
        return _dadoDiurnoController;
      case 1:
        return _dadoNoturnoController;
      case 2:
        return _dadoPescaController;
      case 3:
        return _dadoSurfeController;
      default:
        return _dadoDiurnoController;
    }
  }

  String _periodoTexto(PeriodoDia? periodo) {
    if (periodo == null) {
      return 'Qualquer';
    }

    return periodo.texto;
  }

  Future<void> _carregarLocaisConexao() async {
    final locais = await _repository.carregar();
    if (!mounted) return;

    setState(() {
      _locaisConexao = locais
          .where((local) => local.id != widget.local.id)
          .toList()
        ..sort((a, b) => a.nome.compareTo(b.nome));
    });
  }

  void _adicionarConexao() {
    setState(() {
      _conexoesEdicao.add(_ConexaoLocalEdicao());
    });
  }

  void _removerConexao(int indice) {
    final conexao = _conexoesEdicao.removeAt(indice);
    conexao.dispose();
    setState(() {});
  }

  Widget _buildConexoes() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Conexões',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Adicionar conexão',
                    onPressed: _adicionarConexao,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              if (_conexoesEdicao.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Nenhuma conexão cadastrada.'),
                ),
              ...List.generate(
                _conexoesEdicao.length,
                (indice) => _buildLinhaConexao(indice),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinhaConexao(int indice) {
    final conexao = _conexoesEdicao[indice];

    final idsDisponiveis = _locaisConexao.map((local) => local.id).toSet();
    final localSelecionado =
        idsDisponiveis.contains(conexao.localId) ? conexao.localId : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  initialValue: conexao.direcao,
                  decoration: const InputDecoration(
                    labelText: 'Direção',
                    border: OutlineInputBorder(),
                  ),
                  items: const ['Norte', 'Sul', 'Leste', 'Oeste']
                      .map(
                        (direcao) => DropdownMenuItem<String>(
                          value: direcao,
                          child: Text(direcao),
                        ),
                      )
                      .toList(),
                  onChanged: (valor) {
                    if (valor == null) return;
                    setState(() => conexao.direcao = valor);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: conexao.leguasController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Léguas',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Remover conexão',
                onPressed: () => _removerConexao(indice),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: localSelecionado,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Local de destino',
              border: OutlineInputBorder(),
            ),
            hint: const Text('Selecione um Local'),
            items: _locaisConexao
                .map(
                  (local) => DropdownMenuItem<String>(
                    value: local.id,
                    child: Text(
                      local.nome,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (valor) {
              setState(() => conexao.localId = valor);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _salvar() async {
    final nome = _nomeController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome do Local.')),
      );
      return;
    }

    final mapa = _localAtual.toMap();
    mapa['id'] = widget.local.id;
    mapa['itens'] = _itens.map((item) => item.toMap()).toList();

    // Aplicar leguas dos pontos
    final pontosMap =
        List<dynamic>.from(mapa['pontosInteresse'] as List? ?? []);
    for (var i = 0; i < pontosMap.length; i++) {
      final pontoMap = Map<String, dynamic>.from(pontosMap[i] as Map);
      final id = pontoMap['id']?.toString();
      if (id != null && _leguasPontosTexto.containsKey(id)) {
        final valor = int.tryParse(_leguasPontosTexto[id]!.trim());
        if (valor != null && valor >= 0) {
          pontoMap['leguas'] = valor;
        }
      }
      pontosMap[i] = pontoMap;
    }
    mapa['pontosInteresse'] = pontosMap;
    mapa['nome'] = nome;
    mapa['regiaoId'] = _regiaoController.text.trim();
    mapa['descricao'] = _descricaoController.text.trim();
    mapa['leguas'] = int.tryParse(_leguasController.text.trim()) ?? 0;
    mapa['terreno'] = _terrenoController.text.trim();
    mapa['conexoes'] = <dynamic>[
      ..._localAtual.conexoes.whereType<String>(),
      ..._conexoesEdicao.map(
        (conexao) => <String, dynamic>{
          'direcao': conexao.direcao,
          'leguas': int.tryParse(conexao.leguasController.text.trim()) ?? 0,
          'localId': conexao.localId,
        },
      ),
    ];
    mapa['nivelMinCriatura'] =
        int.tryParse(_nivelMinController.text.trim()) ?? 0;
    mapa['nivelMaxCriatura'] =
        int.tryParse(_nivelMaxController.text.trim()) ?? 0;
    mapa['dadoEncontroDiurno'] = _dadoDiurnoController.text.trim();
    mapa['dadoEncontroNoturno'] = _dadoNoturnoController.text.trim();
    mapa['dadoEncontroPesca'] = _dadoPescaController.text.trim();
    mapa['dadoEncontroSurfe'] = _dadoSurfeController.text.trim();
    mapa['dadoEncontro'] = mapa['dadoEncontroDiurno'];
    mapa['dadoEventos'] = _dadoEventosController.text.trim();

    final localSalvo = Local.fromMap(mapa);
    await _repository.salvar(localSalvo);

    final locais = await _repository.carregar();
    final confirmado = locais.where((local) => local.id == widget.local.id);

    final camposDivergentes = confirmado.isEmpty
        ? <String>['Local não encontrado pelo ID']
        : <String>[
            if (confirmado.first.nome != nome) 'nome',
            if (confirmado.first.regiaoId != mapa['regiaoId'])
              'região',
            if (confirmado.first.descricao != mapa['descricao'])
              'descrição',
            if (confirmado.first.leguas != mapa['leguas']) 'léguas',
            if (confirmado.first.terreno != mapa['terreno']) 'terreno',
            if (confirmado.first.nivelMinCriatura != mapa['nivelMinCriatura'])
              'nível mínimo',
            if (confirmado.first.nivelMaxCriatura != mapa['nivelMaxCriatura'])
              'nível máximo',
            if (confirmado.first.dadoEncontroDiurno !=
                mapa['dadoEncontroDiurno'])
              'encontro diurno',
            if (confirmado.first.dadoEncontroNoturno !=
                mapa['dadoEncontroNoturno'])
              'encontro noturno',
            if (confirmado.first.dadoEncontroPesca != mapa['dadoEncontroPesca'])
              'encontro de pesca',
            if (confirmado.first.dadoEncontroSurfe != mapa['dadoEncontroSurfe'])
              'encontro aquático',
            if (confirmado.first.dadoEventos != mapa['dadoEventos']) 'eventos',
          ];

    if (camposDivergentes.isNotEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Falha ao confirmar: ${camposDivergentes.join(', ')}.',
          ),
        ),
      );
      return;
    }

    _localAtual = confirmado.first;

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _editarEncontro({
    Encontro? encontro,
    required int modalidade,
  }) async {
    if (_criaturas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nenhuma criatura cadastrada para selecionar.',
          ),
        ),
      );
      return;
    }

    final resultado = await showDialog<Encontro>(
      context: context,
      builder: (_) => _EncontroDialog(
        criaturas: _criaturas,
        encontro: encontro,
        nomeCriatura: _nomeCriatura,
      ),
    );

    if (resultado == null || !mounted) {
      return;
    }

    final mapa = _localAtual.toMap();
    final encontrosMap = Map<String, dynamic>.from(
      mapa['encontros'] as Map? ?? {},
    );

    final chave = [
      'diurno',
      'noturno',
      'pesca',
      'surfe',
    ][modalidade];

    final lista = (encontrosMap[chave] is List)
        ? List<dynamic>.from(
            encontrosMap[chave] as List,
          )
        : <dynamic>[];

    final encontroMap = {
      'criatura': resultado.criatura.toMap(),
      'condicao': resultado.condicao,
      'raro': resultado.raro,
      'periodo': resultado.periodo?.name,
      'leguaMin': resultado.leguaMin,
      'leguaMax': resultado.leguaMax,
      'nivelFixo': resultado.nivelFixo,
    };

    if (encontro == null) {
      lista.add(encontroMap);
    } else {
      final indice = lista.indexWhere(
        (item) =>
            item is Map &&
            _mesmoEncontro(
              item,
              encontro,
            ),
      );

      if (indice >= 0) {
        lista[indice] = encontroMap;
      } else {
        lista.add(encontroMap);
      }
    }

    encontrosMap[chave] = lista;
    mapa['encontros'] = encontrosMap;

    setState(() {
      _localAtual = Local.fromMap(mapa);
    });
    await _repository.salvar(_localAtual);
  }

  bool _mesmoEncontro(
    dynamic item,
    Encontro encontro,
  ) {
    if (item is! Map) {
      return false;
    }

    final criatura = item['criatura'];

    return criatura is Map &&
        criatura['id']?.toString() == encontro.criatura.id &&
        item['condicao']?.toString() == encontro.condicao &&
        item['leguaMin']?.toString() == encontro.leguaMin?.toString() &&
        item['leguaMax']?.toString() == encontro.leguaMax?.toString() &&
        item['nivelFixo']?.toString() == encontro.nivelFixo?.toString();
  }

  Future<void> _excluirEncontro(
    Encontro encontro,
    int modalidade,
  ) async {
    final confirmar = await _confirmar(
      'Excluir encontro?',
      '${encontro.criatura.nome} será removido desta tabela.',
    );

    if (!confirmar || !mounted) {
      return;
    }

    final mapa = _localAtual.toMap();
    final encontrosMap = Map<String, dynamic>.from(
      mapa['encontros'] as Map? ?? {},
    );

    final chave = [
      'diurno',
      'noturno',
      'pesca',
      'surfe',
    ][modalidade];

    final lista = List<dynamic>.from(
      encontrosMap[chave] as List? ?? [],
    );

    lista.removeWhere(
      (item) => item is Map && _mesmoEncontro(item, encontro),
    );

    encontrosMap[chave] = lista;
    mapa['encontros'] = encontrosMap;

    setState(() {
      _localAtual = Local.fromMap(mapa);
    });
    await _repository.salvar(_localAtual);
  }

  GrupoNPC _grupoNPC(bool rocket) {
    return rocket ? _localAtual.rockets : _localAtual.treinadores;
  }

  List<EncontroNPC> _listaNPC(
    bool rocket,
    int modalidade,
  ) {
    final grupo = _grupoNPC(rocket);

    switch (modalidade) {
      case 0:
        return grupo.diurno;
      case 1:
        return grupo.noturno;
      case 2:
        return grupo.pesca;
      case 3:
        return grupo.surfe;
      default:
        return const [];
    }
  }

  Future<void> _editarNPC({
    required bool rocket,
    required int modalidade,
    EncontroNPC? encontro,
  }) async {
    List<NPC> cadastrosBase = [];

    if (encontro == null) {
      cadastrosBase = await NPCsRepository().carregar();

      cadastrosBase =
          cadastrosBase.where((npc) => npc.cadastroBaseId == null).toList();

      cadastrosBase.sort(
        (a, b) => a.nome.toLowerCase().compareTo(
              b.nome.toLowerCase(),
            ),
      );

      if (!mounted) {
        return;
      }

      if (cadastrosBase.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              rocket
                  ? 'Nenhum cadastro de $_menuInimigos encontrado.'
                  : 'Nenhum cadastro de $_menuAliados encontrado.',
            ),
          ),
        );
        return;
      }
    }

    final resultado = await showDialog<EncontroNPC>(
      context: context,
      builder: (_) => _NPCDialog(
        encontro: encontro,
        tipo: rocket ? _menuInimigos : _menuAliados,
        tipoCadastro: rocket ? 'Rocket' : 'Treinador',
        inimigo: rocket,
        cadastrosBase: cadastrosBase,
      ),
    );

    if (resultado == null || !mounted) {
      return;
    }

    final mapa = _localAtual.toMap();

    final chaveGrupo = rocket ? 'rockets' : 'treinadores';

    final grupoMap = Map<String, dynamic>.from(
      mapa[chaveGrupo] as Map? ?? {},
    );

    final chaveModalidade = [
      'diurno',
      'noturno',
      'pesca',
      'surfe',
    ][modalidade];

    final lista = grupoMap[chaveModalidade] is List
        ? List<dynamic>.from(
            grupoMap[chaveModalidade] as List,
          )
        : <dynamic>[];

    final encontroMap = {
      'npc': resultado.npc.toMap(),
      'raro': resultado.raro,
      'periodo': resultado.periodo?.name,
      'leguaMin': resultado.leguaMin,
      'leguaMax': resultado.leguaMax,
    };

    if (encontro == null) {
      lista.add(encontroMap);
    } else {
      final indice = lista.indexWhere(
        (item) =>
            item is Map &&
            _mesmoEncontroNPC(
              item,
              encontro,
            ),
      );

      if (indice >= 0) {
        lista[indice] = encontroMap;
      } else {
        lista.add(encontroMap);
      }
    }

    grupoMap[chaveModalidade] = lista;
    mapa[chaveGrupo] = grupoMap;

    setState(() {
      _localAtual = Local.fromMap(mapa);
    });
    await _repository.salvar(_localAtual);
  }

  bool _mesmoEncontroNPC(
    dynamic item,
    EncontroNPC encontro,
  ) {
    if (item is! Map) {
      return false;
    }

    final npc = item['npc'];

    return npc is Map &&
        npc['id']?.toString() == encontro.npc.id &&
        item['leguaMin']?.toString() == encontro.leguaMin?.toString() &&
        item['leguaMax']?.toString() == encontro.leguaMax?.toString();
  }

  Future<void> _excluirNPC(
    bool rocket,
    EncontroNPC encontro,
    int modalidade,
  ) async {
    final tipo = rocket ? 'Rocket' : 'Treinador';

    final confirmar = await _confirmar(
      'Excluir $tipo?',
      '${encontro.npc.nome} será removido desta modalidade.',
    );

    if (!confirmar || !mounted) {
      return;
    }

    final mapa = _localAtual.toMap();

    final chaveGrupo = rocket ? 'rockets' : 'treinadores';

    final grupoMap = Map<String, dynamic>.from(
      mapa[chaveGrupo] as Map? ?? {},
    );

    final chaveModalidade = [
      'diurno',
      'noturno',
      'pesca',
      'surfe',
    ][modalidade];

    final lista = List<dynamic>.from(
      grupoMap[chaveModalidade] as List? ?? [],
    );

    lista.removeWhere(
      (item) =>
          item is Map &&
          _mesmoEncontroNPC(
            item,
            encontro,
          ),
    );

    grupoMap[chaveModalidade] = lista;
    mapa[chaveGrupo] = grupoMap;

    setState(() {
      _localAtual = Local.fromMap(mapa);
    });
    await _repository.salvar(_localAtual);
  }

  Future<void> _editarEvento({
    required Evento evento,
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

    final mapa = _localAtual.toMap();
    final lista = List<dynamic>.from(
      mapa['eventos'] as List? ?? [],
    );

    final indice = lista.indexWhere(
      (item) => item is Map && item['id']?.toString() == evento.id,
    );

    if (indice >= 0) {
      lista[indice] = resultado.toMap();
    } else {
      return;
    }

    mapa['eventos'] = lista;

    final localAtualizado = Local.fromMap(mapa);

    setState(() {
      _localAtual = localAtualizado;
    });
    await _repository.salvar(localAtualizado);
  }

  Future<void> _incluirEvento() async {
    final cadastro = CadastrosRepository();
    final eventos = await cadastro.carregarEventos();

    if (!mounted) {
      return;
    }

    if (eventos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nenhum evento-base cadastrado no Mapa.',
          ),
        ),
      );
      return;
    }

    final eventoBase = await showDialog<Evento>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Incluir evento'),
        content: SizedBox(
          width: 560,
          height: 420,
          child: ListView.separated(
            itemCount: eventos.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final evento = eventos[index];

              return ListTile(
                leading: const Icon(
                  Icons.warning_amber_rounded,
                  color: _laranja,
                ),
                title: Text(
                  evento.nome.isEmpty ? 'Evento sem nome' : evento.nome,
                ),
                subtitle: Text(
                  evento.descricao.isEmpty
                      ? 'Sem descrição'
                      : evento.descricao,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => Navigator.pop(context, evento),
              );
            },
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

    if (eventoBase == null || !mounted) {
      return;
    }

    final copia = Evento.fromMap({
      ...eventoBase.toMap(),
      'id': _novoId('EVENTO'),
      'cadastroBaseId': eventoBase.id,
      'localizacao': '',
      'localizacaoTipo': 'nenhuma',
      'localizacaoId': '',
      'legua': null,
    });

    final mapa = _localAtual.toMap();
    final lista = List<dynamic>.from(
      mapa['eventos'] as List? ?? [],
    );

    lista.add(copia.toMap());
    mapa['eventos'] = lista;

    final localAtualizado = Local.fromMap(mapa);

    setState(() {
      _localAtual = localAtualizado;
    });
    await _repository.salvar(localAtualizado);
  }

  Future<void> _excluirEvento(Evento evento) async {
    final confirmar = await _confirmar(
      'Excluir evento?',
      'O evento "${evento.nome}" será removido deste Local.',
    );

    if (!confirmar || !mounted) {
      return;
    }

    final mapa = _localAtual.toMap();
    final lista = List<dynamic>.from(
      mapa['eventos'] as List? ?? [],
    );

    lista.removeWhere(
      (item) => item is Map && item['id']?.toString() == evento.id,
    );

    mapa['eventos'] = lista;

    final localAtualizado = Local.fromMap(mapa);

    setState(() {
      _localAtual = localAtualizado;
    });
    await _repository.salvar(localAtualizado);
  }

  Future<void> _editarPonto({
    required PontoInteresse ponto,
  }) async {
    final resultado = await Navigator.push<PontoInteresse>(
      context,
      MaterialPageRoute(
        builder: (_) => PontoInteresseEditScreen(
          ponto: ponto,
        ),
      ),
    );

    if (resultado == null || !mounted) {
      return;
    }

    final mapa = _localAtual.toMap();
    final lista = List<dynamic>.from(
      mapa['pontosInteresse'] as List? ?? [],
    );

    final indice = lista.indexWhere(
      (item) => item is Map && item['id']?.toString() == ponto.id,
    );

    if (indice >= 0) {
      lista[indice] = resultado.toMap();
    } else {
      return;
    }

    mapa['pontosInteresse'] = lista;

    setState(() {
      _localAtual = Local.fromMap(mapa);
    });
    await _repository.salvar(_localAtual);
  }

  Future<void> _incluirPonto() async {
    final cadastro = CadastrosRepository();
    final pontos = await cadastro.carregarPontos();

    if (!mounted) {
      return;
    }

    if (pontos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nenhum ponto de interesse-base cadastrado no Mapa.',
          ),
        ),
      );
      return;
    }

    final pontoBase = await showDialog<PontoInteresse>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Incluir ponto de interesse',
        ),
        content: SizedBox(
          width: 560,
          height: 420,
          child: ListView.separated(
            itemCount: pontos.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final ponto = pontos[index];

              return ListTile(
                leading: const Icon(
                  Icons.place_outlined,
                  color: _azul,
                ),
                title: Text(
                  ponto.nome.isEmpty ? 'Ponto sem nome' : ponto.nome,
                ),
                subtitle: Text(
                  ponto.descricao.isEmpty
                      ? 'Sem descrição'
                      : ponto.descricao,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => Navigator.pop(context, ponto),
              );
            },
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

    if (pontoBase == null || !mounted) {
      return;
    }

    final copia = PontoInteresse.fromMap({
      ...pontoBase.toMap(),
      'id': _novoId('PONTO'),
      'cadastroBaseId': pontoBase.id,
      'localizacao': '',
      'localizacaoTipo': 'nenhuma',
      'localizacaoId': '',
      'leguas': 0,
    });

    final mapa = _localAtual.toMap();
    final lista = List<dynamic>.from(
      mapa['pontosInteresse'] as List? ?? [],
    );

    lista.add(copia.toMap());
    mapa['pontosInteresse'] = lista;

    setState(() {
      _localAtual = Local.fromMap(mapa);
    });
    await _repository.salvar(_localAtual);
  }

  Future<void> _excluirPonto(
    PontoInteresse ponto,
  ) async {
    final confirmar = await _confirmar(
      'Excluir ponto de interesse?',
      'O ponto "${ponto.nome}" será removido deste Local.',
    );

    if (!confirmar || !mounted) {
      return;
    }

    final mapa = _localAtual.toMap();
    final lista = List<dynamic>.from(
      mapa['pontosInteresse'] as List? ?? [],
    );

    lista.removeWhere(
      (item) => item is Map && item['id']?.toString() == ponto.id,
    );

    mapa['pontosInteresse'] = lista;

    setState(() {
      _localAtual = Local.fromMap(mapa);
    });
    await _repository.salvar(_localAtual);
  }

  Future<void> _adicionarItem() async {
    final itensBase = await ItensRepository().carregar();

    if (!mounted) {
      return;
    }

    if (itensBase.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum Item-base cadastrado.'),
        ),
      );
      return;
    }

    itensBase.sort(
      (a, b) => a.nome.toLowerCase().compareTo(
            b.nome.toLowerCase(),
          ),
    );

    final itemBase = await showDialog<Item>(
      context: context,
      builder: (_) => _SelecionarItemDialog(
        itens: itensBase,
      ),
    );

    if (itemBase == null || !mounted) {
      return;
    }

    setState(() {
      _itens.add(
        itemBase.copyWith(
          quantidade: 1,
          localizacao: '',
        ),
      );
    });
  }

  Future<void> _editarItem(Item item) async {
    final resultado = await showDialog<Item>(
      context: context,
      builder: (_) => _ItemLocalDialog(
        item: item,
      ),
    );

    if (resultado == null || !mounted) {
      return;
    }

    final indice = _itens.indexOf(item);

    if (indice < 0) {
      return;
    }

    setState(() {
      _itens[indice] = resultado;
    });
  }

  Future<void> _excluirItem(Item item) async {
    final confirmar = await _confirmar(
      'Excluir item?',
      'O item "${item.nome}" será removido deste Local.',
    );

    if (!confirmar || !mounted) {
      return;
    }

    setState(() {
      _itens.remove(item);
    });
  }

  Widget _buildItens() {
    return _secao(
      'Itens',
      Icons.inventory_2_outlined,
      _amarelo,
      [
        if (_itens.isEmpty)
          const Text(
            'Nenhum item incluído neste Local.',
            style: TextStyle(
              color: _textoSecundario,
            ),
          ),
        ..._itens.map(
          (item) => Card(
            elevation: 0,
            color: const Color(0xFFF8F7F3),
            child: ListTile(
              leading: const Icon(
                Icons.inventory_2_outlined,
                color: _amarelo,
              ),
              title: Text(
                '${item.nome.isEmpty ? 'Item sem nome' : item.nome} ,? ${item.quantidade}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text([
                item.tipo.trim().isEmpty ? 'Sem tipo' : item.tipo,
                if (item.localizacao.trim().isNotEmpty)
                  'Localização: ${item.localizacao.trim()}',
              ].join(' ,Á‚Â¢ ')),
              onTap: () => _editarItem(item),
              trailing: IconButton(
                tooltip: 'Excluir',
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFD64545),
                ),
                onPressed: () => _excluirItem(item),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _adicionarItem,
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

  Future<void> _criarItemBase() async {
    await Navigator.push<bool>(
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
  }

  Future<void> _criarCriaturaBase() async {
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

    await Navigator.push<Criatura>(
      context,
      MaterialPageRoute(
        builder: (_) => CriaturaEditarScreen(
          criatura: nova,
          novo: true,
        ),
      ),
    );
  }

  Future<void> _criarNPCBase({required bool rocket}) async {
    final novo = NPC(
      id: '',
      nome: '',
      tipo: rocket ? _menuInimigos : _menuAliados,
      descricao: '',
    );

    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NPCEditScreen(
          npc: novo,
          novo: true,
        ),
      ),
    );
  }

  Future<void> _criarEventoBase() async {
    final resultado = await Navigator.push<Evento>(
      context,
      MaterialPageRoute(
        builder: (_) => const EventoEditScreen(),
      ),
    );

    if (resultado == null || !mounted) return;
    await CadastrosRepository().salvarEvento(resultado);
  }

  Future<void> _criarPontoBase() async {
    final resultado = await Navigator.push<PontoInteresse>(
      context,
      MaterialPageRoute(
        builder: (_) => PontoInteresseEditScreen(
          ponto: const PontoInteresse(
            id: '',
            nome: '',
            descricao: '',
            localizacao: '',
          ),
        ),
      ),
    );

    if (resultado == null || !mounted) return;
    await CadastrosRepository().salvarPonto(resultado);
  }

  String _novoId(String prefixo) =>
      '$prefixo-${DateTime.now().microsecondsSinceEpoch}';

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
              backgroundColor: Color(0xFFD64545),
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

  Widget _campoTexto({
    required String label,
    required TextEditingController controller,
    required IconData icone,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return SizedBox(
      height: maxLines > 1 ? null : 60,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icone),
          filled: true,
          fillColor: _card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: _borda,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: _borda,
            ),
          ),
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
      margin: const EdgeInsets.only(bottom: 18),
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
          const SizedBox(height: 16),
          ...filhos,
        ],
      ),
    );
  }

  Widget _abasModalidade({
    required int selecionada,
    required ValueChanged<int> onChanged,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          _modalidades.length,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_modalidades[index]),
              selected: selecionada == index,
              onSelected: (_) {
                onChanged(index);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEncontros() {
    final encontros = _listaEncontros(_abaEncontro);
    final dadoController = _dadoController(_abaEncontro);

    return _secao(
      _tituloCriaturas,
      Icons.pets,
      _vermelho,
      [
        _abasModalidade(
          selecionada: _abaEncontro,
          onChanged: (index) {
            setState(() {
              _abaEncontro = index;
            });
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: dadoController,
          maxLines: 1,
          decoration: InputDecoration(
            labelText:
                'Resultado dos dados,{_modalidades[_abaEncontro]}',
            hintText: 'Ex.: 1-3 Nada, 4-5 Criatura, 6 Personagem',
            prefixIcon: const Icon(
              Icons.casino_outlined,
            ),
            filled: true,
            fillColor: const Color(0xFFF8F7F3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: _borda,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: _borda,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (encontros.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Nenhuma criatura nesta modalidade.',
              style: TextStyle(
                color: _textoSecundario,
              ),
            ),
          ),
        ...encontros.map(
          (encontro) => Card(
            elevation: 0,
            color: const Color(0xFFF8F7F3),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              leading: const Icon(
                Icons.pets,
                color: Color(0xFFD64545),
              ),
              title: Text(
                encontro.criatura.nome,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                _resumoEncontro(encontro),
              ),
              onTap: () => _editarEncontro(
                encontro: encontro,
                modalidade: _abaEncontro,
              ),
              trailing: IconButton(
                tooltip: 'Excluir encontro',
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFD64545),
                ),
                onPressed: () => _excluirEncontro(
                  encontro,
                  _abaEncontro,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _editarEncontro(modalidade: _abaEncontro),
                icon: const Icon(Icons.library_add_outlined),
                label: const Text('Adicionar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _criarCriaturaBase,
                icon: const Icon(Icons.add),
                label: const Text('Criar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _resumoEncontro(Encontro encontro) {
    final partes = <String>[];

    if (encontro.raro) {
      partes.add('Raro');
    }

    if (encontro.periodo != null) {
      partes.add(_periodoTexto(encontro.periodo));
    }

    if (encontro.leguaMin != null || encontro.leguaMax != null) {
      final min = encontro.leguaMin?.toString() ?? '?';
      final max = encontro.leguaMax?.toString() ?? '?';
      partes.add('Léguas $min,?o$max');
    }

    if (encontro.nivelFixo != null) {
      partes.add('Nível ${encontro.nivelFixo}');
    }

    if (encontro.condicao.trim().isNotEmpty) {
      partes.add(encontro.condicao.trim());
    }

    return partes.isEmpty
        ? 'Sem restrií§íµes'
        : partes.join(' ,Á‚Â¢ ');
  }

  Widget _buildNPCs({
    required bool rocket,
  }) {
    final modalidade = rocket ? _abaRocket : _abaTreinador;

    final encontros = _listaNPC(
      rocket,
      modalidade,
    );

    final titulo = rocket ? _menuInimigos : _menuAliados;

    final cor = rocket ? _vermelho : _verde;

    return _secao(
      titulo,
      rocket ? Icons.groups_2_outlined : Icons.person_outline,
      cor,
      [
        _abasModalidade(
          selecionada: modalidade,
          onChanged: (index) {
            setState(() {
              if (rocket) {
                _abaRocket = index;
              } else {
                _abaTreinador = index;
              }
            });
          },
        ),
        const SizedBox(height: 12),
        if (encontros.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
            ),
            child: Text(
              rocket
                  ? 'Nenhum cadastro nesta modalidade.'
                  : 'Nenhum cadastro nesta modalidade.',
              style: const TextStyle(
                color: _textoSecundario,
              ),
            ),
          ),
        ...encontros.map(
          (encontro) => Card(
            elevation: 0,
            color: const Color(0xFFF8F7F3),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              leading: Icon(
                rocket ? Icons.groups_2_outlined : Icons.person_outline,
                color: cor,
              ),
              title: Text(
                encontro.npc.nome,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                _resumoNPC(encontro),
              ),
              onTap: () => _editarNPC(
                rocket: rocket,
                modalidade: modalidade,
                encontro: encontro,
              ),
              trailing: IconButton(
                tooltip: 'Excluir',
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFD64545),
                ),
                onPressed: () => _excluirNPC(
                  rocket,
                  encontro,
                  modalidade,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    _editarNPC(rocket: rocket, modalidade: modalidade),
                icon: const Icon(Icons.library_add_outlined),
                label: const Text('Adicionar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _criarNPCBase(rocket: rocket),
                icon: const Icon(Icons.add),
                label: const Text('Criar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _resumoNPC(EncontroNPC encontro) {
    final partes = <String>[];

    if (encontro.raro) {
      partes.add('Raro');
    }

    if (encontro.periodo != null) {
      partes.add(_periodoTexto(encontro.periodo));
    }

    if (encontro.leguaMin != null || encontro.leguaMax != null) {
      final min = encontro.leguaMin?.toString() ?? '?';
      final max = encontro.leguaMax?.toString() ?? '?';
      partes.add('Léguas $min,?o$max');
    }

    if (encontro.npc.localizacao.trim().isNotEmpty) {
      partes.add(encontro.npc.localizacao.trim());
    }

    return partes.isEmpty
        ? 'Sem restrições'
        : partes.join(' ,Á‚Â¢ ');
  }

  Widget _buildEventos() {
    return _secao(
      'Eventos',
      Icons.warning_amber_rounded,
      _laranja,
      [
        TextField(
          controller: _dadoEventosController,
          maxLines: 1,
          decoration: InputDecoration(
            labelText: 'Resultado dos dados ,? Eventos',
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
        if (_localAtual.eventos.isEmpty)
          const Text(
            'Nenhum evento incluído neste Local.',
            style: TextStyle(color: _textoSecundario),
          ),
        ..._localAtual.eventos.map(
          (evento) => Card(
            elevation: 0,
            color: const Color(0xFFF8F7F3),
            child: ListTile(
              leading: const Icon(
                Icons.warning_amber_rounded,
                color: _laranja,
              ),
              title: Text(
                evento.nome,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                evento.descricao.isEmpty
                    ? 'Sem descrií§í£o'
                    : evento.descricao,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _editarEvento(
                evento: evento,
              ),
              trailing: IconButton(
                tooltip: 'Excluir evento deste Local',
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFD64545),
                ),
                onPressed: () => _excluirEvento(evento),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _incluirEvento,
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

  Widget _buildPontos() {
    return _secao(
      'Pontos de Interesse',
      Icons.place_outlined,
      _azul,
      [
        if (_localAtual.pontosInteresse.isEmpty)
          const Text(
            'Nenhum ponto de interesse incluído.',
            style: TextStyle(color: _textoSecundario),
          ),
        ..._localAtual.pontosInteresse.map(
          (ponto) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 76,
                  child: Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    color: const Color(0xFFF8F7F3),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Légua',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _textoSecundario,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            key: ValueKey('leguas-${ponto.id}-${ponto.leguas}'),
                            initialValue: _leguasPontosTexto[ponto.id] ??
                                ponto.leguas.toString(),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 6,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (valor) {
                              _leguasPontosTexto[ponto.id] = valor;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    elevation: 0,
                    color: const Color(0xFFF8F7F3),
                    child: InkWell(
                      onTap: () => _editarPonto(ponto: ponto),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.place_outlined, color: _azul),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    ponto.nome,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ponto.descricao.isEmpty
                                        ? 'Sem descrií§í£o'
                                        : ponto.descricao,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Excluir ponto deste Local',
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Color(0xFFD64545),
                              ),
                              onPressed: () => _excluirPonto(ponto),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _incluirPonto,
                icon: const Icon(Icons.library_add_outlined),
                label: const Text('Adicionar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _criarPontoBase,
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
          backgroundColor: Color(0xFFD64545),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Editar Local',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Salvar',
              icon: const Icon(Icons.save_outlined),
              onPressed: _salvar,
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
            Container(
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _borda),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Color(0xFFD64545),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.map_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _localAtual.nome,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: _texto,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _secao(
              'Características',
              Icons.tune,
              _azul,
              [
                _campoTexto(
                  label: 'Nome do Local',
                  controller: _nomeController,
                  icone: Icons.edit_location_alt,
                ),
                const SizedBox(height: 12),
                _campoTexto(
                  label: 'Descrií§í£o',
                  controller: _descricaoController,
                  icone: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _regiaoController,
                        decoration: const InputDecoration(
                          labelText: 'Região',
                          prefixIcon: Icon(Icons.public),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _campoTexto(
                        label: 'Léguas',
                        controller: _leguasController,
                        icone: Icons.straighten,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _campoTexto(
                  label: 'Terreno',
                  controller: _terrenoController,
                  icone: Icons.terrain,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                _buildConexoes(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _campoTexto(
                        label: 'Nível mínimo',
                        controller: _nivelMinController,
                        icone: Icons.arrow_downward,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _campoTexto(
                        label: 'Nível máximo',
                        controller: _nivelMaxController,
                        icone: Icons.arrow_upward,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _buildEncontros(),
            _buildNPCs(rocket: false),
            _buildNPCs(rocket: true),
            _buildEventos(),
            _buildPontos(),
            _buildItens(),
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

  late List<Item> _filtrados;

  @override
  void initState() {
    super.initState();
    _filtrados = List<Item>.from(widget.itens);
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  void _filtrar(String valor) {
    final termo = valor.trim().toLowerCase();

    setState(() {
      _filtrados = widget.itens
          .where(
            (item) => item.nome.toLowerCase().contains(termo),
          )
          .toList()
        ..sort(
          (a, b) => a.nome.toLowerCase().compareTo(
                b.nome.toLowerCase(),
              ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecionar Item-base'),
      content: SizedBox(
        width: 520,
        height: 460,
        child: Column(
          children: [
            TextField(
              controller: _busca,
              onChanged: _filtrar,
              decoration: const InputDecoration(
                labelText: 'Buscar item',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: _filtrados.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = _filtrados[index];

                  return ListTile(
                    leading: const Icon(
                      Icons.inventory_2_outlined,
                    ),
                    title: Text(
                      item.nome.isEmpty ? 'Item sem nome' : item.nome,
                    ),
                    subtitle: Text(
                      item.tipo.trim().isEmpty ? 'Sem tipo' : item.tipo,
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

class _ItemLocalDialog extends StatefulWidget {
  final Item item;

  const _ItemLocalDialog({
    required this.item,
  });

  @override
  State<_ItemLocalDialog> createState() => _ItemLocalDialogState();
}

class _ItemLocalDialogState extends State<_ItemLocalDialog> {
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

    _nome = TextEditingController(
      text: widget.item.nome,
    );
    _tipo = TextEditingController(
      text: widget.item.tipo,
    );
    _descricao = TextEditingController(
      text: widget.item.descricao,
    );
    _custo = TextEditingController(
      text: widget.item.custoEmCreditos.toString(),
    );
    _efeito = TextEditingController(
      text: widget.item.efeito,
    );
    _localizacao = TextEditingController(
      text: widget.item.localizacao,
    );
    _quantidade = TextEditingController(
      text: widget.item.quantidade.toString(),
    );
  }

  @override
  void dispose() {
    _nome.dispose();
    _tipo.dispose();
    _descricao.dispose();
    _custo.dispose();
    _efeito.dispose();
    _localizacao.dispose();
    _quantidade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar item'),
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
                controller: _custo,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Preí§o',
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
                controller: _quantidade,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantidade',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _localizacao,
                decoration: const InputDecoration(
                  labelText: 'Légua',
                ),
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
            final nome = _nome.text.trim();

            if (nome.isEmpty) {
              return;
            }

            final quantidade = int.tryParse(_quantidade.text.trim()) ?? 1;

            if (quantidade < 1) {
              return;
            }

            Navigator.pop(
              context,
              widget.item.copyWith(
                nome: nome,
                tipo: _tipo.text.trim(),
                descricao: _descricao.text.trim(),
                custoEmCreditos: int.tryParse(_custo.text.trim()) ?? 0,
                efeito: _efeito.text.trim(),
                localizacao: _localizacao.text.trim(),
                quantidade: quantidade,
              ),
            );
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

    _condicao = TextEditingController(
      text: widget.encontro?.condicao ?? '',
    );

    _leguaMin = TextEditingController(
      text: widget.encontro?.leguaMin?.toString() ?? '',
    );

    _leguaMax = TextEditingController(
      text: widget.encontro?.leguaMax?.toString() ?? '',
    );

    _nivelFixo = TextEditingController(
      text: widget.encontro?.nivelFixo?.toString() ?? '',
    );

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

  String _periodoTexto(PeriodoDia periodo) {
    return periodo.texto;
  }

  List<Criatura> _criaturasFiltrados() {
    final busca = _buscaCriatura.text.trim().toLowerCase();

    if (busca.isEmpty) {
      return const [];
    }

    final resultados = widget.criaturas.where((criatura) {
      final nome = criatura.nome.toLowerCase();
      final numero = criatura.numero.toString();

      return nome.contains(busca) || numero.contains(busca);
    }).toList();

    resultados.sort((a, b) {
      final comparacaoNumero = (a.numero ?? 999999).compareTo(
        b.numero ?? 999999,
      );

      if (comparacaoNumero != 0) {
        return comparacaoNumero;
      }

      return a.nome.toLowerCase().compareTo(
            b.nome.toLowerCase(),
          );
    });

    return resultados.take(20).toList();
  }

  void _selecionarCriatura(Criatura criatura) {
    setState(() {
      _criatura = criatura;
      _buscaCriatura.clear();
    });
  }

  Widget _buildBuscaCriatura() {
    final resultados = _criaturasFiltrados();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _buscaCriatura,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Buscar ${widget.nomeCriatura}',
            hintText:
                'Nome ou n\u00FAmero de ${widget.nomeCriatura.toLowerCase()}',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _buscaCriatura.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Limpar busca',
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _buscaCriatura.clear();
                      });
                    },
                  ),
          ),
        ),
        if (_buscaCriatura.text.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 280),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD8D3C7)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: resultados.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Nenhum resultado encontrado.'),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: resultados.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final criatura = resultados[index];

                      return ListTile(
                        dense: true,
                        leading: criatura.numero == null
                            ? null
                            : Text(
                                '#${criatura.numero}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFD64545),
                                ),
                              ),
                        title: Text(
                          criatura.nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onTap: () => _selecionarCriatura(criatura),
                      );
                    },
                  ),
          ),
        ],
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F7F3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD8D3C7)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.pets,
                color: Color(0xFFD64545),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _criatura.numero == null
                      ? _criatura.nome
                      : '#${_criatura.numero} ${_criatura.nome}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.encontro == null ? 'Adicionar encontro' : 'Editar encontro',
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBuscaCriatura(),
              const SizedBox(height: 12),
              TextField(
                controller: _condicao,
                decoration: const InputDecoration(
                  labelText: 'Condií§í£o',
                  hintText: 'Ex.: Comum, Raro, durante chuva...',
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
                      .where(
                        (periodo) => periodo != PeriodoDia.qualquer,
                      )
                      .map(
                        (periodo) => DropdownMenuItem<PeriodoDia?>(
                          value: periodo,
                          child: Text(
                            _periodoTexto(periodo),
                          ),
                        ),
                      ),
                ],
                onChanged: (periodo) {
                  setState(() {
                    _periodo = periodo;
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _leguaMin,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Légua mínima',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _leguaMax,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Légua máxima',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nivelFixo,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nível fixo',
                  hintText: 'Vazio = usa faixa do Local',
                ),
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Encontro raro'),
                value: _raro,
                onChanged: (valor) {
                  setState(() {
                    _raro = valor;
                  });
                },
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
                leguaMin: int.tryParse(
                  _leguaMin.text.trim(),
                ),
                leguaMax: int.tryParse(
                  _leguaMax.text.trim(),
                ),
                nivelFixo: int.tryParse(
                  _nivelFixo.text.trim(),
                ),
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
  final EncontroNPC? encontro;
  final String tipo;
  final String tipoCadastro;
  final bool inimigo;
  final List<NPC> cadastrosBase;

  const _NPCDialog({
    required this.encontro,
    required this.tipo,
    required this.tipoCadastro,
    required this.inimigo,
    required this.cadastrosBase,
  });

  @override
  State<_NPCDialog> createState() => _NPCDialogState();
}

class _NPCDialogState extends State<_NPCDialog> {
  NPC? _npcBaseSelecionado;

  late final TextEditingController _nome;
  late final TextEditingController _descricao;
  late final TextEditingController _localizacao;
  late final TextEditingController _pv;
  late final TextEditingController _nivelCriatura;
  late final TextEditingController _leguaMin;
  late final TextEditingController _leguaMax;
  late final TextEditingController _busca;

  bool _raro = false;
  PeriodoDia? _periodo;

  @override
  void initState() {
    super.initState();

    final npc = widget.encontro?.npc;

    _npcBaseSelecionado = npc;

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

    _leguaMin = TextEditingController(
      text: widget.encontro?.leguaMin?.toString() ?? '',
    );

    _leguaMax = TextEditingController(
      text: widget.encontro?.leguaMax?.toString() ?? '',
    );

    _busca = TextEditingController();

    _raro = widget.encontro?.raro ?? false;
    _periodo = widget.encontro?.periodo;
  }

  @override
  void dispose() {
    _nome.dispose();
    _descricao.dispose();
    _localizacao.dispose();
    _pv.dispose();
    _nivelCriatura.dispose();
    _leguaMin.dispose();
    _leguaMax.dispose();
    _busca.dispose();
    super.dispose();
  }

  String _periodoTexto(PeriodoDia periodo) {
    return periodo.texto;
  }

  List<NPC> _filtrarCadastros() {
    final busca = _busca.text.trim().toLowerCase();

    if (busca.isEmpty) {
      return widget.cadastrosBase;
    }

    return widget.cadastrosBase
        .where(
          (npc) =>
              npc.nome.toLowerCase().contains(busca) ||
              npc.descricao.toLowerCase().contains(busca),
        )
        .toList();
  }

  void _selecionarCadastroBase(NPC npc) {
    final copia = NPC.fromMap({
      ...npc.toMap(),
      'id': 'NPC-${DateTime.now().microsecondsSinceEpoch}',
      'cadastroBaseId': npc.id,
      'localizacao': '',
    });

    setState(() {
      _npcBaseSelecionado = copia;
      _nome.text = copia.nome;
      _descricao.text = copia.descricao;
      _localizacao.text = copia.localizacao;
      _pv.text = copia.pv.toString();
      _nivelCriatura.text = copia.nivelCriatura;
      _busca.clear();
    });
  }

  Widget _buildSelecaoBase() {
    final resultados = _filtrarCadastros();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cadastro-base',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _busca,
          onChanged: (_) {
            setState(() {});
          },
          decoration: InputDecoration(
            labelText: 'Buscar ${widget.tipo}',
            hintText: 'Digite o nome',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _busca.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Limpar busca',
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _busca.clear();
                      });
                    },
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(
            maxHeight: 220,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFD8D3C7),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: resultados.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Nenhum cadastro encontrado.',
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: resultados.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final npc = resultados[index];

                    return ListTile(
                      leading: Icon(
                        widget.inimigo
                            ? Icons.groups_2_outlined
                            : Icons.person_outline,
                        color: widget.inimigo
                            ? const Color(
                                0xFFD64545,
                              )
                            : const Color(
                                0xFF4D9B62,
                              ),
                      ),
                      title: Text(
                        npc.nome.isEmpty ? 'Sem nome' : npc.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: npc.descricao.isEmpty
                          ? null
                          : Text(
                              npc.descricao,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                      onTap: () {
                        _selecionarCadastroBase(
                          npc,
                        );
                      },
                    );
                  },
                ),
        ),
        if (_npcBaseSelecionado != null)
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7F3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD8D3C7),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.inimigo
                        ? Icons.groups_2_outlined
                        : Icons.person_outline,
                    color: widget.inimigo
                        ? const Color(
                            0xFFD64545,
                          )
                        : const Color(
                            0xFF4D9B62,
                          ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _npcBaseSelecionado!.nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final incluindo = widget.encontro == null;

    return AlertDialog(
      title: Text(
        incluindo ? 'Incluir ${widget.tipo}' : 'Editar ${widget.tipo}',
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (incluindo) ...[
                _buildSelecaoBase(),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _nome,
                enabled: !incluindo || _npcBaseSelecionado != null,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: const Icon(
                    Icons.person_outline,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descricao,
                enabled: !incluindo || _npcBaseSelecionado != null,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrií§í£o',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _localizacao,
                enabled: !incluindo || _npcBaseSelecionado != null,
                decoration: const InputDecoration(
                  labelText: 'Localizaí§í£o',
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
                      enabled: !incluindo || _npcBaseSelecionado != null,
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
                      enabled: !incluindo || _npcBaseSelecionado != null,
                      decoration: const InputDecoration(
                        labelText: 'Nível da criatura',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                      .where(
                        (periodo) => periodo != PeriodoDia.qualquer,
                      )
                      .map(
                        (periodo) => DropdownMenuItem<PeriodoDia?>(
                          value: periodo,
                          child: Text(
                            _periodoTexto(
                              periodo,
                            ),
                          ),
                        ),
                      ),
                ],
                onChanged: (periodo) {
                  setState(() {
                    _periodo = periodo;
                  });
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _leguaMin,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Légua mínima',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _leguaMax,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Légua máxima',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Encontro raro',
                ),
                value: _raro,
                onChanged: (valor) {
                  setState(() {
                    _raro = valor;
                  });
                },
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
          onPressed: incluindo && _npcBaseSelecionado == null
              ? null
              : () {
                  final antigo = widget.encontro?.npc;

                  final npc = NPC(
                    id: incluindo ? _npcBaseSelecionado!.id : antigo!.id,
                    nome: _nome.text.trim(),
                    tipo: widget.tipoCadastro,
                    descricao: _descricao.text.trim(),
                    cadastroBaseId: incluindo
                        ? _npcBaseSelecionado!.cadastroBaseId
                        : antigo!.cadastroBaseId,
                    localizacao: _localizacao.text.trim(),
                    forca: antigo?.forca ?? _npcBaseSelecionado?.forca ?? 0,
                    habilidade: antigo?.habilidade ??
                        _npcBaseSelecionado?.habilidade ??
                        0,
                    inteligencia: antigo?.inteligencia ??
                        _npcBaseSelecionado?.inteligencia ??
                        0,
                    resistencia: antigo?.resistencia ??
                        _npcBaseSelecionado?.resistencia ??
                        0,
                    armadura:
                        antigo?.armadura ?? _npcBaseSelecionado?.armadura ?? 0,
                    poderDeFogo: antigo?.poderDeFogo ??
                        _npcBaseSelecionado?.poderDeFogo ??
                        0,
                    captura:
                        antigo?.captura ?? _npcBaseSelecionado?.captura ?? 0,
                    controle:
                        antigo?.controle ?? _npcBaseSelecionado?.controle ?? 0,
                    compreensao: antigo?.compreensao ??
                        _npcBaseSelecionado?.compreensao ??
                        0,
                    tratamento: antigo?.tratamento ??
                        _npcBaseSelecionado?.tratamento ??
                        0,
                    ecologia:
                        antigo?.ecologia ?? _npcBaseSelecionado?.ecologia ?? 0,
                    kit: antigo?.kit ?? _npcBaseSelecionado?.kit ?? '',
                    manobras:
                        antigo?.manobras ?? _npcBaseSelecionado?.manobras ?? '',
                    vantagens: antigo?.vantagens ??
                        _npcBaseSelecionado?.vantagens ??
                        '',
                    desvantagens: antigo?.desvantagens ??
                        _npcBaseSelecionado?.desvantagens ??
                        '',
                    criaturas: antigo?.criaturas ??
                        _npcBaseSelecionado?.criaturas ??
                        const [],
                    fichasCriatura: antigo?.fichasCriatura ??
                        _npcBaseSelecionado?.fichasCriatura ??
                        const [],
                    nivelCriatura: _nivelCriatura.text.trim(),
                    inventario: antigo?.inventario ??
                        _npcBaseSelecionado?.inventario ??
                        '',
                    pv: int.tryParse(
                          _pv.text.trim(),
                        ) ??
                        antigo?.pv ??
                        _npcBaseSelecionado?.pv ??
                        0,
                  );

                  Navigator.pop(
                    context,
                    EncontroNPC(
                      npc: npc,
                      raro: _raro,
                      periodo: _periodo,
                      leguaMin: int.tryParse(
                        _leguaMin.text.trim(),
                      ),
                      leguaMax: int.tryParse(
                        _leguaMax.text.trim(),
                      ),
                    ),
                  );
                },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class _ConexaoLocalEdicao {
  _ConexaoLocalEdicao({
    this.direcao = 'Norte',
    String leguas = '',
    this.localId,
  }) : leguasController = TextEditingController(text: leguas);

  String direcao;
  final TextEditingController leguasController;
  String? localId;

  void dispose() {
    leguasController.dispose();
  }
}
