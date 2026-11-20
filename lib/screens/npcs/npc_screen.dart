import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/npc.dart';
import '../../models/criatura.dart';
import '../../repositories/npcs_repository.dart';
import '../../repositories/criaturas_repository.dart';
import '../bestiario/criatura_detalhe_screen.dart';
import '../itens/item_detalhe_screen.dart';
import 'npc_edit_screen.dart';
import 'npc_localizacao.dart';

class NPCScreen extends StatefulWidget {
  final String npcId;

  const NPCScreen({
    super.key,
    required this.npcId,
  });

  @override
  State<NPCScreen> createState() => _NPCScreenState();
}

class _NPCScreenState extends State<NPCScreen> {
  String _nomePersonagens = 'Personagens';
  final NPCsRepository _npcsRepository = NPCsRepository();

  final CriaturasRepository _criaturasRepository = CriaturasRepository();

  final Random _random = Random();

  NPC? _npc;
  List<Criatura> _criaturas = [];
  Future<List<ReferenciaLocalizacaoNPC>>? _localizacoesFuture;
  bool _carregando = true;

  static const Color _fundo = Color(0xFFF4F1E8);
  static const Color _branco = Colors.white;
  static const Color _texto = Color(0xFF252525);
  static const Color _textoSecundario = Color(0xFF66625B);

  static const Color _vermelho = Color(0xFFD64545);
  static const Color _azul = Color(0xFF3D73C9);
  static const Color _amarelo = Color(0xFFE3B341);
  static const Color _verde = Color(0xFF4D9A5F);
  static const Color _roxo = Color(0xFF7856A8);
  static const Color _ciano = Color(0xFF2796B8);
  static const Color _laranja = Color(0xFFE07A32);
  static const Color _borda = Color(0xFFD8D3C7);

  @override
  void initState() {
    super.initState();
    _carregar();
    _carregarNomesConfigurados();
  }

