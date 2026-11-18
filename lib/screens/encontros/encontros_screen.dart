import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../geradores/gerador_encontros.dart';
import '../../models/local.dart';
import '../../models/criatura.dart';
import '../../models/tipo_encontro.dart';
import '../../models/periodo_dia.dart';
import '../../repositories/locais_repository.dart';
import '../../widgets/pt_dropdown.dart';
import '../bestiario/criatura_detalhe_screen.dart';

class EncontrosScreen extends ConsumerStatefulWidget {
  const EncontrosScreen({super.key});

  @override
  ConsumerState<EncontrosScreen> createState() => _EncontrosScreenState();
}

class _EncontrosScreenState extends ConsumerState<EncontrosScreen> {
  final GeradorEncontro _gerador = GeradorEncontro();
  final LocaisRepository _locaisRepository = LocaisRepository();

  List<Local> _locais = [];

  String? regiaoSelecionada;
  Local? localSelecionado;

  TipoEncontro tipoSelecionado = TipoEncontro.diurno;

  PeriodoDia periodoSelecionado = PeriodoDia.qualquer;

  Criatura? resultado;

  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarLocais();
  }

  Future<void> _carregarLocais() async {
    final locais = await _locaisRepository.carregar();

    if (!mounted) {
      return;
    }

    final regioes = locais
        .map((local) => local.regiaoId.trim())
        .where((regiao) => regiao.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final primeiraRegiao = regioes.isEmpty ? null : regioes.first;

    final locaisDaRegiao = primeiraRegiao == null
        ? <Local>[]
        : locais
            .where(
              (local) => local.regiaoId.trim() == primeiraRegiao,
            )
            .toList();

    final primeiroLocal = locaisDaRegiao.isEmpty ? null : locaisDaRegiao.first;

    final tipos = primeiroLocal == null
        ? <TipoEncontro>[]
        : _tiposDisponiveis(
            primeiroLocal,
          );

    final primeiroTipo = tipos.isNotEmpty ? tipos.first : TipoEncontro.diurno;

    setState(() {
      _locais = locais;
      regiaoSelecionada = primeiraRegiao;
      localSelecionado = primeiroLocal;
      tipoSelecionado = primeiroTipo;
      periodoSelecionado = _periodoValidoParaTipo(
        primeiroTipo,
        periodoSelecionado,
      );
      _carregando = false;
    });
  }

  List<String> get _regioesDisponiveis {
    return _locais
        .map((local) => local.regiaoId.trim())
        .where((regiao) => regiao.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  List<Local> _locaisDaRegiao(
    String regiao,
  ) {
    return _locais
        .where(
          (local) => local.regiaoId.trim() == regiao,
        )
        .toList();
  }

  List<TipoEncontro> _tiposDisponiveis(
    Local local,
  ) {
    final tipos = <TipoEncontro>[];

    if (local.encontros.diurno.isNotEmpty) {
      tipos.add(TipoEncontro.diurno);
    }

    if (local.encontros.noturno.isNotEmpty) {
      tipos.add(TipoEncontro.noturno);
    }

    if (local.encontros.pesca.isNotEmpty) {
      tipos.add(TipoEncontro.pesca);
    }

    if (local.encontros.surfe.isNotEmpty) {
      tipos.add(TipoEncontro.surfe);
    }

    return tipos;
  }

  List<PeriodoDia> _periodosDisponiveis(
    TipoEncontro tipo,
  ) {
    switch (tipo) {
      case TipoEncontro.diurno:
        return const [
          PeriodoDia.qualquer,
          PeriodoDia.amanhecer,
          PeriodoDia.manha,
          PeriodoDia.tarde,
        ];

      case TipoEncontro.noturno:
        return const [
          PeriodoDia.qualquer,
          PeriodoDia.anoitecer,
          PeriodoDia.noite,
          PeriodoDia.madrugada,
        ];

      case TipoEncontro.pesca:
      case TipoEncontro.surfe:
        return const [
          PeriodoDia.qualquer,
          PeriodoDia.amanhecer,
          PeriodoDia.manha,
          PeriodoDia.tarde,
          PeriodoDia.anoitecer,
          PeriodoDia.noite,
          PeriodoDia.madrugada,
        ];
    }
  }

  PeriodoDia _periodoValidoParaTipo(
    TipoEncontro tipo,
    PeriodoDia periodo,
  ) {
    final periodos = _periodosDisponiveis(tipo);

    if (periodos.contains(periodo)) {
      return periodo;
    }

    return PeriodoDia.qualquer;
  }

  String _nomeTipo(TipoEncontro tipo) {
    switch (tipo) {
      case TipoEncontro.diurno:
        return 'Diurno';

      case TipoEncontro.noturno:
        return 'Noturno';

      case TipoEncontro.pesca:
        return 'Pesca';

      case TipoEncontro.surfe:
        return 'Aquático';
    }
  }

  Future<void> _abrirCriaturaSelvagem() async {
    final criatura = resultado;

    if (criatura == null || !mounted) {
      return;
    }

    await Navigator.push(
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
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Gerador de Encontros',
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final regioes = _regioesDisponiveis;

    final locais = regiaoSelecionada == null
        ? <Local>[]
        : _locaisDaRegiao(
            regiaoSelecionada!,
          );

    final tiposDisponiveis = localSelecionado == null
        ? <TipoEncontro>[]
        : _tiposDisponiveis(
            localSelecionado!,
          );

    final periodosDisponiveis = _periodosDisponiveis(
      tipoSelecionado,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gerador de Encontros',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (regioes.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Nenhum Local cadastrado.',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            if (regioes.isNotEmpty)
              PTDropdown<String>(
                label: 'Região',
                value: regiaoSelecionada,
                items: regioes,
                itemLabel: (regiao) => regiao,
                onChanged: (valor) {
                  if (valor == null) {
                    return;
                  }

                  final novosLocais = _locaisDaRegiao(valor);

                  final novoLocal =
                      novosLocais.isEmpty ? null : novosLocais.first;

                  final novosTipos = novoLocal == null
                      ? <TipoEncontro>[]
                      : _tiposDisponiveis(
                          novoLocal,
                        );

                  final novoTipo = novosTipos.contains(
                    tipoSelecionado,
                  )
                      ? tipoSelecionado
                      : novosTipos.isNotEmpty
                          ? novosTipos.first
                          : TipoEncontro.diurno;

                  setState(() {
                    regiaoSelecionada = valor;
                    localSelecionado = novoLocal;
                    tipoSelecionado = novoTipo;
                    periodoSelecionado = _periodoValidoParaTipo(
                      novoTipo,
                      periodoSelecionado,
                    );
                    resultado = null;
                  });
                },
              ),
            if (regioes.isNotEmpty) const SizedBox(height: 20),
            if (locais.isNotEmpty)
              PTDropdown<Local>(
                label: 'Local',
                value: localSelecionado,
                items: locais,
                itemLabel: (local) => local.nome,
                onChanged: (local) {
                  if (local == null) {
                    return;
                  }

                  final tipos = _tiposDisponiveis(local);

                  final novoTipo = tipos.contains(
                    tipoSelecionado,
                  )
                      ? tipoSelecionado
                      : tipos.isNotEmpty
                          ? tipos.first
                          : TipoEncontro.diurno;

                  setState(() {
                    localSelecionado = local;
                    tipoSelecionado = novoTipo;
                    periodoSelecionado = _periodoValidoParaTipo(
                      novoTipo,
                      periodoSelecionado,
                    );
                    resultado = null;
                  });
                },
              ),
            if (locais.isNotEmpty) const SizedBox(height: 20),
            if (tiposDisponiveis.isNotEmpty)
              PTDropdown<TipoEncontro>(
                label: 'Dado de Encontro',
                value: tipoSelecionado,
                items: tiposDisponiveis,
                itemLabel: _nomeTipo,
                onChanged: (tipo) {
                  if (tipo == null) {
                    return;
                  }

                  setState(() {
                    tipoSelecionado = tipo;
                    periodoSelecionado = _periodoValidoParaTipo(
                      tipo,
                      periodoSelecionado,
                    );
                    resultado = null;
                  });
                },
              ),
            if (tiposDisponiveis.isNotEmpty) const SizedBox(height: 20),
            PTDropdown<PeriodoDia>(
              label: 'Período',
              value: periodoSelecionado,
              items: periodosDisponiveis,
              itemLabel: (periodo) => periodo.texto,
              onChanged: (periodo) {
                if (periodo == null) {
                  return;
                }

                setState(() {
                  periodoSelecionado = periodo;
                  resultado = null;
                });
              },
            ),
            const SizedBox(height: 30),
            if (localSelecionado != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Faixa de nível do Local',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${localSelecionado!.nivelMinCriatura}'
                        ' – '
                        '${localSelecionado!.nivelMaxCriatura}',
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: localSelecionado == null || tiposDisponiveis.isEmpty
                    ? null
                    : () {
                        try {
                          final criatura = _gerador.gerar(
                            localSelecionado!,
                            tipoSelecionado,
                            periodoSelecionado,
                          );

                          setState(() {
                            resultado = criatura;
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString(),
                              ),
                            ),
                          );
                        }
                      },
                child: const Text(
                  'Sortear Encontro',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (resultado != null)
              Card(
                elevation: 3,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _abrirCriaturaSelvagem,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          child: const Icon(
                            Icons.pets,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Encontro sorteado',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                resultado!.nome,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Nível ${resultado!.nivel}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.blue.shade700,
                          size: 32,
                        ),
                      ],
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
