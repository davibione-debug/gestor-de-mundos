import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/npc.dart';
import '../../models/criatura.dart';
import '../../models/poder.dart';
import '../../models/item.dart';
import '../../repositories/npcs_repository.dart';
import '../../repositories/criaturas_repository.dart';
import '../../repositories/itens_repository.dart';
import '../itens/item_editar_screen.dart';
import '../bestiario/criatura_editar_screen.dart';

class NPCEditScreen extends StatefulWidget {
  final NPC npc;
  final bool novo;

  const NPCEditScreen({
    super.key,
    required this.npc,
    this.novo = false,
  });

  @override
  State<NPCEditScreen> createState() => _NPCEditScreenState();
}

class _NPCEditScreenState extends State<NPCEditScreen> {
  String _nomePersonagens = 'Personagens';
  final NPCsRepository _repository = NPCsRepository();

  late final TextEditingController _nomeController;
  late final TextEditingController _tipoController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _localizacaoController;

  late final TextEditingController _forcaController;
  late final TextEditingController _habilidadeController;
  late final TextEditingController _inteligenciaController;
  late final TextEditingController _resistenciaController;
  late final TextEditingController _armaduraController;
  late final TextEditingController _poderDeFogoController;

  late final TextEditingController _capturaController;
  late final TextEditingController _controleController;
  late final TextEditingController _compreensaoController;
  late final TextEditingController _tratamentoController;
  late final TextEditingController _ecologiaController;

  late final TextEditingController _kitController;
  late final TextEditingController _manobrasController;
  late final TextEditingController _vantagensController;
  late final TextEditingController _desvantagensController;
  late final TextEditingController _creditosController;

  late List<CriaturaTreinador> _fichasCriatura;
  late List<Item> _itens;

  bool _salvando = false;

  @override
  void initState() {
    super.initState();

    _carregarNomesConfigurados();

    final npc = widget.npc;

    _nomeController = TextEditingController(text: npc.nome);
    _tipoController = TextEditingController(text: npc.tipo);
    _descricaoController = TextEditingController(text: npc.descricao);
    _localizacaoController = TextEditingController(text: npc.localizacao);

    _forcaController = TextEditingController(text: '${npc.forca}');
    _habilidadeController = TextEditingController(text: '${npc.habilidade}');
    _inteligenciaController =
        TextEditingController(text: '${npc.inteligencia}');
    _resistenciaController = TextEditingController(text: '${npc.resistencia}');
    _armaduraController = TextEditingController(text: '${npc.armadura}');
    _poderDeFogoController = TextEditingController(text: '${npc.poderDeFogo}');

    _capturaController = TextEditingController(text: '${npc.captura}');
    _controleController = TextEditingController(text: '${npc.controle}');
    _compreensaoController = TextEditingController(text: '${npc.compreensao}');
    _tratamentoController = TextEditingController(text: '${npc.tratamento}');
    _ecologiaController = TextEditingController(text: '${npc.ecologia}');

    _kitController = TextEditingController(text: npc.kit);
    _manobrasController = TextEditingController(text: npc.manobras);
    _vantagensController = TextEditingController(text: npc.vantagens);
    _desvantagensController = TextEditingController(text: npc.desvantagens);
    _creditosController = TextEditingController(text: '${npc.creditos}');

    _fichasCriatura = List<CriaturaTreinador>.from(npc.fichasCriatura);

    // Garante que toda criatura listada no NPC tenha uma ficha (mesmo que vazia)
    for (final nome in npc.criaturas) {
      final existe = _fichasCriatura.any(
        (f) => _normalizarNome(f.nome) == _normalizarNome(nome),
      );
      if (!existe) {
        _fichasCriatura.add(CriaturaTreinador(nome: nome, nivel: 1));
      }
    }
    _itens = List<Item>.from(npc.itens);
  }

