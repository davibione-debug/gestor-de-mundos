import 'package:flutter/material.dart';
import 'dart:math';

import '../../models/ponto_interesse.dart';
import '../../repositories/locais_repository.dart';
import '../../models/local.dart';
import '../../models/npc.dart';
import '../../models/criatura.dart';
import '../../models/periodo_dia.dart';
import '../../geradores/progressao.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bestiario/criatura_detalhe_screen.dart';
import '../npcs/npc_screen.dart';
import '../../models/encontro.dart';
import '../../models/grupo.dart';

class PontoInteresseScreen extends StatefulWidget {
  final Local? local;
  final String localId;
  final PontoInteresse ponto;

  const PontoInteresseScreen({
    super.key,
    required this.localId,
    required this.ponto,
    this.local,
  });

  @override
  State<PontoInteresseScreen> createState() => _PontoInteresseScreenState();
}

class _PontoInteresseScreenState extends State<PontoInteresseScreen> {
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

  final Random _random = Random();
  String _nomeCriatura = 'Criatura';
  String _menuAliados = 'Aliados';
  String _menuInimigos = 'Inimigos';
  late PontoInteresse _pontoAtual;
  @override
  void initState() {
    super.initState();

    _pontoAtual = widget.ponto;

    _carregarNomesConfigurados();
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


  Future<bool> _confirmarExclusao({
    required String titulo,
    required String mensagem,
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
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
        );
      },
    );

