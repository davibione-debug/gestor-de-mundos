import 'dart:math';

import 'package:flutter/material.dart';
import '../../models/item.dart';
import '../../repositories/itens_repository.dart';
import '../itens/item_detalhe_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../geradores/progressao.dart';
import '../../models/evento.dart';
import '../../models/local.dart';
import '../../models/npc.dart';
import '../../models/periodo_dia.dart';
import '../../models/criatura.dart';
import '../../repositories/locais_repository.dart';
import '../npcs/npc_screen.dart';
import 'evento_screen.dart';
import 'local_edit_screen.dart';
import '../bestiario/criatura_detalhe_screen.dart';
import 'ponto_interesse_screen.dart';

class LocalScreen extends StatefulWidget {
  final Local local;

  const LocalScreen({
    super.key,
    required this.local,
  });

  @override
  State<LocalScreen> createState() => _LocalScreenState();
}

class _LocalScreenState extends State<LocalScreen> {
  final Random _random = Random();
  final LocaisRepository _repository = LocaisRepository();

  Local? _localAtual;

  Local get _local => _localAtual ?? widget.local;

  static const Color _fundo = Color(0xFFF4F1E8);
  static const Color _card = Colors.white;
  static const Color _cardSuave = Color(0xFFF8F7F3);
  static const Color _borda = Color(0xFFD8D3C7);

  static const Color _vermelho = Color(0xFFD64545);
  static const Color _azul = Color(0xFF3D73C9);
  static const Color _amarelo = Color(0xFFE3B341);

  static const Color _verde = Color(0xFF4D9A5F);
  static const Color _roxo = Color(0xFF7856A8);
  static const Color _ciano = Color(0xFF2796B8);
  static const Color _laranja = Color(0xFFE07A32);

  static const Color _texto = Color(0xFF252525);
  static const Color _textoSecundario = Color(0xFF66625B);

  String _modalidade = 'Diurno';
  String _periodo = 'Qualquer';
  String _tipoEncontro = 'Criatura';
  String _nomeCriatura = 'Criatura';

  String _menuAliados = 'Aliados';
  String _menuInimigos = 'Inimigos';

  int? _leguaAtual;
  List<Local> _locaisConexaoCache = [];