  Future<void> _preencherPoderesDasFichas() async {
    final criaturasBase = await CriaturasRepository().carregar();
    bool alterou = false;

    for (int i = 0; i < _fichasCriatura.length; i++) {
      final ficha = _fichasCriatura[i];
      final base = criaturasBase.firstWhere(
        (c) => _normalizarNome(c.nome) == _normalizarNome(ficha.nome),
        orElse: () => Criatura(nome: '', tipos: const [], forca: 0, habilidade: 0, resistencia: 0, armadura: 0, defesaEspecial: 0, poderDeFogo: 0, poderes: const []),
      );

      if (base.poderes.isEmpty) continue;

      // Junta os poderes da base com os poderes ja existentes na ficha
      final poderesMesclados = <Poder>[];
      final tiposAdicionados = <String>{};

      // Adiciona os poderes da base primeiro
      for (final p in base.poderes) {
        if (!tiposAdicionados.contains(p.tipo)) {
          poderesMesclados.add(p);
          tiposAdicionados.add(p.tipo);
        }
      }

      // Adiciona os poderes que estao na ficha mas nao na base
      for (final p in ficha.poderes) {
        if (!tiposAdicionados.contains(p.tipo)) {
          poderesMesclados.add(p);
          tiposAdicionados.add(p.tipo);
        } else {
          // Se o poder ja existe na base, mantem o bonus da ficha
          final index = poderesMesclados.indexWhere((mp) => mp.tipo == p.tipo);
          if (index >= 0) {
            poderesMesclados[index] = Poder(
              tipo: p.tipo,
              valorBase: poderesMesclados[index].valorBase,
              bonus: p.bonus,
              original: poderesMesclados[index].original,
            );
          }
        }
      }

      _fichasCriatura[i] = CriaturaTreinador(
        nome: ficha.nome,
        nivel: ficha.nivel,
        bonusForca: ficha.bonusForca,
        bonusHabilidade: ficha.bonusHabilidade,
        bonusResistencia: ficha.bonusResistencia,
        bonusArmadura: ficha.bonusArmadura,
        bonusDefesaEspecial: ficha.bonusDefesaEspecial,
        bonusPoderDeFogo: ficha.bonusPoderDeFogo,
        poderes: poderesMesclados,
        poderesExtras: ficha.poderesExtras,
        pv: ficha.pv,
        pe: ficha.pe,
        moves: List<String>.from(ficha.moves),
      );
      alterou = true;
    }

    if (alterou && mounted) {
      setState(() {});
    }
  }
  Future<void> _carregarNomesConfigurados() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _nomePersonagens = prefs.getString('menu_personagens') ?? 'Personagens';
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _tipoController.dispose();
    _descricaoController.dispose();
    _localizacaoController.dispose();

    _forcaController.dispose();
    _habilidadeController.dispose();
    _inteligenciaController.dispose();
    _resistenciaController.dispose();
    _armaduraController.dispose();
    _poderDeFogoController.dispose();

    _capturaController.dispose();
    _controleController.dispose();
    _compreensaoController.dispose();
    _tratamentoController.dispose();
    _ecologiaController.dispose();

    _kitController.dispose();
    _manobrasController.dispose();
    _vantagensController.dispose();
    _desvantagensController.dispose();
    _creditosController.dispose();