    return resultado == true;
  }

  Future<void> _excluirPonto() async {
    final confirmar = await _confirmarExclusao(
      titulo: 'Excluir ponto de interesse?',
      mensagem:
          'O ponto "${_pontoAtual.nome}" será removido deste Local.\n\nA planilha não será alterada.',
    );

    if (!confirmar || !mounted) {
      return;
    }

    await _repository.removerPontoInteresse(
      widget.localId,
      _pontoAtual.id,
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  Future<void> _excluirEvento(
    String eventoId,
    String eventoNome,
  ) async {
    final confirmar = await _confirmarExclusao(
      titulo: 'Excluir evento?',
      mensagem:
          'O evento "$eventoNome" será removido deste ponto de interesse.\n\nA planilha não será alterada.',
    );

    if (!confirmar || !mounted) {
      return;
    }

    await _repository.removerEventoDoPonto(
      widget.localId,
      _pontoAtual.id,
      eventoId,
    );

    final locais = await _repository.carregar();

    PontoInteresse? atualizado;

    for (final local in locais) {
      if (local.id != widget.localId) {
        continue;
      }

      for (final ponto in local.pontosInteresse) {
        if (ponto.id == _pontoAtual.id) {
          atualizado = ponto;
          break;
        }
      }

      break;
    }

    if (!mounted) {
      return;
    }

    if (atualizado == null) {
      Navigator.pop(context, true);
      return;
    }

    setState(() {
      _pontoAtual = atualizado!;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Evento excluído.'),
      ),
    );
  }

  bool get _temEncontros {
    final c = _pontoAtual.encontrosCriaturas;
    final a = _pontoAtual.encontrosAliados;
    final i = _pontoAtual.encontrosInimigos;
    return c.diurno.isNotEmpty || c.noturno.isNotEmpty ||
        c.pesca.isNotEmpty || c.surfe.isNotEmpty ||
        a.diurno.isNotEmpty || a.noturno.isNotEmpty ||
        a.pesca.isNotEmpty || a.surfe.isNotEmpty ||
        i.diurno.isNotEmpty || i.noturno.isNotEmpty ||
        i.pesca.isNotEmpty || i.surfe.isNotEmpty;
  }

  PeriodoDia _periodoDoTexto(String texto) {
    for (final p in PeriodoDia.values) {
      if (p.texto == texto) return p;
    }
    return PeriodoDia.qualquer;
  }

  bool _disponivelNoPeriodo(PeriodoDia? periodo, PeriodoDia escolhido) {
    if (periodo == null || periodo == PeriodoDia.qualquer) return true;
    if (escolhido == PeriodoDia.qualquer) return true;
    return periodo == escolhido;
  }

  List<PeriodoDia> get _periodosDisponiveis => PeriodoDia.values;

  Future<void> _abrirGerador() async {
    String periodoTexto = 'Qualquer';
    String tipoEncontro = 'Criatura';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Gerar Encontro'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: periodoTexto,
                      decoration: const InputDecoration(
                        labelText: 'Período',
                        border: OutlineInputBorder(),
                      ),
                      items: _periodosDisponiveis
                          .map((p) => DropdownMenuItem<String>(
                                value: p.texto,
                                child: Text(p.texto),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setDialogState(() => periodoTexto = v);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: tipoEncontro,
                      decoration: const InputDecoration(
                        labelText: 'Encontro',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'Criatura',
                          child: Text(_nomeCriatura),
                        ),
                        DropdownMenuItem(
                          value: 'Aliado',
                          child: Text(_menuAliados),
                        ),
                        DropdownMenuItem(
                          value: 'Inimigo',
                          child: Text(_menuInimigos),
                        ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setDialogState(() => tipoEncontro = v);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _gerarEncontro(periodoTexto, tipoEncontro);
                  },
                  icon: const Icon(Icons.casino),
                  label: const Text('Gerar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _gerarEncontro(String periodoTexto, String tipo) {
    final periodo = _periodoDoTexto(periodoTexto);

    if (tipo == 'Criatura') {
      final lista = [
        ..._pontoAtual.encontrosCriaturas.diurno,
        ..._pontoAtual.encontrosCriaturas.noturno,
        ..._pontoAtual.encontrosCriaturas.pesca,
        ..._pontoAtual.encontrosCriaturas.surfe,
      ].where((e) => _disponivelNoPeriodo(e.periodo, periodo)).toList();

      if (lista.isEmpty) {
        _aviso('Nenhuma criatura disponível para este período.');
        return;
      }

      final raros = lista.where((e) => e.raro).toList();
      final comuns = lista.where((e) => !e.raro).toList();
      final dado = _random.nextInt(6) + 1;

      dynamic escolhido;
      if (dado == 6 && raros.isNotEmpty) {
        escolhido = raros[_random.nextInt(raros.length)];
      } else if (comuns.isNotEmpty) {
        escolhido = comuns[_random.nextInt(comuns.length)];
      } else {
        escolhido = raros[_random.nextInt(raros.length)];
      }

      final min = _pontoAtual.nivelMinCriatura;
      final max = _pontoAtual.nivelMaxCriatura;

      if (escolhido.nivelFixo == null && (min <= 0 || max <= 0)) {
        _aviso('Configure os níveis mínimo e máximo deste ponto.');
        return;
      }

      final nivel = escolhido.nivelFixo ?? (min + _random.nextInt(max - min + 1));

      final criatura = Progressao.aplicarProgressaoNivel(
        escolhido.criatura.comNivel(nivel),
      );

      _mostrarCriatura(criatura);
      return;
    }

    final rocket = tipo == 'Inimigo';
    final grupo = rocket
        ? _pontoAtual.encontrosInimigos
        : _pontoAtual.encontrosAliados;
    final lista = [
      ...grupo.diurno,
      ...grupo.noturno,
      ...grupo.pesca,
      ...grupo.surfe,
    ].where((e) => _disponivelNoPeriodo(e.periodo, periodo)).toList();

    if (lista.isEmpty) {
      _aviso(
        rocket
            ? 'Nenhum $_menuInimigos disponível para este período.'
            : 'Nenhum $_menuAliados disponível para este período.',
      );
      return;
    }

    final escolhido = lista[_random.nextInt(lista.length)];
    final NPC npc = escolhido.npc;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NPCScreen(npcId: npc.id)),
    );
  }

  void _mostrarCriatura(Criatura criatura) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _card,
          surfaceTintColor: Colors.transparent,
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Uma ${_nomeCriatura.toLowerCase()} selvagem aparece!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    color: _texto,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  criatura.nome,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 27,
                    color: _azul,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Nível ${criatura.nivel}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: _textoSecundario,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () async {
                      if (!mounted) return;
                      Navigator.pop(dialogContext);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CriaturaDetalheScreen(
                            criatura: criatura,
                            nivelAlteravel: false,
                            origem: OrigemCriatura.selvagem,
                            iniciarBatalha: false,
                          ),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _azul,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    icon: const Icon(Icons.pets),
                    label: const Text(
                      'Gerar ficha',
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
      },
    );
  }
  void _aviso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
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

  Widget _linhaInformacao(
    String titulo,
    String valor,
    IconData icone,
  ) {
    if (valor.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icone,
            size: 22,
            color: _azul,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _textoSecundario,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 16,
                    color: _texto,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaracteristicas() {
    final temLocalizacao = _pontoAtual.localizacao.trim().isNotEmpty;
    final temDescricao = _pontoAtual.descricao.trim().isNotEmpty;
    final temNiveis = _pontoAtual.nivelMinCriatura > 0 ||
        _pontoAtual.nivelMaxCriatura > 0;

    if (!temDescricao && !temLocalizacao && !temNiveis && _pontoAtual.efeitos.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return _secao(
      'Informações',
      Icons.info_outline,
      _azul,
      [
        if (temDescricao)
          _linhaInformacao(
            'Descrição',
            _pontoAtual.descricao,
            Icons.notes_outlined,
          ),
        if (temLocalizacao)
          _linhaInformacao(
            'Localização',
            _pontoAtual.localizacao,
            Icons.location_on_outlined,
          ),
        if (_pontoAtual.efeitos.trim().isNotEmpty)
          _linhaInformacao(
            'Efeitos',
            _pontoAtual.efeitos,
            Icons.auto_awesome_outlined,
          ),
        if (temNiveis)
          _linhaInformacao(
            'Nível de Encontro',
            '${_pontoAtual.nivelMinCriatura} – ${_pontoAtual.nivelMaxCriatura}',
            Icons.pets,
          ),
      ],
    );
  }
  Widget _buildEncontros() {
    final listaCriaturas = [
      ..._pontoAtual.encontrosCriaturas.diurno,
      ..._pontoAtual.encontrosCriaturas.noturno,
      ..._pontoAtual.encontrosCriaturas.pesca,
      ..._pontoAtual.encontrosCriaturas.surfe,
    ];
    final listaAliados = [
      ..._pontoAtual.encontrosAliados.diurno,
      ..._pontoAtual.encontrosAliados.noturno,
      ..._pontoAtual.encontrosAliados.pesca,
      ..._pontoAtual.encontrosAliados.surfe,
    ];
    final listaInimigos = [
      ..._pontoAtual.encontrosInimigos.diurno,
      ..._pontoAtual.encontrosInimigos.noturno,
      ..._pontoAtual.encontrosInimigos.pesca,
      ..._pontoAtual.encontrosInimigos.surfe,
    ];

    final temDado = _pontoAtual.dadoEncontros.trim().isNotEmpty;
    if (!temDado &&
        listaCriaturas.isEmpty &&
        listaAliados.isEmpty &&
        listaInimigos.isEmpty) {
      return const SizedBox.shrink();
    }

    return _secao(
      'Encontros',
      Icons.pets,
      _vermelho,
      [
        if (temDado)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7F3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borda),
            ),
            child: Row(
              children: [
                const Icon(Icons.casino_outlined, color: _amarelo),
                const SizedBox(width: 8),
                Expanded(child: Text(_pontoAtual.dadoEncontros)),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _mostrarEncontrosDialog(listaCriaturas, tipo: 'criatura'),
                child: Text(_nomeCriatura),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _mostrarEncontrosDialog(listaAliados, tipo: 'aliado'),
                child: Text(_menuAliados),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _mostrarEncontrosDialog(listaInimigos, tipo: 'inimigo'),
                child: Text(_menuInimigos),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _persistirCriaturaAtualizada(Criatura nova) async {
    try {
      final repo = LocaisRepository();
      final locais = await repo.carregar();

      for (final local in locais) {
        for (final ponto in local.pontosInteresse) {
          if (ponto.id != _pontoAtual.id) continue;

          final grupos = [
            ponto.encontrosCriaturas.diurno,
            ponto.encontrosCriaturas.noturno,
            ponto.encontrosCriaturas.pesca,
            ponto.encontrosCriaturas.surfe,
          ];

          Encontro? encontrado;
          for (final g in grupos) {
            for (final e in g) {
              if (e.criatura.id == nova.id) {
                encontrado = e;
                break;
              }
            }
            if (encontrado != null) break;
          }

          if (encontrado == null) continue;

          final novoEncontro = Encontro(
            criatura: nova,
            condicao: encontrado.condicao,
            raro: encontrado.raro,
            periodo: encontrado.periodo,
            leguaMin: encontrado.leguaMin,
            leguaMax: encontrado.leguaMax,
            nivelFixo: encontrado.nivelFixo,
            fichaFixada: encontrado.fichaFixada,
          );

          List<Encontro> substitui(List<Encontro> lista) => lista
              .map((e) => e.criatura.id == nova.id ? novoEncontro : e)
              .toList();

          final grupoAtualizado = Grupo(
            id: ponto.encontrosCriaturas.id,
            nome: ponto.encontrosCriaturas.nome,
            diurno: substitui(ponto.encontrosCriaturas.diurno),
            noturno: substitui(ponto.encontrosCriaturas.noturno),
            pesca: substitui(ponto.encontrosCriaturas.pesca),
            surfe: substitui(ponto.encontrosCriaturas.surfe),
          );

          final pontoAtualizado = ponto.copyWith(
            encontrosCriaturas: grupoAtualizado,
          );

          await repo.salvarPontoInteresse(local.id, pontoAtualizado);

          if (!mounted) return;
          setState(() {
            _pontoAtual = pontoAtualizado;
          });
          return;
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao salvar nível: $e')),
      );
    }
  }


  void _mostrarEncontrosDialog(List<dynamic> lista, {required String tipo}) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          tipo == 'criatura'
              ? _nomeCriatura
              : (tipo == 'aliado' ? _menuAliados : _menuInimigos),
        ),
        content: SizedBox(
          width: 420,
          child: lista.isEmpty
              ? const Text('Nenhum encontro cadastrado.')
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: lista.map((e) {
                    final nome = tipo == 'criatura'
                        ? e.criatura.nome as String
                        : e.npc.nome as String;
                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async {
                        Navigator.pop(ctx);
                        if (tipo == 'criatura') {
                          final alterada = await Navigator.push<Criatura>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CriaturaDetalheScreen(
                                criatura: e.criatura,
                                nivelAlteravel: true,
                                origem: OrigemCriatura.selvagem,
                                iniciarBatalha: false,
                              ),
                            ),
                          );
                          if (alterada != null && mounted) {
                            await _persistirCriaturaAtualizada(alterada);
                          }
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NPCScreen(npcId: e.npc.id),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _borda),
                        ),
                        child: Text(
                          nome,
                          style: const TextStyle(
                            color: _azul,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventos() {
    final temDado = _pontoAtual.dadoEventos.trim().isNotEmpty;
    if (!temDado && _pontoAtual.eventos.isEmpty) {
      return const SizedBox.shrink();
    }

    return _secao(
      'Eventos',
      Icons.warning_amber_rounded,
      _laranja,
      [
        if (temDado)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7F3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borda),
            ),
            child: Row(
              children: [
                const Icon(Icons.casino_outlined, color: _laranja),
                const SizedBox(width: 8),
                Expanded(child: Text(_pontoAtual.dadoEventos)),
              ],
            ),
          ),        ..._pontoAtual.eventos.map(
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
              subtitle: evento.descricao.isEmpty
                  ? null
                  : Text(
                      evento.descricao,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
              trailing: IconButton(
                tooltip: 'Excluir evento',
                icon: const Icon(
                  Icons.delete_outline,
                  color: _vermelho,
                ),
                onPressed: () => _excluirEvento(
                  evento.id,
                  evento.nome,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNPCs() {
    if (_pontoAtual.npcs.isEmpty) {
      return const SizedBox.shrink();
    }

    return _secao(
      'NPCs',
      Icons.people_outline,
      _verde,
      [
        ..._pontoAtual.npcs.map(
          (npc) => Card(
            elevation: 0,
            color: const Color(0xFFF8F7F3),
            child: ListTile(
              leading: Icon(
                npc.tipo.toLowerCase() == 'rocket'
                    ? Icons.groups_2_outlined
                    : Icons.person_outline,
                color: npc.tipo.toLowerCase() == 'rocket' ? _vermelho : _verde,
              ),
              title: Text(
                npc.nome,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                [
                  if (npc.tipo.isNotEmpty) npc.tipo,
                  if (npc.descricao.isNotEmpty) npc.descricao,
                  if (npc.localizacao.isNotEmpty) npc.localizacao,
                  if (npc.nivelCriatura.isNotEmpty)
                    'Criatura: ${npc.nivelCriatura}',
                  'PV: ${npc.pv}',
                ].join(' • '),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(
                Icons.chevron_right,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NPCScreen(
                      npcId: npc.id,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItens() {
    if (_pontoAtual.itens.isEmpty) {
      return const SizedBox.shrink();
    }

    return _secao(
      'Itens',
      Icons.inventory_2_outlined,
      _amarelo,
      [
        ..._pontoAtual.itens.map(
          (item) => Card(
            elevation: 0,
            color: const Color(0xFFF8F7F3),
            child: ListTile(
              leading: const Icon(
                Icons.inventory_2_outlined,
                color: _amarelo,
              ),
              title: Text(
                item.nome,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                [
                  if (item.tipo.isNotEmpty) item.tipo,
                  if (item.descricao.isNotEmpty) item.descricao,
                  if (item.efeito.isNotEmpty) item.efeito,
                  if (item.localizacao.isNotEmpty) item.localizacao,
                  'Quantidade: ${item.quantidade}',
                  'Custo: ${item.custoEmCreditos}',
                ].join(' • '),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final possuiInformacoes = _pontoAtual.descricao.trim().isNotEmpty ||
        _pontoAtual.localizacao.trim().isNotEmpty ||
        _pontoAtual.npcs.isNotEmpty ||
        _pontoAtual.itens.isNotEmpty ||
        _pontoAtual.eventos.isNotEmpty;

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: _fundo,
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: _vermelho,
              secondary: _amarelo,
              surface: _card,
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _azul,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _pontoAtual.nome,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Excluir ponto de interesse',
              icon: const Icon(
                Icons.delete_outline,
              ),
              onPressed: _excluirPonto,
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
            if (_pontoAtual.nome.trim().isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(18),
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
                        color: _azul,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.place,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _pontoAtual.nome,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: _texto,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _buildCaracteristicas(),
            _buildEncontros(),
            if (_temEncontros)
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 9,
                    offset: Offset(0, 4),
                    color: Color(0x28000000),
                  ),
                ],
              ),
              child: FilledButton.icon(
                onPressed: _abrirGerador,
                style: FilledButton.styleFrom(
                  backgroundColor: _vermelho,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(Icons.casino),
                label: const Text(
                  'GERAR ENCONTRO',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            _buildNPCs(),
            _buildItens(),
            _buildEventos(),
            if (!possuiInformacoes)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _borda),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 42,
                      color: _textoSecundario,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Este ponto de interesse ainda não possui informações cadastradas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: _textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