  @override
  void initState() {
    super.initState();
    _localAtual = widget.local;
    _carregarNomesConfigurados();
    _carregarConexoesDestino();
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

  Future<void> _editarLocal() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => LocalEditScreen(
          local: _local,
        ),
      ),
    );

    if (resultado == true) {
      await _recarregarLocal();
    }
  }

  Future<void> _excluirLocal() async {
    final confirmar = await _confirmarExclusao(
      titulo: 'Excluir local?',
      mensagem:
          'O local "${_local.nome}" será removido apenas do armazenamento local do aplicativo.\n\nA planilha não será alterada.',
    );

    if (!confirmar || !mounted) {
      return;
    }

    await _repository.remover(_local.id);

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  Future<void> _recarregarLocal() async {
    final locais = await _repository.carregar();

    Local? atualizado;

    for (final local in locais) {
      if (local.id == _local.id) {
        atualizado = local;
        break;
      }
    }

    if (!mounted || atualizado == null) {
      return;
    }

    setState(() {
      _localAtual = atualizado;
    });
  }

  Future<void> _abrirPontoInteresse(
    dynamic ponto,
  ) async {
    final alterado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PontoInteresseScreen(
          localId: _local.id,
          local: _local,
          ponto: ponto,
        ),
      ),
    );

    if (alterado == true) {
      await _recarregarLocal();
    }
  }

  void _abrirEvento(Evento evento) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventoScreen(
          evento: evento,
        ),
      ),
    );
  }

  PeriodoDia _periodoSelecionado() {
    switch (_periodo) {
      case 'Qualquer':
        return PeriodoDia.qualquer;
      case 'Amanhecer':
        return PeriodoDia.amanhecer;
      case 'Manhã':
        return PeriodoDia.manha;
      case 'Tarde':
        return PeriodoDia.tarde;
      case 'Anoitecer':
        return PeriodoDia.anoitecer;
      case 'Noite':
        return PeriodoDia.noite;
      case 'Madrugada':
        return PeriodoDia.madrugada;
      default:
        return PeriodoDia.qualquer;
    }
  }

  bool _disponivelNoPeriodo(
    PeriodoDia? periodo,
  ) {
    if (periodo == null || periodo == PeriodoDia.qualquer) {
      return true;
    }

    if (_periodoSelecionado() == PeriodoDia.qualquer) {
      return true;
    }

    return periodo == _periodoSelecionado();
  }

  List<String> _modalidadesDisponiveis() {
    final modalidades = <String>[];

    if (_local.encontros.diurno.isNotEmpty ||
        _local.treinadores.diurno.isNotEmpty ||
        _local.rockets.diurno.isNotEmpty ||
        _local.dadoEncontroDiurno.trim().isNotEmpty) {
      modalidades.add('Diurno');
    }

    if (_local.encontros.noturno.isNotEmpty ||
        _local.treinadores.noturno.isNotEmpty ||
        _local.rockets.noturno.isNotEmpty ||
        _local.dadoEncontroNoturno.trim().isNotEmpty) {
      modalidades.add('Noturno');
    }

    if (_local.encontros.pesca.isNotEmpty ||
        _local.treinadores.pesca.isNotEmpty ||
        _local.rockets.pesca.isNotEmpty ||
        _local.dadoEncontroPesca.trim().isNotEmpty) {
      modalidades.add('Pesca');
    }

    if (_local.encontros.surfe.isNotEmpty ||
        _local.treinadores.surfe.isNotEmpty ||
        _local.rockets.surfe.isNotEmpty ||
        _local.dadoEncontroSurfe.trim().isNotEmpty) {
      modalidades.add('Aquático');
    }

    return modalidades;
  }

  List<String> _periodosDisponiveisParaModalidade() {
    switch (_modalidade) {
      case 'Diurno':
        return const [
          'Qualquer',
          'Amanhecer',
          'Manhã',
          'Tarde',
        ];

      case 'Noturno':
        return const [
          'Qualquer',
          'Anoitecer',
          'Noite',
          'Madrugada',
        ];

      case 'Pesca':
      case 'Aquático':
        return const [
          'Qualquer',
          'Amanhecer',
          'Manhã',
          'Tarde',
          'Anoitecer',
          'Noite',
          'Madrugada',
        ];

      default:
        return const ['Qualquer'];
    }
  }

  List<dynamic> _criaturaDaModalidade() {
    switch (_modalidade) {
      case 'Noturno':
        return _local.encontros.noturno;
      case 'Pesca':
        return _local.encontros.pesca;
      case 'Aquático':
        return _local.encontros.surfe;
      case 'Diurno':
      default:
        return _local.encontros.diurno;
    }
  }

  List<dynamic> _npcDaModalidade(
    bool rocket,
  ) {
    final grupo = rocket ? _local.rockets : _local.treinadores;

    switch (_modalidade) {
      case 'Noturno':
        return grupo.noturno;
      case 'Pesca':
        return grupo.pesca;
      case 'Aquático':
        return grupo.surfe;
      case 'Diurno':
      default:
        return grupo.diurno;
    }
  }

  bool _disponivelNaLegua(
    int? leguaMin,
    int? leguaMax,
  ) {
    if (_leguaAtual == null) {
      return false;
    }

    if (leguaMin != null && _leguaAtual! < leguaMin) {
      return false;
    }

    if (leguaMax != null && _leguaAtual! > leguaMax) {
      return false;
    }

    return true;
  }

  Future<void> _abrirGerador() async {
    final modalidadesDisponiveis = _modalidadesDisponiveis();

    if (modalidadesDisponiveis.isEmpty) {
      _mostrarAviso(
        'Este Local não possui encontros cadastrados.',
      );
      return;
    }

    _modalidade = modalidadesDisponiveis.first;
    _periodo = 'Qualquer';
    _tipoEncontro = 'Criatura';

    _leguaAtual = _local.leguas > 0 ? 1 : null;

    final controladorLegua = TextEditingController(
      text: _leguaAtual?.toString() ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              backgroundColor: _card,
              surfaceTintColor: Colors.transparent,
              title: const Text(
                'Gerar Encontro',
                style: TextStyle(
                  color: _texto,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _modalidade,
                      dropdownColor: _card,
                      style: const TextStyle(
                        color: _texto,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Tipo',
                        labelStyle: TextStyle(
                          color: _textoSecundario,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _borda,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _vermelho,
                            width: 2,
                          ),
                        ),
                      ),
                      items: modalidadesDisponiveis
                          .map(
                            (modalidade) => DropdownMenuItem<String>(
                              value: modalidade,
                              child: Text(modalidade),
                            ),
                          )
                          .toList(),
                      onChanged: (valor) {
                        if (valor == null) {
                          return;
                        }

                        setDialogState(() {
                          _modalidade = valor;

                          final periodos = _periodosDisponiveisParaModalidade();

                          if (!periodos.contains(_periodo)) {
                            _periodo = 'Qualquer';
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controladorLegua,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: _texto,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Légua Atual',
                        labelStyle: const TextStyle(
                          color: _textoSecundario,
                        ),
                        hintText:
                            _local.leguas > 0 ? '1 a ${_local.leguas}' : null,
                        hintStyle: const TextStyle(
                          color: _textoSecundario,
                        ),
                        suffixText:
                            _local.leguas > 0 ? '/ ${_local.leguas}' : null,
                        suffixStyle: const TextStyle(
                          color: _textoSecundario,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _borda,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _vermelho,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (valor) {
                        final numero = int.tryParse(
                          valor.trim(),
                        );

                        setDialogState(() {
                          _leguaAtual = numero;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _periodo,
                      dropdownColor: _card,
                      style: const TextStyle(
                        color: _texto,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Período',
                        labelStyle: TextStyle(
                          color: _textoSecundario,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _borda,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _vermelho,
                            width: 2,
                          ),
                        ),
                      ),
                      items: _periodosDisponiveisParaModalidade()
                          .map(
                            (periodo) => DropdownMenuItem<String>(
                              value: periodo,
                              child: Text(periodo),
                            ),
                          )
                          .toList(),
                      onChanged: (valor) {
                        if (valor == null) {
                          return;
                        }

                        setDialogState(() {
                          _periodo = valor;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _tipoEncontro,
                      dropdownColor: _card,
                      style: const TextStyle(
                        color: _texto,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Encontro',
                        labelStyle: TextStyle(
                          color: _textoSecundario,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _borda,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _vermelho,
                            width: 2,
                          ),
                        ),
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
                      onChanged: (valor) {
                        if (valor == null) {
                          return;
                        }

                        setDialogState(() {
                          _tipoEncontro = valor;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    controladorLegua.dispose();

                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: _textoSecundario,
                    ),
                  ),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _vermelho,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final legua = int.tryParse(
                      controladorLegua.text.trim(),
                    );

                    if (legua == null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Informe a Légua Atual.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (_local.leguas > 0 &&
                        (legua < 1 || legua > _local.leguas)) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            'A Légua Atual deve estar entre 1 e ${_local.leguas}.',
                          ),
                        ),
                      );
                      return;
                    }

                    _leguaAtual = legua;

                    controladorLegua.dispose();

                    Navigator.pop(
                      dialogContext,
                    );

                    _gerarEncontro();
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

  void _gerarEncontro() {
    if (_leguaAtual == null) {
      _mostrarAviso(
        'Informe a Légua Atual.',
      );
      return;
    }

    if (_tipoEncontro == 'Criatura') {
      _gerarCriatura();
      return;
    }

    _gerarNPC(
      rocket: _tipoEncontro == 'Inimigo',
    );
  }

  int _sortearNivelCriatura() {
    final minimo = _local.nivelMinCriatura;
    final maximo = _local.nivelMaxCriatura;

    if (minimo <= 0 || maximo <= 0) {
      throw Exception(
        'O Local não possui uma faixa de nível válida para os Criatura.',
      );
    }

    if (minimo > maximo) {
      throw Exception(
        'O nível mínimo do Local não pode ser maior que o máximo.',
      );
    }

    return minimo +
        _random.nextInt(
          maximo - minimo + 1,
        );
  }

  void _gerarCriatura() {
    final disponiveis = _criaturaDaModalidade().where((item) {
      if (!_disponivelNoPeriodo(
        item.periodo,
      )) {
        return false;
      }

      return _disponivelNaLegua(
        item.leguaMin,
        item.leguaMax,
      );
    }).toList();

    if (disponiveis.isEmpty) {
      _mostrarAviso(
        'Não existem Criatura disponíveis '
        'na Légua $_leguaAtual '
        'para $_modalidade '
        'no período $_periodo.',
      );
      return;
    }

    final raros = disponiveis.where((item) => item.raro).toList();

    final comuns = disponiveis.where((item) => !item.raro).toList();

    final dadoRaridade = _random.nextInt(6) + 1;

    dynamic escolhido;

    if (dadoRaridade == 6 && raros.isNotEmpty) {
      escolhido = raros[_random.nextInt(
        raros.length,
      )];
    } else if (comuns.isNotEmpty) {
      escolhido = comuns[_random.nextInt(
        comuns.length,
      )];
    } else if (raros.isNotEmpty) {
      escolhido = raros[_random.nextInt(
        raros.length,
      )];
    } else {
      _mostrarAviso(
        'Não existem Criatura válidos para este encontro.',
      );
      return;
    }

    try {
      final Criatura criaturaFinal;

      if (escolhido.nivelFixo != null) {
        final criaturaNivelado = escolhido.criatura.comNivel(
          escolhido.nivelFixo!,
          valoresPlanilhaFixos: true,
        );

        criaturaFinal = Progressao.aplicarProgressaoNivel(
          criaturaNivelado,
        );
      } else {
        final nivel = _sortearNivelCriatura();

        final criaturaNivelado = escolhido.criatura.comNivel(
          nivel,
        );

        criaturaFinal = Progressao.aplicarProgressaoNivel(
          criaturaNivelado,
        );
      }

      _mostrarCriatura(criaturaFinal);
    } catch (e) {
      _mostrarAviso(e.toString());
    }
  }

  void _gerarNPC({
    required bool rocket,
  }) {
    final lista = _npcDaModalidade(rocket);

    if (lista.isEmpty) {
      _mostrarAviso(
        rocket
            ? 'Não existem $_menuInimigos cadastrados para $_modalidade.'
            : 'Não existem $_menuAliados cadastrados para $_modalidade.',
      );
      return;
    }

    final disponiveis = lista.where((item) {
      if (!_disponivelNoPeriodo(
        item.periodo,
      )) {
        return false;
      }

      return _disponivelNaLegua(
        item.leguaMin,
        item.leguaMax,
      );
    }).toList();

    if (disponiveis.isEmpty) {
      _mostrarAviso(
        rocket
            ? 'Não existem $_menuInimigos disponíveis na Légua $_leguaAtual para o período $_periodo.'
            : 'Não existem $_menuAliados disponíveis na Légua $_leguaAtual para o período $_periodo.',
      );
      return;
    }

    final escolhido = disponiveis[_random.nextInt(
      disponiveis.length,
    )];

    final NPC npc = escolhido.npc;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NPCScreen(
          npcId: npc.id,
        ),
      ),
    );
  }

  void _mostrarCriatura(Criatura criatura) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _card,
          surfaceTintColor: Colors.transparent,
          contentPadding: const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            18,
          ),
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
                  style: TextStyle(
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
                      if (!mounted) {
                        return;
                      }

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

  void _mostrarAviso(
    String mensagem,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _texto,
        content: Text(
          mensagem,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _chipInfo({
    required IconData icon,
    required String titulo,
    required String valor,
    required Color cor,
    double? largura,
  }) {
    return Container(
      width: largura,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _borda),
        boxShadow: const [
          BoxShadow(
            blurRadius: 5,
            offset: Offset(0, 2),
            color: Color(0x12000000),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cor.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: cor,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.5,
                    color: _textoSecundario,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _texto,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cabecalhoLocal() {
    final local = _local;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borda),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Color(0x18000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _vermelho,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 7,
                      offset: Offset(0, 3),
                      color: Color(0x30000000),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 29,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      local.nome,
                      style: const TextStyle(
                        fontSize: 27,
                        color: _texto,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (local.regiaoId.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.map_outlined,
                              size: 15,
                              color: _azul,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Região: ${local.regiaoId}',
                              style: const TextStyle(
                                color: _textoSecundario,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (local.descricao.isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.only(left: 13),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: _amarelo,
                    width: 4,
                  ),
                ),
              ),
              child: Text(
                local.descricao,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: _texto,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _carregarConexoesDestino() async {
    final locais = await _repository.carregar();
    if (!mounted) return;
    setState(() {
      _locaisConexaoCache = locais;
    });
  }

  Widget _buildConexoes() {
    final localAtual = _localAtual;
    if (localAtual == null || localAtual.conexoes.isEmpty) {
      return const SizedBox.shrink();
    }

    const direcoes = ['Norte', 'Sul', 'Leste', 'Oeste'];
    final agrupadas = <String, List<dynamic>>{};

    for (final conexao in localAtual.conexoes) {
      if (conexao is! Map) continue;

      final direcaoOriginal = (conexao['direcao'] ?? '').toString().trim();
      var direcao = direcaoOriginal;

      for (final cardinal in direcoes) {
        if (cardinal.toLowerCase() == direcaoOriginal.toLowerCase()) {
          direcao = cardinal;
          break;
        }
      }

      if (direcao.isEmpty) direcao = 'Outras';
      agrupadas.putIfAbsent(direcao, () => <dynamic>[]).add(conexao);
    }

    Widget linhaConexao(dynamic conexao) {
      final leguas = (conexao['leguas'] ?? 0).toString().padLeft(2, '0');
      final localId = conexao['localId'];
      debugPrint('[DEBUG CONEXAO] localId=$localId');

      Local? localDestino;
      var destino = 'Destino não encontrado';

      debugPrint('[DEBUG CONEXAO] Procurando em ${_locaisConexaoCache.length} locais:');
      for (final l in _locaisConexaoCache) { debugPrint('[DEBUG CONEXAO]   local.id=${l.id} nome=${l.nome}'); }
      for (final local in _locaisConexaoCache) {
        if (local.id.toString() == localId.toString()) {
          localDestino = local;
          destino = local.nome;
          break;
        }
      }

      return Card(
        margin: const EdgeInsets.only(top: 8),
        elevation: 0,
        color: _card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: _borda),
        ),
        child: ListTile(
          title: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Légua $leguas - Saída para '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: InkWell(
                    onTap: localDestino == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => LocalScreen(
                                  local: localDestino!,
                                ),
                              ),
                            );
                          },
                    child: Text(
                      destino,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _azul,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    final ordemDirecoes = <String>[
      ...direcoes,
      ...agrupadas.keys.where((direcao) => !direcoes.contains(direcao)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _tituloSecao('Conexões', Icons.alt_route),
        for (final direcao in ordemDirecoes)
          if (agrupadas.containsKey(direcao)) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 2),
              child: Text(
                direcao,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _azul,
                ),
              ),
            ),
            for (final conexao in agrupadas[direcao]!) linhaConexao(conexao),
          ],
      ],
    );
  }

  Widget _informacoesLocal() {
    final local = _local;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardSuave,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _chipInfo(
                  icon: Icons.straighten,
                  titulo: 'LÉGUAS',
                  valor: '${local.leguas}',
                  cor: _vermelho,
                ),
              ),
              if (local.nivelMinCriatura > 0 || local.nivelMaxCriatura > 0) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _chipInfo(
                    icon: Icons.pets,
                    titulo: 'NÍVEL DE ENCONTRO',
                    valor:
                        '${local.nivelMinCriatura} - ${local.nivelMaxCriatura}',
                    cor: _amarelo,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          _chipInfo(
            icon: Icons.terrain,
            titulo: 'TERRENO',
            valor: local.terreno,
            cor: _verde,
          ),
        ],
      ),
    );
  }

  Widget _linhaNPC(
    String rotulo,
    List<dynamic> encontros,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: [
          for (int i = 0; i < encontros.length; i++)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                final npc = encontros[i].npc;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NPCScreen(npcId: npc.id),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 3,
                ),
                child: Text(
                  encontros[i].npc.nome + (i < encontros.length - 1 ? ',' : ''),
                  style: const TextStyle(
                    color: _azul,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _listaCriatura(
    List<dynamic> criaturas,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final item in criaturas)
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CriaturaDetalheScreen(
                      criatura: item.criatura,
                      nivelAlteravel: true,
                      origem: OrigemCriatura.selvagem,
                      iniciarBatalha: false,
                    ),
                  ),
                );
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
                  item.criatura.nome,
                  style: const TextStyle(
                    color: _azul,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _iconeEncontro(String titulo) {
    switch (titulo) {
      case 'Encontro Diurno':
        return Icons.wb_sunny;
      case 'Encontro Noturno':
        return Icons.nightlight_round;
      case 'Encontro Pesca':
        return Icons.phishing;
      case 'Encontro Aquático':
        return Icons.waves;
      default:
        return Icons.casino;
    }
  }

  String _tituloEncontroCurto(String titulo) {
    switch (titulo) {
      case 'Encontro Diurno':
        return 'Diurno';
      case 'Encontro Noturno':
        return 'Noturno';
      case 'Encontro Pesca':
        return 'Pesca';
      case 'Encontro Aquático':
        return 'Aquático';
      default:
        return titulo;
    }
  }

  Color _corEncontro(String titulo) {
    switch (titulo) {
      case 'Encontro Diurno':
        return _verde;
      case 'Encontro Noturno':
        return _roxo;
      case 'Encontro Pesca':
        return _ciano;
      case 'Encontro Aquático':
        return _laranja;
      default:
        return _azul;
    }
  }

  Widget _botaoListaEncontro({
    required String titulo,
    required IconData icone,
    required List<dynamic> itens,
    required bool criaturas,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OutlinedButton(
        child: Text(
          _tituloEncontroCurto(titulo),
          style: const TextStyle(fontSize: 12),
        ),
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(_tituloEncontroCurto(titulo)),
              content: SizedBox(
                width: double.maxFinite,
                child: itens.isEmpty
                    ? const Text('Nenhum item cadastrado.')
                    : SingleChildScrollView(
                        child: criaturas
                            ? _listaCriatura(itens)
                            : _linhaNPC(titulo, itens),
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _secaoEncontro({
    required String titulo,
    required String dado,
    required List<dynamic> criaturas,
    required List<dynamic> treinadores,
    required List<dynamic> rockets,
  }) {
    final temDado = dado.trim().isNotEmpty;
    final temCriatura = criaturas.isNotEmpty;
    final temTreinadores = treinadores.isNotEmpty;
    final temRockets = rockets.isNotEmpty;

    if (!temDado && !temCriatura && !temTreinadores && !temRockets) {
      return const SizedBox.shrink();
    }

    final cor = _corEncontro(titulo);

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borda),
        boxShadow: const [
          BoxShadow(
            blurRadius: 7,
            offset: Offset(0, 3),
            color: Color(0x12000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cor.withAlpha(25),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: cor.withAlpha(110),
                  ),
                ),
                child: Icon(
                  _iconeEncontro(titulo),
                  size: 21,
                  color: cor,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  _tituloEncontroCurto(titulo),
                  style: TextStyle(
                    fontSize: 18,
                    color: cor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: 7,
                height: 27,
                decoration: BoxDecoration(
                  color: cor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
          if (temDado) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: _cardSuave,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: cor.withAlpha(70),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.casino_outlined,
                    size: 19,
                    color: _amarelo,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dado,
                      style: const TextStyle(
                        height: 1.35,
                        color: _textoSecundario,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            children: [
              Expanded(
                child: _botaoListaEncontro(
                  titulo: _nomeCriatura,
                  icone: Icons.pets_outlined,
                  itens: criaturas,
                  criaturas: true,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _botaoListaEncontro(
                  titulo: _menuAliados,
                  icone: Icons.groups_outlined,
                  itens: treinadores,
                  criaturas: false,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _botaoListaEncontro(
                  titulo: _menuInimigos,
                  icone: Icons.shield_outlined,
                  itens: rockets,
                  criaturas: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tituloSecao(
    String titulo,
    IconData icone,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 26,
        bottom: 2,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _vermelho.withAlpha(22),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: _vermelho.withAlpha(70),
              ),
            ),
            child: Icon(
              icone,
              size: 19,
              color: _vermelho,
            ),
          ),
          const SizedBox(width: 9),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 20,
              color: _texto,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Container(
              height: 2,
              color: _amarelo.withAlpha(100),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirItemBase(Item itemLocal) async {
    final itensBase = await ItensRepository().carregar();
    Item? itemBase;

    for (final candidato in itensBase) {
      if (candidato.nome.trim().toLowerCase() ==
          itemLocal.nome.trim().toLowerCase()) {
        itemBase = candidato;
        break;
      }
    }

    if (!mounted) return;

    if (itemBase == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro-base do item não encontrado.'),
        ),
      );
      return;
    }

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ItemDetalheScreen(item: itemBase!),
      ),
    );
  }

  Widget _buildItens() {
    if (_local.itens.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSecao('Itens', Icons.inventory_2_outlined),
        ..._local.itens.map(
          (item) => Card(
            margin: const EdgeInsets.only(top: 10),
            elevation: 0,
            color: _card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: _borda),
            ),
            child: ListTile(
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _amarelo.withAlpha(35),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: _amarelo,
                ),
              ),
              title: Text(
                '${item.nome} x${item.quantidade} = Légua ${item.localizacao.trim().isEmpty ? '—' : item.localizacao.trim()}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: item.descricao.trim().isEmpty
                  ? null
                  : Text(
                      item.descricao.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
              trailing: const Icon(Icons.chevron_right, color: _azul),
              onTap: () => _abrirItemBase(item),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPontosInteresse() {
    final pontos = _local.pontosInteresse;

    if (pontos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSecao(
          'Pontos de Interesse',
          Icons.place_outlined,
        ),
        ...pontos.map(
          (ponto) => Card(
            margin: const EdgeInsets.only(top: 10),
            elevation: 0,
            color: _card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(
                color: _borda,
              ),
            ),
            child: ListTile(
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _azul.withAlpha(22),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.place_outlined,
                  color: _azul,
                ),
              ),
              title: Text(
                'L\u00E9gua ${ponto.leguas}: ${ponto.nome}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: ponto.descricao.isEmpty
                  ? null
                  : Text(
                      ponto.descricao,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
              trailing: const Icon(
                Icons.chevron_right,
              ),
              onTap: () => _abrirPontoInteresse(ponto),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventos() {
    final eventos = _local.eventos;

    if (_local.dadoEventos.trim().isEmpty && eventos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSecao(
          'Eventos',
          Icons.warning_amber_rounded,
        ),
        if (_local.dadoEventos.trim().isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _borda,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.casino_outlined,
                    color: _laranja,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _local.dadoEventos.trim(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ...eventos.map(
          (evento) => Card(
            margin: const EdgeInsets.only(top: 10),
            elevation: 0,
            color: _card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(
                color: _borda,
              ),
            ),
            child: ListTile(
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _laranja.withAlpha(22),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: _laranja,
                ),
              ),
              title: Text(
                evento.nome,
                style: const TextStyle(
                  color: _azul,
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: evento.descricao.trim().isEmpty
                  ? null
                  : Text(
                      evento.descricao.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
              trailing: const Icon(
                Icons.chevron_right,
                color: _azul,
              ),
              onTap: () => _abrirEvento(evento),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final local = _local;

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
          centerTitle: false,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelStyle: TextStyle(
            color: _vermelho,
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            local.nome,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Editar local',
              icon: const Icon(
                Icons.edit_outlined,
              ),
              onPressed: _editarLocal,
            ),
            IconButton(
              tooltip: 'Excluir local',
              icon: const Icon(
                Icons.delete_outline,
              ),
              onPressed: _excluirLocal,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            28,
          ),
          children: [
            _cabecalhoLocal(),
            const SizedBox(height: 12),
            _informacoesLocal(),
            _buildConexoes(),
            _tituloSecao(
              'Encontros',
              Icons.casino_outlined,
            ),
            _secaoEncontro(
              titulo: 'Encontro Diurno',
              dado: local.dadoEncontroDiurno,
              criaturas: local.encontros.diurno,
              treinadores: local.treinadores.diurno,
              rockets: local.rockets.diurno,
            ),
            _secaoEncontro(
              titulo: 'Encontro Noturno',
              dado: local.dadoEncontroNoturno,
              criaturas: local.encontros.noturno,
              treinadores: local.treinadores.noturno,
              rockets: local.rockets.noturno,
            ),
            _secaoEncontro(
              titulo: 'Encontro Pesca',
              dado: local.dadoEncontroPesca,
              criaturas: local.encontros.pesca,
              treinadores: local.treinadores.pesca,
              rockets: local.rockets.pesca,
            ),
            _secaoEncontro(
              titulo: 'Encontro Aquático',
              dado: local.dadoEncontroSurfe,
              criaturas: local.encontros.surfe,
              treinadores: local.treinadores.surfe,
              rockets: local.rockets.surfe,
            ),
            const SizedBox(height: 26),
            Container(
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
            _buildItens(),
            _buildEventos(),
            _buildPontosInteresse(),
          ],
        ),
      ),
    );
  }
}
