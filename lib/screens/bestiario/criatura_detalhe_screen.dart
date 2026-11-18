import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../geradores/progressao.dart';
import '../../gerenciadores/batalhas.dart';
import '../../models/criatura.dart';
import '../../models/item.dart';
import '../../widgets/criatura_card.dart';
import '../../repositories/criaturas_repository.dart';
import '../../repositories/locais_repository.dart';
import '../../repositories/cadastros_repository.dart';
import '../../repositories/npcs_repository.dart';
import '../../models/local.dart';
import '../../models/npc.dart';
import '../../models/evento.dart';
import '../../models/ponto_interesse.dart';
import '../mapa/local_screen.dart';
import '../mapa/evento_screen.dart';
import '../mapa/ponto_interesse_screen.dart';
import '../npcs/npc_screen.dart';

class _ReferenciaLocalizacao {
  final String tipo;
  final String nome;
  final Object registro;
  final String? localId;
  final String? localNome;

  const _ReferenciaLocalizacao({
    required this.tipo,
    required this.nome,
    required this.registro,
    this.localId,
    this.localNome,
  });

  String get chave {
    try {
      final dynamic item = registro;
      final id = item.id?.toString() ?? '';
      if (id.isNotEmpty) return '$tipo:$id';
    } catch (_) {}

    return '$tipo:$nome';
  }
}

enum OrigemCriatura {
  bestiario,
  treinador,
  selvagem,
}

class CriaturaDetalheScreen extends ConsumerStatefulWidget {
  final Criatura criatura;
  final bool nivelAlteravel;
  final Future<void> Function()? onDelete;
  final int? batalhaId;
  final OrigemCriatura origem;
  final bool iniciarBatalha;

  const CriaturaDetalheScreen({
    super.key,
    required this.criatura,
    this.nivelAlteravel = false,
    this.onDelete,
    this.batalhaId,
    this.origem = OrigemCriatura.bestiario,
    this.iniciarBatalha = false,
  });

  @override
  ConsumerState<CriaturaDetalheScreen> createState() =>
      _CriaturaDetalheScreenState();
}

class _CriaturaDetalheScreenState extends ConsumerState<CriaturaDetalheScreen> {
  late Criatura _criatura;

  late final Future<List<_ReferenciaLocalizacao>> _localizacoesFuture =
      _buscarLocalizacoes();

  int? _batalhaId;

  Color get _corOrigem {
    switch (widget.origem) {
      case OrigemCriatura.bestiario:
        return Colors.red.shade700;
      case OrigemCriatura.treinador:
        return Colors.amber.shade700;
      case OrigemCriatura.selvagem:
        return Colors.blue.shade700;
    }
  }

  Color get _corOrigemFundo {
    switch (widget.origem) {
      case OrigemCriatura.bestiario:
        return Colors.red.shade50;
      case OrigemCriatura.treinador:
        return Colors.amber.shade50;
      case OrigemCriatura.selvagem:
        return Colors.blue.shade50;
    }
  }

  Item? _itemComumSorteado;
  Item? _itemRaroSorteado;

