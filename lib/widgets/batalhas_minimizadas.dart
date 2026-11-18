import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../gerenciadores/batalhas.dart';
import '../main.dart';
import '../screens/bestiario/criatura_detalhe_screen.dart';

class BatalhasMinimizadas extends ConsumerStatefulWidget {
  const BatalhasMinimizadas({super.key});

  @override
  ConsumerState<BatalhasMinimizadas> createState() =>
      _BatalhasMinimizadasState();
}

class _BatalhasMinimizadasState
    extends ConsumerState<BatalhasMinimizadas> {
  bool _aberto = false;

  void _abrir() {
    if (!_aberto) {
      setState(() {
        _aberto = true;
      });
    }
  }

  void _fechar() {
    if (_aberto) {
      setState(() {
        _aberto = false;
      });
    }
  }

  void _abrirBatalha(Batalhacriatura batalha) {
    final navigator = appNavigatorKey.currentState;

    if (navigator == null) {
      return;
    }

    ref
        .read(batalhasProvider.notifier)
        .ativar(batalha.id);

    setState(() {
      _aberto = false;
    });

    navigator.push(
      MaterialPageRoute(
        builder: (_) => CriaturaDetalheScreen(
          criatura: batalha.criatura,
          batalhaId: batalha.id,
          origem: switch (batalha.origem) {
            'treinador' => OrigemCriatura.treinador,
            'selvagem' => OrigemCriatura.selvagem,
            _ => OrigemCriatura.bestiario,
          },
        ),
      ),
    );
  }

  Color _corOrigem(String origem) {
    switch (origem) {
      case 'treinador':
        return Colors.amber.shade700;
      case 'selvagem':
        return Colors.blue.shade700;
      case 'bestiario':
      default:
        return Colors.red.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final batalhas = ref.watch(batalhasProvider);

    final minimizadas = batalhas
        .where((batalha) => batalha.minimizada)
        .toList();

    return Stack(
      children: [
        if (!_aberto)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 28,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx < -2) {
                  _abrir();
                }
              },
              onHorizontalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) < -100) {
                  _abrir();
                }
              },
            ),
          ),

        if (_aberto)
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _fechar,
                    onHorizontalDragUpdate: (details) {
                      if (details.delta.dx > 2) {
                        _fechar();
                      }
                    },
                    onHorizontalDragEnd: (details) {
                      if ((details.primaryVelocity ?? 0) > 100) {
                        _fechar();
                      }
                    },
                    child: const SizedBox.expand(),
                  ),
                ),
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx > 2) {
                      _fechar();
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    if ((details.primaryVelocity ?? 0) > 100) {
                      _fechar();
                    }
                  },
                  child: Material(
                    elevation: 16,
                    color: Colors.white,
                    child: SafeArea(
                      left: false,
                      child: SizedBox(
                        width: 320,
                        height: double.infinity,
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                14,
                                10,
                                14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade700,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.sports_martial_arts,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Painel de Batalha',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _fechar,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 36,
                                      minHeight: 36,
                                    ),
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: minimizadas.isEmpty
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(24),
                                        child: Text(
                                          'Nenhuma batalha minimizada.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.fromLTRB(
                                        8,
                                        10,
                                        8,
                                        20,
                                      ),
                                      itemCount: minimizadas.length,
                                      itemBuilder: (context, index) {
                                        final batalha =
                                            minimizadas[index];

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 6,
                                          ),
                                          child: _batalhaItem(batalha),
                                        );
                                      },
                                    ),
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
      ],
    );
  }

  Widget _batalhaItem(Batalhacriatura batalha) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: _corOrigem(batalha.origem),
        elevation: 7,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _abrirBatalha(batalha),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              10,
              8,
              4,
              8,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.pets,
                  color: Colors.white,
                  size: 25,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        batalha.criatura.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Nível ${batalha.criatura.nivel}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'PV: ${batalha.pv}/${batalha.criatura.pv}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ref
                        .read(batalhasProvider.notifier)
                        .fechar(batalha.id);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    maxWidth: 28,
                    minHeight: 28,
                    maxHeight: 28,
                  ),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
