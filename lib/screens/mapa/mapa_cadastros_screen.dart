import 'package:flutter/material.dart';

import '../../models/evento.dart';
import '../../models/ponto_interesse.dart';
import '../../repositories/cadastros_repository.dart';
import 'evento_edit_screen.dart';
import 'ponto_interesse_edit_screen.dart';

class MapaCadastrosScreen extends StatefulWidget {
  const MapaCadastrosScreen({super.key});

  @override
  State<MapaCadastrosScreen> createState() =>
      _MapaCadastrosScreenState();
}

class _MapaCadastrosScreenState
    extends State<MapaCadastrosScreen> {
  final CadastrosRepository _cadastros =
      CadastrosRepository();

  List<Evento> _eventos = [];
  List<PontoInteresse> _pontos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final eventos =
        await _cadastros.carregarEventos();

    final pontos =
        await _cadastros.carregarPontos();

    eventos.sort(
      (a, b) => a.nome.toLowerCase().compareTo(
            b.nome.toLowerCase(),
          ),
    );

    pontos.sort(
      (a, b) => a.nome.toLowerCase().compareTo(
            b.nome.toLowerCase(),
          ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _eventos = eventos;
      _pontos = pontos;
      _carregando = false;
    });
  }

  Future<void> _criarEvento() async {
    final resultado =
        await Navigator.push<Evento>(
      context,
      MaterialPageRoute(
        builder: (_) => const EventoEditScreen(),
      ),
    );

    if (resultado == null) {
      return;
    }

    await _cadastros.salvarEvento(resultado);
    await _carregar();
  }

  Future<void> _editarEvento(
    Evento evento,
  ) async {
    final resultado =
        await Navigator.push<Evento>(
      context,
      MaterialPageRoute(
        builder: (_) => EventoEditScreen(
          evento: evento,
        ),
      ),
    );

    if (resultado == null) {
      return;
    }

    await _cadastros.salvarEvento(resultado);
    await _carregar();
  }

  Future<void> _criarPonto() async {
    final resultado =
        await Navigator.push<PontoInteresse>(
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

    if (resultado == null) {
      return;
    }

    await _cadastros.salvarPonto(resultado);
    await _carregar();
  }

  Future<void> _editarPonto(
    PontoInteresse ponto,
  ) async {
    final resultado =
        await Navigator.push<PontoInteresse>(
      context,
      MaterialPageRoute(
        builder: (_) => PontoInteresseEditScreen(
          ponto: ponto,
        ),
      ),
    );

    if (resultado == null) {
      return;
    }

    await _cadastros.salvarPonto(resultado);
    await _carregar();
  }

  Future<void> _excluirEvento(
    Evento evento,
  ) async {
    final confirmar = await _confirmar(
      'Excluir cadastro-base?',
      'Isso remove somente o cadastro-base. Cópias já incluídas em Locais não serão alteradas.',
    );

    if (confirmar) {
      await _cadastros.removerEvento(evento.id);
      await _carregar();
    }
  }

  Future<void> _excluirPonto(
    PontoInteresse ponto,
  ) async {
    final confirmar = await _confirmar(
      'Excluir cadastro-base?',
      'Isso remove somente o cadastro-base. Cópias já incluídas em Locais não serão alteradas.',
    );

    if (confirmar) {
      await _cadastros.removerPonto(ponto.id);
      await _carregar();
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
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    return resultado == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastros do Mapa'),
      ),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _carregar,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _secao(
                    titulo: 'Eventos',
                    cor: const Color(0xFFE07A32),
                    icone:
                        Icons.warning_amber_rounded,
                    onCreate: _criarEvento,
                    children: _eventos.isEmpty
                        ? const [
                            ListTile(
                              title: Text(
                                'Nenhum evento-base cadastrado.',
                              ),
                            ),
                          ]
                        : _eventos
                            .map(
                              (evento) => ListTile(
                                leading: const Icon(
                                  Icons
                                      .warning_amber_rounded,
                                  color:
                                      Color(0xFFE07A32),
                                ),
                                title: Text(
                                  evento.nome.isEmpty
                                      ? 'Evento sem nome'
                                      : evento.nome,
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Cadastro-base',
                                ),
                                onTap: () =>
                                    _editarEvento(
                                  evento,
                                ),
                                trailing:
                                    IconButton(
                                  tooltip:
                                      'Excluir cadastro-base',
                                  icon: const Icon(
                                    Icons
                                        .delete_outline,
                                    color:
                                        Color(0xFFD64545),
                                  ),
                                  onPressed: () =>
                                      _excluirEvento(
                                    evento,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                  _secao(
                    titulo: 'Pontos de Interesse',
                    cor: const Color(0xFF7856A8),
                    icone:
                        Icons.place_outlined,
                    onCreate: _criarPonto,
                    children: _pontos.isEmpty
                        ? const [
                            ListTile(
                              title: Text(
                                'Nenhum ponto de interesse-base cadastrado.',
                              ),
                            ),
                          ]
                        : _pontos
                            .map(
                              (ponto) => ListTile(
                                leading: const Icon(
                                  Icons.place_outlined,
                                  color:
                                      Color(0xFF7856A8),
                                ),
                                title: Text(
                                  ponto.nome.isEmpty
                                      ? 'Ponto sem nome'
                                      : ponto.nome,
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Cadastro-base',
                                ),
                                onTap: () =>
                                    _editarPonto(
                                  ponto,
                                ),
                                trailing:
                                    IconButton(
                                  tooltip:
                                      'Excluir cadastro-base',
                                  icon: const Icon(
                                    Icons
                                        .delete_outline,
                                    color:
                                        Color(0xFFD64545),
                                  ),
                                  onPressed: () =>
                                      _excluirPonto(
                                    ponto,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _criarEvento,
        backgroundColor:
            const Color(0xFFE07A32),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Criar Evento'),
      ),
    );
  }

  Widget _secao({
    required String titulo,
    required Color cor,
    required IconData icone,
    required VoidCallback onCreate,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: cor.withValues(alpha: 0.35),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icone,
                color: cor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: cor,
                  foregroundColor:
                      Colors.white,
                ),
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text('Criar'),
              ),
            ],
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }
}