  Future<void> _carregarNomesConfigurados() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _nomePersonagens = prefs.getString('menu_personagens') ?? 'Personagens';
    });
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
    });

    try {
      final npcs = await _npcsRepository.carregar();

      final criaturas = await _criaturasRepository.carregar();

      NPC? npc;

      for (final item in npcs) {
        if (item.id == widget.npcId) {
          npc = item;
          break;
        }
      }

      if (!mounted) {
        return;
      }

      if (npc == null) {
        setState(() {
          _npc = null;
          _criaturas = [];
          _localizacoesFuture = null;
          _carregando = false;
        });
        return;
      }

      final porNome = <String, Criatura>{};

      for (final criatura in criaturas) {
        porNome[_chaveNome(criatura.nome)] = criatura;
      }

      final encontrados = <Criatura>[];

      for (final nome in npc.criaturas) {
        final criatura = porNome[_chaveNome(nome)];

        if (criatura != null) {
          encontrados.add(criatura);
        }
      }

      setState(() {
        _npc = npc;
        _criaturas = encontrados;
        _localizacoesFuture = buscarLocalizacoesDoNPC(npc!);
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
            'Não foi possível carregar o $_nomePersonagens: $e',
          ),
        ),
      );
    }
  }

  Future<void> _editarNPC(
    NPC npc,
  ) async {
    final resultado = await Navigator.push<bool>(
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

  Future<bool> _confirmarExclusao(
    NPC npc,
  ) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Excluir $_nomePersonagens?',
          ),
          content: Text(
            'O $_nomePersonagens "${npc.nome}" será removido apenas do armazenamento local do aplicativo.\n\nA planilha não será alterada.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                false,
              ),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(
                context,
                true,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    return resultado == true;
  }

  Future<void> _excluirNPC(
    NPC npc,
  ) async {
    final confirmar = await _confirmarExclusao(npc);

    if (!confirmar || !mounted) {
      return;
    }

    await _npcsRepository.remover(
      npc.id,
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  String _chaveNome(String nome) {
    return nome
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

  CriaturaTreinador? _fichaCriatura(
    String nome,
  ) {
    final npc = _npc;

    if (npc == null) {
      return null;
    }

    final chave = _chaveNome(nome);

    for (final ficha in npc.fichasCriatura) {
      if (_chaveNome(ficha.nome) == chave) {
        return ficha;
      }
    }

    return null;
  }

  Criatura _criaturaComFicha(
    Criatura criatura,
    CriaturaTreinador ficha,
  ) {
    return Criatura(
      id: criatura.id,
      numero: criatura.numero,
      nome: criatura.nome,
      nivel: ficha.nivel,
      lendario: criatura.lendario,
      tipos: criatura.tipos,
      superEfetivo: criatura.superEfetivo,
      poucoEfetivo: criatura.poucoEfetivo,
      imune: criatura.imune,
      efetividadeTipo: criatura.efetividadeTipo,
      forca: criatura.forca,
      habilidade: criatura.habilidade,
      resistencia: criatura.resistencia,
      armadura: criatura.armadura,
      defesaEspecial: criatura.defesaEspecial,
      poderDeFogo: criatura.poderDeFogo,
      bonusForca: ficha.bonusForca,
      bonusHabilidade: ficha.bonusHabilidade,
      bonusResistencia: ficha.bonusResistencia,
      bonusArmadura: ficha.bonusArmadura,
      bonusDefesaEspecial: ficha.bonusDefesaEspecial,
      bonusPoderDeFogo: ficha.bonusPoderDeFogo,
      forcaPlanilha: criatura.forcaPlanilha,
      habilidadePlanilha: criatura.habilidadePlanilha,
      resistenciaPlanilha: criatura.resistenciaPlanilha,
      armaduraPlanilha: criatura.armaduraPlanilha,
      defesaEspecialPlanilha: criatura.defesaEspecialPlanilha,
      poderDeFogoPlanilha: criatura.poderDeFogoPlanilha,
      valoresPlanilhaFixos: false,
      moves: List<String>.from(
        ficha.moves,
      ),
      pontosMoveProgressao: criatura.pontosMoveProgressao,
      poderes: List.from(ficha.poderes),
      poderesExtras: ficha.poderesExtras,
      pv: ficha.pv,
      pe: ficha.pe,
      localizacao: criatura.localizacao,
      itemEquipado: ficha.itemEquipado,
    );
  }

  (int, int) _faixaNivel() {
    final texto = _npc?.nivelCriatura ?? '';

    final partes = RegExp(r'\d+')
        .allMatches(texto)
        .map(
          (match) => int.parse(
            match.group(0)!,
          ),
        )
        .toList();

    if (partes.isEmpty) {
      return (1, 1);
    }

    if (partes.length == 1) {
      return (
        partes.first,
        partes.first,
      );
    }

    final minimo = partes.first;
    final maximo = partes[1];

    if (minimo <= maximo) {
      return (
        minimo,
        maximo,
      );
    }

    return (
      maximo,
      minimo,
    );
  }

  int _sortearNivelCriatura() {
    final faixa = _faixaNivel();

    final minimo = faixa.$1;
    final maximo = faixa.$2;

    if (minimo <= 0 || maximo <= 0) {
      return 1;
    }

    return minimo +
        _random.nextInt(
          maximo - minimo + 1,
        );
  }

  Widget _tituloSecao(
    String titulo,
    Color cor,
    IconData icone,
  ) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: cor.withValues(
              alpha: 0.12,
            ),
            borderRadius: BorderRadius.circular(
              9,
            ),
          ),
          child: Icon(
            icone,
            color: cor,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          titulo,
          style: const TextStyle(
            color: _texto,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _cabecalhoSecao(
    String titulo,
    Color cor,
    IconData icone,
    Widget conteudo,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _branco,
        borderRadius: BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color: _borda,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloSecao(
            titulo,
            cor,
            icone,
          ),
          const SizedBox(height: 12),
          conteudo,
        ],
      ),
    );
  }

  Widget _linhaAtributo(
    String titulo,
    int valor,
    Color cor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: _fundo,
        borderRadius: BorderRadius.circular(
          9,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 27,
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(
                3,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _texto,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            valor.toString(),
            style: const TextStyle(
              color: _texto,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradeAtributos(
    List<Widget> itens,
  ) {
    final linhas = <Widget>[];

    final quantidadeColunaEsquerda = (itens.length + 1) ~/ 2;

    for (int i = 0; i < quantidadeColunaEsquerda; i++) {
      final primeiro = itens[i];

      final indiceDireita = i + quantidadeColunaEsquerda;

      final segundo = indiceDireita < itens.length
          ? itens[indiceDireita]
          : const SizedBox.shrink();

      linhas.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: primeiro,
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: segundo,
            ),
          ],
        ),
      );

      if (i + 1 < quantidadeColunaEsquerda) {
        linhas.add(
          const SizedBox(
            height: 8,
          ),
        );
      }
    }

    return Column(
      children: linhas,
    );
  }

  Widget _textoSecao(
    String titulo,
    String texto,
    Color cor,
    IconData icone,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _branco,
        borderRadius: BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color: _borda,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: cor.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                ),
                child: Icon(
                  icone,
                  color: cor,
                  size: 17,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    color: cor,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            texto,
            style: const TextStyle(
              color: _texto,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _linhaSecoesTexto(
    Widget esquerda,
    Widget direita,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: esquerda,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: direita,
        ),
      ],
    );
  }

  Widget _cabecalhoNPC(
    NPC npc,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _vermelho,
        borderRadius: BorderRadius.circular(
          16,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.08,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.18,
              ),
              borderRadius: BorderRadius.circular(
                14,
              ),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.35,
                ),
              ),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  npc.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (npc.tipo.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: 0.18,
                      ),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Text(
                      npc.tipo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
                if (npc.descricao.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    npc.descricao,
                    style: TextStyle(
                      color: Colors.white.withValues(
                        alpha: 0.92,
                      ),
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirCriatura(
    Criatura criatura,
  ) async {
    final ficha = _fichaCriatura(criatura.nome);

    late final Criatura criaturaExibido;

    if (ficha != null) {
      criaturaExibido = _criaturaComFicha(
        criatura,
        ficha,
      );
    } else {
      final nivel = _sortearNivelCriatura();

      criaturaExibido = criatura.comNivel(nivel);
    }

    if (!mounted) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CriaturaDetalheScreen(
          criatura: criaturaExibido,
          nivelAlteravel: true,
          origem: OrigemCriatura.treinador,
        ),
      ),
    );
  }

  Widget _buildCriaturaResumo(
    Criatura criatura,
  ) {
    final ficha = _fichaCriatura(criatura.nome);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 8,
      ),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _abrirCriatura(criatura),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 11,
          ),
          child: Row(
            children: [
              if (criatura.numero != null)
                SizedBox(
                  width: 48,
                  child: Text(
                    '#${criatura.numero.toString().padLeft(3, '0')}',
                    style: const TextStyle(
                      color: _textoSecundario,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            criatura.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _texto,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (ficha != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _verde.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                            child: Text(
                              'Nv. ${ficha.nivel}',
                              style: const TextStyle(
                                color: _verde,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    if (criatura.tipos.isNotEmpty)
                      Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: criatura.tipos
                            .map(
                              (tipo) => _buildTipoChip(
                                tipo,
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: _textoSecundario,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipoChip(
    String tipo,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: _fundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tipo,
        style: const TextStyle(
          color: _texto,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _secaoItensNPC(NPC npc) {
    if (npc.itens.isEmpty) {
      return const SizedBox.shrink();
    }

    return _cabecalhoSecao(
      'Itens',
      _amarelo,
      Icons.inventory_2_outlined,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: npc.itens
            .map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                child: ListTile(
                  leading: const Icon(
                    Icons.inventory_2_outlined,
                    color: _amarelo,
                  ),
                  title: Text(
                    '${item.nome} \u00d7 ${item.quantidade}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: _texto,
                    ),
                  ),
                  subtitle: Text(
                    item.tipo.isEmpty ? item.descricao : item.tipo,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: _textoSecundario,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemDetalheScreen(item: item),
                      ),
                    );
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _secaoLocalizacaoNPC() {
    final future = _localizacoesFuture;
    if (future == null) return const SizedBox.shrink();

    return FutureBuilder<List<ReferenciaLocalizacaoNPC>>(
      future: future,
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
        if (referencias.isEmpty) return const SizedBox.shrink();

        const ordemTipos = ['Local', 'Evento', 'Ponto de Interesse'];
        return _cabecalhoSecao(
          'LOCALIZAÇÃO',
          _azul,
          Icons.location_on_outlined,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final tipo in ordemTipos)
                if (referencias.any((r) => r.tipo == tipo))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '$tipo: ',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        for (var i = 0, indice = 0; i < referencias.length; i++)
                          if (referencias[i].tipo == tipo) ...[
                            if (indice++ > 0) const Text(', '),
                            InkWell(
                              onTap: () {
                                final tela = widgetReferenciaNPC(
                                    context, referencias[i]);
                                if (tela != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => tela),
                                  );
                                }
                              },
                              child: Text(
                                referencias[i].localNome != null
                                    ? '${referencias[i].nome} (${referencias[i].localNome})'
                                    : referencias[i].nome,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
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
        );
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (_carregando) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_nomePersonagens),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final npc = _npc;

    if (npc == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_nomePersonagens),
        ),
        body: Center(
          child: Text(
            '$_nomePersonagens não encontrado.',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _fundo,
      appBar: AppBar(
        title: Text(npc.nome),
        actions: [
          IconButton(
            tooltip: 'Editar $_nomePersonagens',
            icon: const Icon(
              Icons.edit_outlined,
            ),
            onPressed: () => _editarNPC(npc),
          ),
          IconButton(
            tooltip: 'Excluir $_nomePersonagens',
            icon: const Icon(
              Icons.delete_outline,
            ),
            onPressed: () => _excluirNPC(npc),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          14,
          14,
          14,
          24,
        ),
        children: [
          _cabecalhoNPC(npc),
          _cabecalhoSecao(
            'Características',
            _azul,
            Icons.bar_chart,
            _gradeAtributos(
              [
                _linhaAtributo(
                  'Força',
                  npc.forca,
                  _vermelho,
                ),
                _linhaAtributo(
                  'Habilidade',
                  npc.habilidade,
                  _azul,
                ),
                _linhaAtributo(
                  'Inteligência',
                  npc.inteligencia,
                  _roxo,
                ),
                _linhaAtributo(
                  'Resistência',
                  npc.resistencia,
                  _verde,
                ),
                _linhaAtributo(
                  'Armadura',
                  npc.armadura,
                  _laranja,
                ),
                _linhaAtributo(
                  'Poder de Fogo',
                  npc.poderDeFogo,
                  _amarelo,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _cabecalhoSecao(
            'Conhecimentos',
            _roxo,
            Icons.menu_book,
            _gradeAtributos(
              [
                _linhaAtributo(
                  'Captura',
                  npc.captura,
                  _vermelho,
                ),
                _linhaAtributo(
                  'Controle',
                  npc.controle,
                  _azul,
                ),
                _linhaAtributo(
                  'Compreensão',
                  npc.compreensao,
                  _roxo,
                ),
                _linhaAtributo(
                  'Tratamento',
                  npc.tratamento,
                  _verde,
                ),
                _linhaAtributo(
                  'Ecologia',
                  npc.ecologia,
                  _ciano,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _cabecalhoSecao(
            'Recursos',
            _azul,
            Icons.folder_open,
            Row(
              children: [
                Expanded(
                  child: _linhaAtributo(
                    'PV',
                    npc.pv,
                    _vermelho,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _linhaAtributo(
                    'Créditos',
                    npc.creditos,
                    _amarelo,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (npc.kit.isNotEmpty && npc.vantagens.isNotEmpty)
            _linhaSecoesTexto(
              _textoSecao(
                'Kit',
                npc.kit,
                _laranja,
                Icons.backpack,
              ),
              _textoSecao(
                'Vantagens',
                npc.vantagens,
                _verde,
                Icons.add_circle_outline,
              ),
            )
          else if (npc.kit.isNotEmpty)
            _textoSecao(
              'Kit',
              npc.kit,
              _laranja,
              Icons.backpack,
            )
          else if (npc.vantagens.isNotEmpty)
            _textoSecao(
              'Vantagens',
              npc.vantagens,
              _verde,
              Icons.add_circle_outline,
            ),
          if (npc.desvantagens.isNotEmpty)
            _textoSecao(
              'Desvantagens',
              npc.desvantagens,
              _vermelho,
              Icons.remove_circle_outline,
            ),
          if (npc.manobras.isNotEmpty)
            _textoSecao(
              'Manobras',
              npc.manobras,
              _azul,
              Icons.sports_martial_arts,
            ),
          if (npc.criaturas.isNotEmpty) ...[
            const SizedBox(height: 4),
            _cabecalhoSecao(
              'Criatura',
              _vermelho,
              Icons.pets,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_criaturas.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        12,
                      ),
                      decoration: BoxDecoration(
                        color: _fundo,
                        borderRadius: BorderRadius.circular(
                          9,
                        ),
                      ),
                      child: Text(
                        'O $_nomePersonagens "${npc.nome}" será removido apenas do armazenamento local do aplicativo.\n\nA planilha não será alterada.',
                        style: TextStyle(
                          color: _textoSecundario,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    )
                  else
                    ..._criaturas.map(
                      (criatura) => _buildCriaturaResumo(
                        criatura,
                      ),
                    ),
                ],
              ),
            ),
          ],
          _secaoItensNPC(npc),
          _secaoLocalizacaoNPC(),
        ],
      ),
    );
  }
}