  @override
  void initState() {
    super.initState();

    _criatura = widget.criatura;
    _sortearItensPadrao();
    _sortearItensPadrao();
    _batalhaId = widget.batalhaId;

    if (widget.iniciarBatalha && _batalhaId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _abrirBatalha();
        }
      });
    }
  }

  void _abrirBatalha() {
    if (_batalhaId != null) {
      return;
    }

    final criaturaComStats = _criatura.comStatsCalculados();
    final id = ref.read(batalhasProvider.notifier).abrir(
          criaturaComStats,
          origem: widget.origem.name,
        );

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Já existem 6 fichas de batalha minimizadas.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _batalhaId = id;
    });
  }

  void _minimizarBatalha() {
    final id = _batalhaId;

    if (id == null) {
      return;
    }

    ref.read(batalhasProvider.notifier).minimizar(id);

    Navigator.of(context).pop();
  }

  void _fecharBatalha() {
    final id = _batalhaId;

    if (id == null) {
      return;
    }

    ref.read(batalhasProvider.notifier).fechar(id);

    if (widget.batalhaId != null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _batalhaId = null;
    });
  }

  Future<void> _adicionarStatus() async {
    final id = _batalhaId;

    if (id == null) {
      return;
    }

    final nomeController = TextEditingController();
    final duracaoController = TextEditingController(text: '1');

    final resultado = await showDialog<StatusBatalha>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  hintText: 'Ex.: Envenenado',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: duracaoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duração',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _corOrigem,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final nome = nomeController.text.trim();

                final duracao = int.tryParse(
                      duracaoController.text.trim(),
                    ) ??
                    0;

                if (nome.isEmpty || duracao <= 0) {
                  return;
                }

                Navigator.pop(
                  context,
                  StatusBatalha(
                    nome: nome,
                    duracao: duracao,
                  ),
                );
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );

    nomeController.dispose();
    duracaoController.dispose();

    if (resultado == null || !mounted) {
      return;
    }

    ref.read(batalhasProvider.notifier).adicionarStatus(id, resultado);
  }

  Future<void> _excluir() async {
    if (widget.onDelete == null) {
      return;
    }

    final id = _batalhaId;

    if (id != null) {
      ref.read(batalhasProvider.notifier).fechar(id);
    }

    await widget.onDelete!();

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  void _alterarNivel(int nivel) {
    if (_batalhaId != null) {
      return;
    }

    final base = widget.criatura.comNivel(1);
    final fichaBase = base.comNivel(nivel);

    final fichaGerada = Progressao.aplicarProgressaoNivel(
      fichaBase,
    );

    setState(() {
      _criatura = fichaGerada;
    });
    Future.microtask(_sortearItensPadrao);
  }

  Widget _botaoBatalha({
    required IconData icone,
    required VoidCallback onPressed,
    required String tooltip,
    required Color cor,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: cor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              icone,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _linhaPv(
    Batalhacriatura batalha,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'PV: ${batalha.pv}/${batalha.criatura.pv}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _botaoBatalha(
          icone: Icons.add,
          tooltip: 'Ganhar 1 PV',
          cor: Colors.blue,
          onPressed: () {
            ref.read(batalhasProvider.notifier).alterarPv(batalha.id, 1);
          },
        ),
        const SizedBox(width: 8),
        _botaoBatalha(
          icone: Icons.remove,
          tooltip: 'Perder 1 PV',
          cor: Colors.red,
          onPressed: () {
            ref.read(batalhasProvider.notifier).alterarPv(batalha.id, -1);
          },
        ),
      ],
    );
  }

  Widget _linhaPe(
    Batalhacriatura batalha,
    int indice,
  ) {
    final poder = batalha.criatura.poderes[indice];
    final maximo = batalha.peMaximo(poder);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'PE ${poder.tipo}: '
              '${batalha.pe[indice]}/$maximo',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _botaoBatalha(
            icone: Icons.add,
            tooltip: 'Ganhar 1 PE',
            cor: Colors.blue,
            onPressed: () {
              ref.read(batalhasProvider.notifier).alterarPe(
                    batalha.id,
                    indice,
                    1,
                  );
            },
          ),
          const SizedBox(width: 8),
          _botaoBatalha(
            icone: Icons.remove,
            tooltip: 'Gastar 1 PE',
            cor: Colors.red,
            onPressed: () {
              ref.read(batalhasProvider.notifier).alterarPe(
                    batalha.id,
                    indice,
                    -1,
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _linhaMove(
    Batalhacriatura batalha,
    int indice,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              key: ValueKey(
                'move-$indice-${batalha.id}',
              ),
              initialValue: batalha.moves[indice],
              onChanged: (valor) {
                ref.read(batalhasProvider.notifier).alterarMove(
                      batalha.id,
                      indice,
                      valor,
                    );
              },
              decoration: InputDecoration(
                labelText: 'Move ${indice + 1}',
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 58,
            child: TextFormField(
              key: ValueKey(
                'custo-move-$indice-${batalha.id}',
              ),
              initialValue: batalha.custosMoves[indice] == 0
                  ? ''
                  : batalha.custosMoves[indice].toString(),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              textAlign: TextAlign.center,
              onChanged: (valor) {
                ref.read(batalhasProvider.notifier).alterarCustoMove(
                      batalha.id,
                      indice,
                      valor,
                    );
              },
              decoration: const InputDecoration(
                labelText: 'Custo',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linhaStatus(
    Batalhacriatura batalha,
    int indice,
  ) {
    final status = batalha.status[indice];

    return Row(
      children: [
        Expanded(
          child: Text(
            status.nome,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Turnos',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${status.duracao}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        _botaoBatalha(
          icone: Icons.add,
          tooltip: 'Aumentar duração',
          cor: Colors.blue,
          onPressed: () {
            ref.read(batalhasProvider.notifier).alterarStatusDuracao(
                  batalha.id,
                  indice,
                  1,
                );
          },
        ),
        const SizedBox(width: 8),
        _botaoBatalha(
          icone: Icons.remove,
          tooltip: 'Reduzir duração',
          cor: Colors.red,
          onPressed: () {
            ref.read(batalhasProvider.notifier).alterarStatusDuracao(
                  batalha.id,
                  indice,
                  -1,
                );
          },
        ),
      ],
    );
  }

  Widget _painelBatalha(
    Batalhacriatura batalha,
  ) {
    final pontosDisponiveis = batalha.pontosMovesDisponiveis;

    final pontosGastos = batalha.pontosMovesGastos;

    return Card(
      margin: const EdgeInsets.only(top: 14),
      color: _corOrigemFundo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: _corOrigem,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          14,
          16,
          14,
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _linhaPv(batalha),
            if (batalha.criatura.poderes.isNotEmpty) ...[
              const Divider(height: 28),
              for (var i = 0; i < batalha.criatura.poderes.length; i++)
                _linhaPe(batalha, i),
            ],
            const Divider(height: 28),
            Text(
              'Pontos de Moves: '
              '$pontosGastos / $pontosDisponiveis',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Base ${batalha.criatura.pontosMoveIniciais} + '
              'Bônus ${batalha.criatura.pontosMoveProgressao}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < 4; i++) _linhaMove(batalha, i),
            const Divider(height: 28),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _adicionarStatus,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            if (batalha.status.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                child: Text(
                  'Nenhum status.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              )
            else
              for (var i = 0; i < batalha.status.length; i++)
                _linhaStatus(batalha, i),
            const SizedBox(height: 14),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _corOrigem,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ref.read(batalhasProvider.notifier).inicioTurno(batalha.id);
              },
              child: const Text(
                'INÍCIO DE TURNO',
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                ref.read(batalhasProvider.notifier).fimTurno(batalha.id);
              },
              child: const Text(
                'FIM DE TURNO',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _minimizarBatalha,
              icon: const Icon(
                Icons.remove,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
                side: BorderSide(
                  color: Colors.blue.shade700,
                  width: 2,
                ),
                minimumSize: const Size(
                  double.infinity,
                  48,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              label: const Text(
                'MINIMIZAR',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _fecharBatalha,
              icon: const Icon(
                Icons.close,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                elevation: 4,
                minimumSize: const Size(
                  double.infinity,
                  48,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              label: const Text(
                'FECHAR BATALHA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _referenciaEstaCriatura(dynamic referencia) {
    if (referencia == null) return false;

    final nomeAtual = _criatura.nome.trim();

    if (referencia is String) {
      return referencia.trim() == nomeAtual;
    }

    try {
      final nome = referencia.nome?.toString().trim() ?? '';
      if (nome == nomeAtual) return true;
    } catch (_) {}

    try {
      final id = referencia.id?.toString().trim() ?? '';
      if (id == nomeAtual) return true;
    } catch (_) {}

    return false;
  }

  String _nomeRegistro(dynamic registro, [String fallback = '']) {
    try {
      final nome = registro.nome?.toString().trim() ?? '';
      if (nome.isNotEmpty) return nome;
    } catch (_) {}

    return fallback;
  }

  bool _verificarPersonagem(dynamic personagem) {
    if (personagem == null) return false;

    final nomeAtual = _criatura.nome.trim().toLowerCase();

    try {
      final criaturas = personagem.criaturas;
      if (criaturas is Iterable && criaturas.any(_referenciaEstaCriatura)) {
        return true;
      }
    } catch (_) {}

    try {
      final fichas = personagem.fichasCriatura;
      if (fichas is Iterable &&
          fichas.any((f) =>
              f.nome?.toString().trim().toLowerCase() == nomeAtual)) {
        return true;
      }
    } catch (_) {}

    return false;
  }

  bool _grupoContemCriatura(dynamic grupo) {
    if (grupo == null) return false;

    try {
      for (final periodo in [
        grupo.diurno,
        grupo.noturno,
        grupo.pesca,
        grupo.surfe,
      ]) {
        if (periodo is! Iterable) continue;

        for (final encontro in periodo) {
          try {
            if (_referenciaEstaCriatura(encontro.criatura)) return true;
          } catch (_) {}
        }
      }
    } catch (_) {}

    return false;
  }

  void _adicionarReferencia(
    Map<String, _ReferenciaLocalizacao> destino,
    String tipo,
    dynamic registro, {
    String? localId,
    String? localNome,
  }) {
    final nome = _nomeRegistro(registro);
    if (nome.isEmpty) return;

    final referencia = _ReferenciaLocalizacao(
      tipo: tipo,
      nome: nome,
      registro: registro as Object,
      localId: localId,
      localNome: localNome,
    );

    destino.putIfAbsent(referencia.chave, () => referencia);
  }

  Future<List<_ReferenciaLocalizacao>> _buscarLocalizacoes() async {
    final referencias = <String, _ReferenciaLocalizacao>{};
    final locais = await LocaisRepository().carregar();
    final personagens = await NPCsRepository().carregar();

    for (final local in locais) {
      final localId = local.id;
      var localTemReferenciaDireta = _grupoContemCriatura(local.encontros);

      if (localTemReferenciaDireta) {
        _adicionarReferencia(referencias, 'Local', local);
      }

      void coletarPersonagensDoGrupo(dynamic grupo) {
        if (grupo == null) return;

        try {
          for (final periodo in [
            grupo.diurno,
            grupo.noturno,
            grupo.pesca,
            grupo.surfe,
          ]) {
            if (periodo is! Iterable) continue;

            for (final encontro in periodo) {
              try {
                final personagem = encontro.npc;
                if (_verificarPersonagem(personagem)) {
                  _adicionarReferencia(
                    referencias,
                    'Personagem',
                    personagem,
                  );
                  localTemReferenciaDireta = true;
                }
              } catch (_) {}
            }
          }
        } catch (_) {}
      }

      coletarPersonagensDoGrupo(local.treinadores);
      coletarPersonagensDoGrupo(local.rockets);

      for (final evento in local.eventos) {
        if (_referenciaEstaCriatura(evento.criatura)) {
          _adicionarReferencia(referencias, 'Evento', evento);
          localTemReferenciaDireta = true;
        }
      }

      for (final ponto in local.pontosInteresse) {
        var pontoTemReferenciaDireta = false;

        try {
          pontoTemReferenciaDireta =
              ponto.criaturas.any(_referenciaEstaCriatura);
        } catch (_) {}

        if (!pontoTemReferenciaDireta) {
          pontoTemReferenciaDireta = ponto.encontros.any(
            _grupoContemCriatura,
          );
        }

        if (!pontoTemReferenciaDireta) {
          pontoTemReferenciaDireta = _grupoContemCriatura(ponto.encontrosCriaturas);
        }
        if (pontoTemReferenciaDireta) {
          _adicionarReferencia(
            referencias,
            'Ponto de Interesse',
            ponto,
            localId: localId,
            localNome: local.nome,
          );
        }

        for (final evento in ponto.eventos) {
          if (_referenciaEstaCriatura(evento.criatura)) {
            _adicionarReferencia(referencias, 'Evento', evento);
            localTemReferenciaDireta = true;
          }
        }

        for (final personagem in ponto.npcs) {
          if (_verificarPersonagem(personagem)) {
            _adicionarReferencia(
              referencias,
              'Personagem',
              personagem,
            );
            localTemReferenciaDireta = true;
          }
        }
      }

      if (localTemReferenciaDireta) {
        _adicionarReferencia(referencias, 'Local', local);
      }
    }


    // Pontos de Interesse do cadastro-base (desvinculados de Locais)
    try {
      final pontosBase = await CadastrosRepository().carregarPontos();
      debugPrint('[DEBUG] Pontos base encontrados: ${pontosBase.length}');
      for (final ponto in pontosBase) {
        if (referencias.values.any((r) => r.tipo == 'Ponto de Interesse' && r.nome == ponto.nome)) continue;
        var temRef = false;
        try {
          temRef = ponto.criaturas.any(_referenciaEstaCriatura);
        } catch (_) {}
        if (!temRef) {
          temRef = _grupoContemCriatura(ponto.encontrosCriaturas);
        }
        debugPrint('[DEBUG] Ponto ${ponto.nome}: temRef=$temRef');
        if (temRef) {
          _adicionarReferencia(referencias, 'Ponto de Interesse', ponto);
        }
      }
    } catch (_) {}    // Eventos-base (cadastro)
    try {
      final eventosBase = await CadastrosRepository().carregarEventos();
      for (final evento in eventosBase) {
        if (_referenciaEstaCriatura(evento.criatura)) {
          _adicionarReferencia(referencias, 'Evento', evento);
        }
      }
    } catch (_) {}

    for (final personagem in personagens) {
      if (_verificarPersonagem(personagem)) {
        _adicionarReferencia(referencias, 'Personagem', personagem);
      }
    }

    const ordemTipos = [
      'Local',
      'Personagem',
      'Evento',
      'Ponto de Interesse',
    ];

    final resultado = referencias.values.toList()
      ..sort((a, b) {
        final ordemA = ordemTipos.indexOf(a.tipo);
        final ordemB = ordemTipos.indexOf(b.tipo);

        if (ordemA != ordemB) return ordemA.compareTo(ordemB);

        final porNome = a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
        if (porNome != 0) return porNome;

        return a.chave.compareTo(b.chave);
      });

    return resultado;
  }

  void _abrirReferencia(_ReferenciaLocalizacao referencia) {
    final Widget tela;

    switch (referencia.tipo) {
      case 'Local':
        tela = LocalScreen(local: referencia.registro as Local);
        break;
      case 'Personagem':
        tela = NPCScreen(
          npcId: (referencia.registro as NPC).id,
        );
        break;
      case 'Evento':
        tela = EventoScreen(
          evento: referencia.registro as Evento,
        );
        break;
      case 'Ponto de Interesse':
        final localId = referencia.localId;
        if (localId == null || localId.isEmpty) return;

        tela = PontoInteresseScreen(
          localId: localId,
          ponto: referencia.registro as PontoInteresse,
        );
        break;
      default:
        return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => tela,
      ),
    );
  }

    Future<void> _sortearItensPadrao() async {
    // Criatura de NPC NUNCA tem item sorteado. Usa o item da ficha (ou nenhum).
    if (widget.origem == OrigemCriatura.treinador) {
      _itemComumSorteado = _criatura.itemEquipado;
      _itemRaroSorteado = null;
      if (mounted) setState(() {});
      return;
    }

    _itemComumSorteado = null;
    _itemRaroSorteado = null;
    final repo = CriaturasRepository();
    final lista = await repo.carregar();
    final nome = _criatura.nome.trim().toLowerCase();
    Item? comumBase;
    Item? raroBase;
    for (final c in lista) {
      if (c.nome.trim().toLowerCase() == nome) {
        comumBase = c.itemComum;
        raroBase = c.itemRaro;
        break;
      }
    }
    if (comumBase == null && raroBase == null) return;

    // Nivel 1: mostra os dois fixos
    if (_criatura.nivel == 1) {
      _itemComumSorteado = comumBase;
      _itemRaroSorteado = raroBase;
      if (mounted) setState(() {});
      return;
    }

    // Nivel 2+: sorteia 50% + 1d6
    final temItem = Random().nextInt(2) == 0;
    if (!temItem) return;

    final d6 = Random().nextInt(6) + 1;
    if (d6 == 1) {
      _itemRaroSorteado = raroBase ?? comumBase;
    } else {
      _itemComumSorteado = comumBase ?? raroBase;
    }

    if (mounted) setState(() {});
  }

  Widget _secaoItens() {
    final comum = _itemComumSorteado;
    final raro = _itemRaroSorteado;
    if (comum == null && raro == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ITEM EQUIPADO',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (comum != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _itemCard(
                  titulo: 'Item Comum (50%)',
                  item: comum,
                  destaque: false,
                ),
              ),
            if (raro != null)
              _itemCard(
                titulo: 'Item Raro (1/6)',
                item: raro,
                destaque: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _itemCard({
    required String titulo,
    required Item item,
    required bool destaque,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: destaque
            ? Colors.amber.withValues(alpha: 0.1)
            : const Color(0xFFF8F7F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: destaque ? Colors.amber.shade700 : const Color(0xFFD8D3C7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: destaque ? Colors.amber.shade900 : Colors.grey.shade700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: destaque ? Colors.amber.shade800 : Colors.orange.shade800,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.nome,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
              if (item.tipo.trim().isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.tipo,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
            ],
          ),
          if (item.efeito.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.efeito,
              style: const TextStyle(fontSize: 13, height: 1.3),
            ),
          ],
        ],
      ),
    );
  }

  Widget _secaoLocalizacao() {
    return FutureBuilder<List<_ReferenciaLocalizacao>>(
      future: _localizacoesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Não foi possível carregar as localizações: ${snapshot.error}',
              ),
            ),
          );
        }

        final referencias = snapshot.data ?? const [];
        const ordemTipos = [
          'Local',
          'Personagem',
          'Evento',
          'Ponto de Interesse',
        ];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LOCALIZAÇÃO',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (referencias.isEmpty)
                  const Text('Nenhum registro referencia esta criatura.')
                else
                  for (final tipo in ordemTipos)
                    if (referencias.any((r) => r.tipo == tipo))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '$tipo: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            for (var i = 0, indice = 0;
                                i < referencias.length;
                                i++)
                              if (referencias[i].tipo == tipo) ...[
                                if (indice++ > 0) const Text(', '),
                                InkWell(
                                  onTap: () => _abrirReferencia(referencias[i]),
                                  child: Text(
                                    referencias[i].localNome != null
                                        ? '${referencias[i].nome} (${referencias[i].localNome})'
                                        : referencias[i].nome,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final batalhas = ref.watch(batalhasProvider);

    Batalhacriatura? batalha;

    if (_batalhaId != null) {
      for (final item in batalhas) {
        if (item.id == _batalhaId) {
          batalha = item;
          break;
        }
      }
    }

    final criaturaExibido = batalha?.criatura ?? _criatura;

    final batalhaAberta = batalha != null;

    return PopScope<Criatura>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _criatura);
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(criaturaExibido.nome),
        actions: [
          if (widget.onDelete != null)
            IconButton(
              tooltip: 'Excluir Criatura',
              icon: const Icon(
                Icons.delete_outline,
              ),
              onPressed: _excluir,
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
          CriaturaCard(
            criatura: criaturaExibido,
            batalhaAberta: batalhaAberta,
            onBatalha: _abrirBatalha,
            nivelAlteravel: widget.nivelAlteravel && !batalhaAberta,
            onNivelChanged:
                widget.nivelAlteravel && !batalhaAberta ? _alterarNivel : null,
          ),
          _secaoItens(),
          if (!batalhaAberta) _secaoLocalizacao(),
          if (batalha != null) _painelBatalha(batalha),
        ],
      ),
    ),
    );
  }
}