    super.dispose();
  }

  int _int(TextEditingController controller) {
    return int.tryParse(controller.text.trim()) ?? 0;
  }

  List<String> _criaturas() {
    return _fichasCriatura.map((ficha) => ficha.nome).toList();
  }

  CriaturaTreinador? _fichaDoCriatura(String nome) {
    final normalizado = _normalizarNome(nome);
    for (final ficha in _fichasCriatura) {
      if (_normalizarNome(ficha.nome) == normalizado) {
        return ficha;
      }
    }
    return null;
  }
  String _normalizarNome(String texto) {
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
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  Future<void> _editarFichaCriatura(String nome) async {
    final fichaExistente = _fichaDoCriatura(nome);

    // Busca os poderes da criatura base
    final criaturasBase = await CriaturasRepository().carregar();
    final base = criaturasBase.firstWhere(
      (c) => _normalizarNome(c.nome) == _normalizarNome(nome),
      orElse: () => Criatura(nome: '', tipos: const [], forca: 0, habilidade: 0, resistencia: 0, armadura: 0, defesaEspecial: 0, poderDeFogo: 0, poderes: const []),
    );

    // Mescla os poderes da base com os da ficha
    final poderesMesclados = <Poder>[];
    final tiposAdicionados = <String>{};

    for (final p in base.poderes) {
      if (!tiposAdicionados.contains(p.tipo)) {
        poderesMesclados.add(p);
        tiposAdicionados.add(p.tipo);
      }
    }

    if (fichaExistente != null) {
      for (final p in fichaExistente.poderes) {
        if (!tiposAdicionados.contains(p.tipo)) {
          poderesMesclados.add(p);
          tiposAdicionados.add(p.tipo);
        } else {
          final index = poderesMesclados.indexWhere((mp) => mp.tipo == p.tipo);
          if (index >= 0) {
            poderesMesclados[index] = Poder(
              tipo: p.tipo,
              valorBase: poderesMesclados[index].valorBase,
              bonus: p.bonus,
              original: poderesMesclados[index].original,
            );
          }
        }
      }
    }

    final fichaParaEditar = CriaturaTreinador(
      nome: nome.trim(),
      nivel: fichaExistente?.nivel ?? 1,
      bonusForca: fichaExistente?.bonusForca ?? 0,
      bonusHabilidade: fichaExistente?.bonusHabilidade ?? 0,
      bonusResistencia: fichaExistente?.bonusResistencia ?? 0,
      bonusArmadura: fichaExistente?.bonusArmadura ?? 0,
      bonusDefesaEspecial: fichaExistente?.bonusDefesaEspecial ?? 0,
      bonusPoderDeFogo: fichaExistente?.bonusPoderDeFogo ?? 0,
      poderes: poderesMesclados,
      poderesExtras: fichaExistente?.poderesExtras ?? 0,
      pv: fichaExistente?.pv ?? 0,
      pe: fichaExistente?.pe ?? 0,
      moves: fichaExistente?.moves ?? const [],
    );

    final resultado = await showDialog<CriaturaTreinador>(
      context: context,
      builder: (_) => _FichaCriaturaDialog(
        ficha: fichaParaEditar,
      ),
    );

    if (resultado == null || !mounted) {
      return;
    }

    setState(() {
      final indice = _fichasCriatura.indexWhere(
        (item) => _normalizarNome(item.nome) == _normalizarNome(nome),
      );

      if (indice == -1) {
        _fichasCriatura.add(resultado);
      } else {
        _fichasCriatura[indice] = resultado;
      }
    });
  }
  Future<void> _adicionarCriatura() async {
    final criaturasBase = await CriaturasRepository().carregar();

    if (!mounted) return;

    if (criaturasBase.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma criatura cadastrada no bestiário.'),
        ),
      );
      return;
    }

    criaturasBase.sort(
      (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
    );

    final criaturaSelecionada = await showDialog<Criatura>(
      context: context,
      builder: (context) => _SelecionarCriaturaDialog(criaturas: criaturasBase),
    );

    if (criaturaSelecionada == null || !mounted) {
      return;
    }

    final nome = criaturaSelecionada.nome;

    final existe = _criaturas().any(
      (c) => _normalizarNome(c) == _normalizarNome(nome),
    );

    if (existe) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Essa criatura já está na ficha.'),
        ),
      );
      return;
    }

    setState(() {});

    await _editarFichaCriatura(nome);
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
      setState(() {});
      await _editarFichaCriatura(resultado.nome);
    }
  }

  Future<void> _editarCriaturaSelecionado(String nome) async {
    await _editarFichaCriatura(nome);
  }

  void _removerCriatura(String nome) {
    setState(() {
      _fichasCriatura.removeWhere(
        (ficha) => _normalizarNome(ficha.nome) == _normalizarNome(nome),
      );
    });
  }

  Future<void> _adicionarItem() async {
    final itensBase = await ItensRepository().carregar();

    if (!mounted) {
      return;
    }

    if (itensBase.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum item cadastrado no Cadastro-base.'),
        ),
      );
      return;
    }

    final item = await showDialog<Item>(
      context: context,
      builder: (_) => _SelecionarItemDialog(
        itens: itensBase,
      ),
    );

    if (item == null || !mounted) {
      return;
    }

    final copia = item.copyWith();

    final quantidade = await showDialog<int>(
      context: context,
      builder: (_) => _QuantidadeItemDialog(
        quantidade: 1,
      ),
    );

    if (quantidade == null || !mounted) {
      return;
    }

    setState(() {
      _itens.add(
        copia.copyWith(
          quantidade: quantidade,
        ),
      );
    });
  }

  Future<void> _criarItem() async {
    final resultado = await Navigator.push<bool>(
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

    if (resultado != true || !mounted) return;

    final itens = await ItensRepository().carregar();
    if (!mounted) return;
    if (itens.isEmpty) return;

    itens.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    final novo = itens.last;

    setState(() {
      _itens.add(
        novo.copyWith(quantidade: 1, localizacao: ''),
      );
    });
  }
  Future<void> _editarItem(int indice) async {
    final item = _itens[indice];

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
      _itens[indice] = resultado;
    });
  }

  void _removerItem(int indice) {
    setState(() {
      _itens.removeAt(indice);
    });
  }

  Widget _listaItens() {
    if (_itens.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Nenhum item cadastrado.',
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
      );
    }

    return Column(
      children: List.generate(
        _itens.length,
        (indice) {
          final item = _itens[indice];

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.inventory_2_outlined),
              ),
              title: Text(
                '${item.nome} \u00d7 ${item.quantidade}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text(
                item.tipo.isEmpty ? item.descricao : item.tipo,
              ),
              trailing: Wrap(
                spacing: 0,
                children: [
                  IconButton(
                    tooltip: 'Editar item',
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    onPressed: () => _editarItem(indice),
                  ),
                  IconButton(
                    tooltip: 'Remover item',
                    icon: const Icon(
                      Icons.delete_outline,
                    ),
                    onPressed: () => _removerItem(indice),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _salvar() async {
    final nome = _nomeController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Informe o nome do $_nomePersonagens.',
          ),
        ),
      );
      return;
    }

    if (_salvando) {
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final nomesCriatura = _criaturas();

      final fichas = _fichasCriatura
          .where(
            (ficha) => nomesCriatura.any(
              (nomeCriatura) =>
                  _normalizarNome(nomeCriatura) == _normalizarNome(ficha.nome),
            ),
          )
          .toList();

      final atualizado = NPC(
        id: widget.npc.id.isEmpty
            ? DateTime.now().microsecondsSinceEpoch.toString()
            : widget.npc.id,
        nome: nome,
        tipo: _tipoController.text.trim(),
        descricao: _descricaoController.text.trim(),
        localizacao: _localizacaoController.text.trim(),
        forca: _int(_forcaController),
        habilidade: _int(_habilidadeController),
        inteligencia: _int(_inteligenciaController),
        resistencia: _int(_resistenciaController),
        armadura: _int(_armaduraController),
        poderDeFogo: _int(_poderDeFogoController),
        captura: _int(_capturaController),
        controle: _int(_controleController),
        compreensao: _int(_compreensaoController),
        tratamento: _int(_tratamentoController),
        ecologia: _int(_ecologiaController),
        kit: _kitController.text.trim(),
        manobras: _manobrasController.text.trim(),
        vantagens: _vantagensController.text.trim(),
        desvantagens: _desvantagensController.text.trim(),
        criaturas: nomesCriatura,
        fichasCriatura: fichas,
        nivelCriatura: '',
        inventario: '',
        pv: _int(_resistenciaController) * 5,
        creditos: _int(_creditosController),
        itens: List<Item>.from(_itens),
      );

      await _repository.salvar(atualizado);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _salvando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível salvar o $_nomePersonagens: $e',
          ),
        ),
      );
    }
  }

  Widget _campoTexto(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          filled: true,
        ),
      ),
    );
  }

  Widget _campoNumero(
    String label,
    TextEditingController controller,
  ) {
    return _campoTexto(
      label,
      controller,
      keyboardType: TextInputType.number,
    );
  }

  Widget _secao(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 12,
        bottom: 12,
      ),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
  Widget _gradeNumerica(
    List<MapEntry<String, TextEditingController>> campos,
  ) {
    final linhas = <Widget>[];

    for (int i = 0; i < campos.length; i += 2) {
      final esquerda = campos[i];

      final direita = i + 1 < campos.length ? campos[i + 1] : null;

      linhas.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _campoNumero(
                esquerda.key,
                esquerda.value,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: direita == null
                  ? const SizedBox.shrink()
                  : _campoNumero(
                      direita.key,
                      direita.value,
                    ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: linhas,
    );
  }

  Widget _listaCriatura() {
    final nomes = _criaturas();

    if (nomes.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Nenhum cadastro.',
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
      );
    }

    return Column(
      children: nomes.map((nome) {
        final ficha = _fichaDoCriatura(nome);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.pets),
            ),
            title: Text(
              nome,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: ficha == null
                ? const Text('Ficha ainda não configurada')
                : Text('Nível ${ficha.nivel}'),
            trailing: Wrap(
              spacing: 0,
              children: [
                IconButton(
                  tooltip: 'Editar ficha',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _editarCriaturaSelecionado(nome),
                ),
                IconButton(
                  tooltip: 'Remover Criatura',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _removerCriatura(nome),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titulo = widget.novo
        ? 'Novo $_nomePersonagens'
        : 'Editar $_nomePersonagens';

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _secao('Identificação'),
            _campoTexto(
              'Nome',
              _nomeController,
              hint: 'Nome do $_nomePersonagens',
            ),
            _campoTexto(
              'Tipo',
              _tipoController,
              hint: 'Ex.: Líder de Ginásio',
            ),
            _campoTexto(
              'Descrição',
              _descricaoController,
              maxLines: 4,
            ),
            _secao('Características'),
            _gradeNumerica([
              MapEntry('Força', _forcaController),
              MapEntry('Habilidade', _habilidadeController),
              MapEntry('Inteligência', _inteligenciaController),
              MapEntry('Resistência', _resistenciaController),
              MapEntry('Armadura', _armaduraController),
              MapEntry('Poder de Fogo', _poderDeFogoController),
            ]),
            _secao('Conhecimentos'),
            _gradeNumerica([
              MapEntry('Captura', _capturaController),
              MapEntry('Controle', _controleController),
              MapEntry('Compreensão', _compreensaoController),
              MapEntry('Tratamento', _tratamentoController),
              MapEntry('Ecologia', _ecologiaController),
            ]),
            _secao('Recursos'),
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'PV (Automático)',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    child: Text(
                      '${_int(_resistenciaController) * 5}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _campoNumero('Créditos', _creditosController),
                ),
              ],
            ),
            _secao('Equipamentos e técnicas'),
            _campoTexto('Kit', _kitController, maxLines: 3),
            _campoTexto('Manobras', _manobrasController, maxLines: 4),
            _campoTexto('Vantagens', _vantagensController, maxLines: 4),
            _campoTexto('Desvantagens', _desvantagensController, maxLines: 4),
            _secao('Itens'),
            _listaItens(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _salvando ? null : _adicionarItem,
                    icon: const Icon(Icons.library_add_outlined),
                    label: const Text('Adicionar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _salvando ? null : _criarItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Criar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _secao('Criatura'),
            _listaCriatura(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _salvando ? null : _adicionarCriatura,
                    icon: const Icon(Icons.library_add_outlined),
                    label: const Text('Adicionar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _salvando ? null : _criarCriatura,
                    icon: const Icon(Icons.add),
                    label: const Text('Criar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _salvando
                      ? 'Salvando...'
                      : widget.novo
                          ? 'Criar $_nomePersonagens'
                          : 'Salvar alterações',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
class _FichaCriaturaDialog extends StatefulWidget {
  final CriaturaTreinador ficha;

  const _FichaCriaturaDialog({
    required this.ficha,
  });

  @override
  State<_FichaCriaturaDialog> createState() => _FichaCriaturaDialogState();
}

class _FichaCriaturaDialogState extends State<_FichaCriaturaDialog> {
  late final TextEditingController _nivel;
  late final TextEditingController _bonusForca;
  late final TextEditingController _bonusHabilidade;
  late final TextEditingController _bonusResistencia;
  late final TextEditingController _bonusArmadura;
  late final TextEditingController _bonusDefesaEspecial;
  late final TextEditingController _bonusPoderDeFogo;
  late final TextEditingController _moves;

  late List<Poder> _poderes;

  @override
  void initState() {
    super.initState();

    final ficha = widget.ficha;

    _nivel = TextEditingController(text: '${ficha.nivel}');
    _bonusForca = TextEditingController(text: '${ficha.bonusForca}');
    _bonusHabilidade = TextEditingController(text: '${ficha.bonusHabilidade}');
    _bonusResistencia =
        TextEditingController(text: '${ficha.bonusResistencia}');
    _bonusArmadura = TextEditingController(text: '${ficha.bonusArmadura}');
    _bonusDefesaEspecial =
        TextEditingController(text: '${ficha.bonusDefesaEspecial}');
    _bonusPoderDeFogo =
        TextEditingController(text: '${ficha.bonusPoderDeFogo}');
    _moves = TextEditingController(text: ficha.moves.join('\n'));

    _poderes = List<Poder>.from(ficha.poderes);
  }

  @override
  void dispose() {
    _nivel.dispose();
    _bonusForca.dispose();
    _bonusHabilidade.dispose();
    _bonusResistencia.dispose();
    _bonusArmadura.dispose();
    _bonusDefesaEspecial.dispose();
    _bonusPoderDeFogo.dispose();
    _moves.dispose();
    super.dispose();
  }

  int _int(TextEditingController controller) {
    return int.tryParse(controller.text.trim()) ?? 0;
  }

  Future<void> _adicionarPoder() async {
    final tipoController = TextEditingController();
    final valorController = TextEditingController(text: '1');
    final bonusController = TextEditingController(text: '0');

    final resultado = await showDialog<Poder>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Poder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tipoController,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: valorController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: bonusController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Bônus',
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
                final tipo = tipoController.text.trim();
                if (tipo.isEmpty) return;

                Navigator.pop(
                  context,
                  Poder(
                    tipo: tipo,
                    valorBase:
                        int.tryParse(valorController.text.trim()) ?? 0,
                    bonus: int.tryParse(bonusController.text.trim()) ?? 0,
                    original: false,
                  ),
                );
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );

    tipoController.dispose();
    valorController.dispose();
    bonusController.dispose();

    if (resultado == null || !mounted) return;

    setState(() {
      _poderes.add(resultado);
    });
  }

  void _removerPoder(int indice) {
    setState(() {
      _poderes.removeAt(indice);
    });
  }

  Widget _numero(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _grade(List<MapEntry<String, TextEditingController>> campos) {
    final linhas = <Widget>[];

    for (int i = 0; i < campos.length; i += 2) {
      final esquerda = campos[i];
      final direita = i + 1 < campos.length ? campos[i + 1] : null;

      linhas.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _numero(esquerda.key, esquerda.value)),
            const SizedBox(width: 8),
            Expanded(
              child: direita == null
                  ? const SizedBox.shrink()
                  : _numero(direita.key, direita.value),
            ),
          ],
        ),
      );
    }

    return Column(children: linhas);
  }

  void _salvar() {
    final nome = widget.ficha.nome;

    final moves = _moves.text
        .split('\n')
        .map((move) => move.trim())
        .where((move) => move.isNotEmpty)
        .toList();

    final ficha = CriaturaTreinador(
      nome: nome,
      nivel: _int(_nivel),
      bonusForca: _int(_bonusForca),
      bonusHabilidade: _int(_bonusHabilidade),
      bonusResistencia: _int(_bonusResistencia),
      bonusArmadura: _int(_bonusArmadura),
      bonusDefesaEspecial: _int(_bonusDefesaEspecial),
      bonusPoderDeFogo: _int(_bonusPoderDeFogo),
      poderes: List<Poder>.from(_poderes),
      poderesExtras: 0,
      pv: widget.ficha.pv,
      pe: widget.ficha.pe,
      moves: moves,
    );

    Navigator.pop(context, ficha);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar ${widget.ficha.nome}'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nível e ajustes',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              _numero('Nível', _nivel),
              _grade([
                MapEntry('Bônus Força', _bonusForca),
                MapEntry('Bônus Habilidade', _bonusHabilidade),
                MapEntry('Bônus Resistência', _bonusResistencia),
                MapEntry('Bônus Armadura', _bonusArmadura),
                MapEntry('Bônus Defesa Especial', _bonusDefesaEspecial),
                MapEntry('Bônus Poder de Fogo', _bonusPoderDeFogo),
              ]),
              const SizedBox(height: 4),
              const Text('Poderes', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              if (_poderes.isEmpty) const Text('Nenhum poder configurado.'),
              ...List.generate(
                _poderes.length,
                (indice) {
                  final poder = _poderes[indice];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text('${poder.tipo} (Base: ${poder.valorBase})', style: const TextStyle(fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: poder.bonus.toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Bônus', border: OutlineInputBorder(), isDense: true),
                            onChanged: (valor) {
                              final novoBonus = int.tryParse(valor) ?? 0;
                              setState(() {
                                _poderes[indice] = Poder(tipo: poder.tipo, valorBase: poder.valorBase, bonus: novoBonus, original: poder.original);
                              });
                            },
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remover',
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => _removerPoder(indice),
                        ),
                      ],
                    ),
                  );
                },
              ),
              OutlinedButton.icon(
                onPressed: _adicionarPoder,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar poder'),
              ),

              const Text(
                'Moves',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _moves,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Moves',
                  hintText: 'Um Move por linha',
                  border: OutlineInputBorder(),
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
          onPressed: _salvar,
          child: const Text('Salvar ficha'),
        ),
      ],
    );
  }
}

class _SelecionarItemDialog extends StatelessWidget {
  final List<Item> itens;

  const _SelecionarItemDialog({required this.itens});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecionar item'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: itens.length,
          itemBuilder: (context, indice) {
            final item = itens[indice];
            return ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(
                item.nome,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(item.tipo.isEmpty ? item.descricao : item.tipo),
              onTap: () => Navigator.pop(context, item),
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
    );
  }
}

class _QuantidadeItemDialog extends StatefulWidget {
  final int quantidade;

  const _QuantidadeItemDialog({required this.quantidade});

  @override
  State<_QuantidadeItemDialog> createState() => _QuantidadeItemDialogState();
}

class _QuantidadeItemDialogState extends State<_QuantidadeItemDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.quantidade}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmar() {
    final quantidade = int.tryParse(_controller.text.trim());
    if (quantidade == null || quantidade < 1) return;
    Navigator.pop(context, quantidade);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Quantidade'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Quantidade',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _confirmar,
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}

class _ItemDialog extends StatefulWidget {
  final Item item;

  const _ItemDialog({required this.item});

  @override
  State<_ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<_ItemDialog> {
  late final TextEditingController _quantidade;

  @override
  void initState() {
    super.initState();
    _quantidade = TextEditingController(text: '${widget.item.quantidade}');
  }

  @override
  void dispose() {
    _quantidade.dispose();
    super.dispose();
  }

  void _salvar() {
    final quantidade = int.tryParse(_quantidade.text.trim());
    if (quantidade == null || quantidade < 1) return;

    Navigator.pop(
      context,
      widget.item.copyWith(quantidade: quantidade),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar ${widget.item.nome}'),
      content: TextField(
        controller: _quantidade,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Quantidade',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _salvar,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class _SelecionarCriaturaDialog extends StatefulWidget {
  final List<Criatura> criaturas;

  const _SelecionarCriaturaDialog({required this.criaturas});

  @override
  State<_SelecionarCriaturaDialog> createState() =>
      _SelecionarCriaturaDialogState();
}

class _SelecionarCriaturaDialogState extends State<_SelecionarCriaturaDialog> {
  final TextEditingController _busca = TextEditingController();
  late List<Criatura> _filtrados;

  @override
  void initState() {
    super.initState();
    _filtrados = List<Criatura>.from(widget.criaturas);
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  void _filtrar(String valor) {
    final termo = valor.trim().toLowerCase();
    setState(() {
      _filtrados = widget.criaturas
          .where((c) => c.nome.toLowerCase().contains(termo))
          .toList()
        ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecionar Criatura'),
      content: SizedBox(
        width: 520,
        height: 460,
        child: Column(
          children: [
            TextField(
              controller: _busca,
              onChanged: _filtrar,
              decoration: const InputDecoration(
                labelText: 'Buscar criatura',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: _filtrados.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final c = _filtrados[index];
                  return ListTile(
                    leading: const Icon(Icons.pets),
                    title: Text(c.nome.isEmpty ? 'Sem nome' : c.nome),
                    subtitle: Text(c.tipos.isNotEmpty
                        ? c.tipos.join(', ')
                        : 'Sem tipo'),
                    onTap: () => Navigator.pop(context, c),
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

















