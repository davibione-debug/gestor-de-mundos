import 'package:flutter/material.dart';

import '../../models/evento.dart';
import '../../models/local.dart';
import '../../models/ponto_interesse.dart';
import '../../repositories/locais_repository.dart';
import '../../repositories/cadastros_repository.dart';
import 'evento_edit_screen.dart';
import 'evento_screen.dart';
import 'local_edit_screen.dart';
import 'local_screen.dart';
import 'ponto_interesse_edit_screen.dart';
import 'ponto_interesse_screen.dart';

enum _CategoriaMapa {
  locais,
  eventos,
  pontosInteresse,
}

class _EventoMapa {
  final Evento evento;
  final Local? local;
  final PontoInteresse? ponto;
  final bool cadastroBase;

  const _EventoMapa({
    required this.evento,
    this.local,
    this.ponto,
    this.cadastroBase = false,
  });
}

class _PontoMapa {
  final PontoInteresse ponto;
  final Local? local;
  final bool cadastroBase;

  const _PontoMapa({
    required this.ponto,
    this.local,
    this.cadastroBase = false,
  });
}

class MapaScreen extends StatefulWidget {
  const MapaScreen({
    super.key,
  });

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final LocaisRepository _repository = LocaisRepository();

  final TextEditingController _pesquisaController = TextEditingController();

  List<Local> _locais = [];
  List<Evento> _eventosBase = [];
  List<PontoInteresse> _pontosBase = [];

  bool _carregando = true;

  String _pesquisa = '';
  String _regiaoSelecionada = 'Todas';

  _CategoriaMapa _categoria = _CategoriaMapa.locais;

  @override
  void initState() {
    super.initState();

    _pesquisaController.addListener(
      _atualizarPesquisa,
    );

    _carregarDados();
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    final locais = await _repository.carregar();

    final cadastros = CadastrosRepository();

    final eventosBase = await cadastros.carregarEventos();

    final pontosBase = await cadastros.carregarPontos();

    if (!mounted) {
      return;
    }

    final regioes = locais
        .map(
          (local) => local.regiaoId.trim(),
        )
        .where(
          (regiao) => regiao.isNotEmpty,
        )
        .toSet();

    eventosBase.sort(
      (a, b) => a.nome.toLowerCase().compareTo(
            b.nome.toLowerCase(),
          ),
    );

    pontosBase.sort(
      (a, b) => a.nome.toLowerCase().compareTo(
            b.nome.toLowerCase(),
          ),
    );

    setState(() {
      _locais = locais;
      _eventosBase = eventosBase;
      _pontosBase = pontosBase;
      _carregando = false;

      if (_regiaoSelecionada != 'Todas' &&
          !regioes.contains(
            _regiaoSelecionada,
          )) {
        _regiaoSelecionada = 'Todas';
      }
    });
  }

  void _atualizarPesquisa() {
    if (!mounted) {
      return;
    }

    setState(() {
      _pesquisa = _pesquisaController.text.trim().toLowerCase();
    });
  }

  List<String> get _regioes {
    final regioes = _locais
        .map(
          (local) => local.regiaoId.trim(),
        )
        .where(
          (regiao) => regiao.isNotEmpty,
        )
        .toSet()
        .toList();

    regioes.sort(
      (a, b) => a.toLowerCase().compareTo(
            b.toLowerCase(),
          ),
    );

    return [
      'Todas',
      ...regioes,
    ];
  }

  List<Local> get _locaisFiltrados {
    return _locais.where((local) {
      final texto = '${local.nome} '
              '${local.descricao} '
              '${local.regiaoId}'
          .toLowerCase();

      final pesquisa = _pesquisa.isEmpty || texto.contains(_pesquisa);

      final regiao = _regiaoSelecionada == 'Todas' ||
          local.regiaoId.trim() == _regiaoSelecionada;

      return pesquisa && regiao;
    }).toList();
  }

  List<_EventoMapa> get _eventos {
    return _eventosBase
        .map(
          (evento) => _EventoMapa(
            evento: evento,
            local: null,
            ponto: null,
            cadastroBase: true,
          ),
        )
        .toList();
  }

  List<_EventoMapa> get _eventosFiltrados {
    return _eventos.where((item) {
      final evento = item.evento;
      final local = item.local;

      final texto = '${evento.nome} '
              '${evento.descricao} '
              '${evento.localizacao} '
              '${evento.efeito} '
              '${evento.aliados.join('' '')} ${evento.inimigos.join('' '')} '
              '${evento.criatura ?? ''} '
              '${evento.itens} '
              '${local?.nome ?? ''} '
              '${item.ponto?.nome ?? ''}'
          .toLowerCase();

      final pesquisa = _pesquisa.isEmpty || texto.contains(_pesquisa);

      final regiao = _regiaoSelecionada == 'Todas' ||
          local == null ||
          local.regiaoId.trim() == _regiaoSelecionada;

      return pesquisa && regiao;
    }).toList();
  }

  List<_PontoMapa> get _pontos {
    return _pontosBase
        .map(
          (ponto) => _PontoMapa(
            ponto: ponto,
            local: null,
            cadastroBase: true,
          ),
        )
        .toList();
  }

  List<_PontoMapa> get _pontosFiltrados {
    return _pontos.where((item) {
      final ponto = item.ponto;
      final local = item.local;

      final texto = '${ponto.nome} '
              '${ponto.descricao} '
              '${ponto.localizacao} '
              '${local?.nome ?? ''}'
          .toLowerCase();

      final pesquisa = _pesquisa.isEmpty || texto.contains(_pesquisa);

      final regiao = _regiaoSelecionada == 'Todas' ||
          local == null ||
          local.regiaoId.trim() == _regiaoSelecionada;

      return pesquisa && regiao;
    }).toList();
  }

  int get _quantidadeAtual {
    switch (_categoria) {
      case _CategoriaMapa.locais:
        return _locaisFiltrados.length;
      case _CategoriaMapa.eventos:
        return _eventosFiltrados.length;
      case _CategoriaMapa.pontosInteresse:
        return _pontosFiltrados.length;
    }
  }

  String get _tituloCategoria {
    switch (_categoria) {
      case _CategoriaMapa.locais:
        return 'LOCAIS';
      case _CategoriaMapa.eventos:
        return 'EVENTOS';
      case _CategoriaMapa.pontosInteresse:
        return 'PONTOS DE INTERESSE';
    }
  }

  String get _descricaoQuantidade {
    final quantidade = _quantidadeAtual;

    switch (_categoria) {
      case _CategoriaMapa.locais:
        return '$quantidade ${quantidade == 1 ? 'local disponível' : 'locais disponíveis'} para explorar';
      case _CategoriaMapa.eventos:
        return '$quantidade ${quantidade == 1 ? 'evento disponível' : 'eventos disponíveis'}';
      case _CategoriaMapa.pontosInteresse:
        return '$quantidade ${quantidade == 1 ? 'ponto de interesse disponível' : 'pontos de interesse disponíveis'}';
    }
  }

  String get _tituloFiltro {
    switch (_categoria) {
      case _CategoriaMapa.locais:
        return 'Filtrar locais';
      case _CategoriaMapa.eventos:
        return 'Filtrar eventos';
      case _CategoriaMapa.pontosInteresse:
        return 'Filtrar pontos de interesse';
    }
  }

  String get _hintPesquisa {
    switch (_categoria) {
      case _CategoriaMapa.locais:
        return 'Pesquisar local pelo nome...';
      case _CategoriaMapa.eventos:
        return 'Pesquisar evento pelo nome...';
      case _CategoriaMapa.pontosInteresse:
        return 'Pesquisar ponto de interesse pelo nome...';
    }
  }

  String get _textoNenhumResultado {
    switch (_categoria) {
      case _CategoriaMapa.locais:
        return 'Nenhum local encontrado';
      case _CategoriaMapa.eventos:
        return 'Nenhum evento encontrado';
      case _CategoriaMapa.pontosInteresse:
        return 'Nenhum ponto de interesse encontrado';
    }
  }

  IconData get _iconeCategoria {
    switch (_categoria) {
      case _CategoriaMapa.locais:
        return Icons.location_on_rounded;
      case _CategoriaMapa.eventos:
        return Icons.warning_amber_rounded;
      case _CategoriaMapa.pontosInteresse:
        return Icons.place_outlined;
    }
  }

  Color get _corCategoria {
    switch (_categoria) {
      case _CategoriaMapa.locais:
        return const Color(0xFF1976D2);
      case _CategoriaMapa.eventos:
        return const Color(0xFFE07A32);
      case _CategoriaMapa.pontosInteresse:
        return const Color(0xFF7856A8);
    }
  }

  String get _textoAdicionar {
    switch (_categoria) {
      case _CategoriaMapa.locais:
        return 'Novo Local';
      case _CategoriaMapa.eventos:
        return 'Novo Evento';
      case _CategoriaMapa.pontosInteresse:
        return 'Novo Ponto';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        actions: [

        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _corCategoria,
        foregroundColor: Colors.white,
        onPressed: _adicionarAtual,
        icon: const Icon(Icons.add),
        label: Text(_textoAdicionar),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final desktop = constraints.maxWidth >= 850;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            desktop ? 36 : 16,
            24,
            desktop ? 36 : 16,
            100,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1180,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(
                    context,
                    desktop,
                  ),
                  const SizedBox(height: 20),
                  _buildCategoriaSelector(),
                  const SizedBox(height: 22),
                  _buildFiltros(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context),
                  const SizedBox(height: 14),
                  _buildConteudo(
                    context,
                    desktop,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool desktop,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        desktop ? 28 : 20,
      ),
      decoration: BoxDecoration(
        color: _corCategoria,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _corCategoria == const Color(0xFF1976D2)
              ? const Color(0xFF0D4F96)
              : _corCategoria.withValues(
                  alpha: 0.75,
                ),
          width: 3,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: desktop ? 82 : 68,
            height: desktop ? 82 : 68,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD600),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFB88600),
                width: 3,
              ),
            ),
            child: Icon(
              _iconeCategoria,
              color: const Color(0xFF173E73),
              size: 42,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD600),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'EXPLORAÇÁO',
                    style: TextStyle(
                      color: Color(0xFF173E73),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  _categoria == _CategoriaMapa.locais
                      ? 'MAPA DA AVENTURA'
                      : _tituloCategoria,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  _descricaoQuantidade,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD8DDE6),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCategoriaButton(
              categoria: _CategoriaMapa.locais,
              icon: Icons.location_on_rounded,
              label: 'Locais',
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildCategoriaButton(
              categoria: _CategoriaMapa.eventos,
              icon: Icons.warning_amber_rounded,
              label: 'Eventos',
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildCategoriaButton(
              categoria: _CategoriaMapa.pontosInteresse,
              icon: Icons.place_outlined,
              label: 'Pontos de Interesse',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaButton({
    required _CategoriaMapa categoria,
    required IconData icon,
    required String label,
  }) {
    final selecionado = _categoria == categoria;

    Color cor;

    switch (categoria) {
      case _CategoriaMapa.locais:
        cor = const Color(0xFF1976D2);
        break;
      case _CategoriaMapa.eventos:
        cor = const Color(0xFFE07A32);
        break;
      case _CategoriaMapa.pontosInteresse:
        cor = const Color(0xFF7856A8);
        break;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _categoria = categoria;
            _pesquisaController.clear();
            _regiaoSelecionada = 'Todas';
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: selecionado ? cor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selecionado ? Colors.white : cor,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selecionado ? Colors.white : const Color(0xFF343A40),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltros(
    BuildContext context,
  ) {
    final tema = Theme.of(context);

    final temFiltro = _pesquisa.isNotEmpty || _regiaoSelecionada != 'Todas';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tituloFiltro,
          style: tema.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _pesquisaController,
          decoration: InputDecoration(
            hintText: _hintPesquisa,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _pesquisaController.text.isNotEmpty
                ? IconButton(
                    tooltip: 'Limpar pesquisa',
                    onPressed: () {
                      _pesquisaController.clear();
                    },
                    icon: const Icon(
                      Icons.clear,
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _regiaoSelecionada,
          decoration: InputDecoration(
            labelText: 'Região',
            prefixIcon: const Icon(Icons.public),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: _regioes
              .map(
                (regiao) => DropdownMenuItem<String>(
                  value: regiao,
                  child: Text(
                    regiao,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (valor) {
            if (valor == null) {
              return;
            }

            setState(() {
              _regiaoSelecionada = valor;
            });
          },
        ),
        if (temFiltro) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.filter_alt_outlined,
                size: 16,
                color: _corCategoria,
              ),
              const SizedBox(width: 6),
              Text(
                '$_quantidadeAtual ${_quantidadeAtual == 1 ? 'resultado' : 'resultados'}',
                style: tema.textTheme.bodySmall?.copyWith(
                  color: _corCategoria,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
  ) {
    final quantidade = _quantidadeAtual;

    return Row(
      children: [
        Container(
          width: 11,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD600),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _tituloCategoria,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
              ),
              Text(
                '$quantidade ${quantidade == 1 ? 'resultado encontrado' : 'resultados encontrados'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF5F6368),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConteudo(
    BuildContext context,
    bool desktop,
  ) {
    if (_quantidadeAtual == 0) {
      return _buildNoResultsState();
    }

    switch (_categoria) {
      case _CategoriaMapa.locais:
        final locais = _locaisFiltrados;

        return desktop
            ? _buildDesktopLocations(
                context,
                locais,
              )
            : _buildMobileLocations(
                context,
                locais,
              );

      case _CategoriaMapa.eventos:
        final eventos = _eventosFiltrados;

        return desktop
            ? _buildDesktopEventos(
                context,
                eventos,
              )
            : _buildMobileEventos(
                context,
                eventos,
              );

      case _CategoriaMapa.pontosInteresse:
        final pontos = _pontosFiltrados;

        return desktop
            ? _buildDesktopPontos(
                context,
                pontos,
              )
            : _buildMobilePontos(
                context,
                pontos,
              );
    }
  }

  Widget _buildDesktopLocations(
    BuildContext context,
    List<Local> locais,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 470,
        mainAxisExtent: 150,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: locais.length,
      itemBuilder: (context, index) {
        return _buildLocationCard(
          context,
          locais[index],
          index,
        );
      },
    );
  }

  Widget _buildMobileLocations(
    BuildContext context,
    List<Local> locais,
  ) {
    return Column(
      children: [
        for (int index = 0; index < locais.length; index++) ...[
          _buildLocationCard(
            context,
            locais[index],
            index,
          ),
          if (index < locais.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildLocationCard(
    BuildContext context,
    Local local,
    int index,
  ) {
    final color = _colorForIndex(index);

    return _buildBaseCard(
      color: color,
      icon: Icons.location_on_rounded,
      child: Row(
        children: [
          _buildIconBox(
            color,
            Icons.location_on_rounded,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildLocationInformation(
              context,
              local,
              color,
            ),
          ),
          IconButton(
            tooltip: 'Editar local',
            onPressed: () => _editarLocal(local),
            icon: Icon(
              Icons.edit_outlined,
              color: color,
            ),
          ),
          Icon(
            Icons.arrow_forward_rounded,
            color: color,
            size: 27,
          ),
        ],
      ),
      onTap: () async {
        final resultado = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => LocalScreen(
              local: local,
            ),
          ),
        );

        if (resultado == true && mounted) {
          await _carregarDados();
        }
      },
    );
  }

  Widget _buildLocationInformation(
    BuildContext context,
    Local local,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          local.nome.isEmpty ? 'Local sem nome' : local.nome,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                height: 1.1,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          local.regiaoId.isEmpty ? 'Sem região' : local.regiaoId,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopEventos(
    BuildContext context,
    List<_EventoMapa> eventos,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 470,
        mainAxisExtent: 185,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: eventos.length,
      itemBuilder: (context, index) {
        return _buildEventoCard(
          context,
          eventos[index],
        );
      },
    );
  }

  Widget _buildMobileEventos(
    BuildContext context,
    List<_EventoMapa> eventos,
  ) {
    return Column(
      children: [
        for (int index = 0; index < eventos.length; index++) ...[
          _buildEventoCard(
            context,
            eventos[index],
          ),
          if (index < eventos.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildEventoCard(
    BuildContext context,
    _EventoMapa item,
  ) {
    const color = Color(0xFFE07A32);

    return _buildBaseCard(
      color: color,
      icon: Icons.warning_amber_rounded,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconBox(
            color,
            Icons.warning_amber_rounded,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.evento.nome.isEmpty
                      ? 'Evento sem nome'
                      : item.evento.nome,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.cadastroBase
                      ? 'Cadastro-base'
                      : (item.ponto == null
                          ? (item.local?.nome ?? 'Sem localização')
                          : '${(item.local?.nome ?? 'Sem localização')} • ${item.ponto!.nome}'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (item.evento.descricao.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    item.evento.descricao,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF5F6368),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Editar evento',
            onPressed: () => _editarEvento(item),
            icon: const Icon(
              Icons.edit_outlined,
              color: color,
            ),
          ),
          const Icon(
            Icons.arrow_forward_rounded,
            color: color,
            size: 25,
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventoScreen(
              evento: item.evento,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopPontos(
    BuildContext context,
    List<_PontoMapa> pontos,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 470,
        mainAxisExtent: 180,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: pontos.length,
      itemBuilder: (context, index) {
        return _buildPontoCard(
          context,
          pontos[index],
        );
      },
    );
  }

  Widget _buildMobilePontos(
    BuildContext context,
    List<_PontoMapa> pontos,
  ) {
    return Column(
      children: [
        for (int index = 0; index < pontos.length; index++) ...[
          _buildPontoCard(
            context,
            pontos[index],
          ),
          if (index < pontos.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildPontoCard(
    BuildContext context,
    _PontoMapa item,
  ) {
    const color = Color(0xFF7856A8);

    final ponto = item.ponto;

    return _buildBaseCard(
      color: color,
      icon: Icons.place_outlined,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconBox(
            color,
            Icons.place_outlined,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ponto.nome.isEmpty ? 'Ponto sem nome' : ponto.nome,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.cadastroBase ? 'Cadastro-base' : item.local?.nome ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (ponto.descricao.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    ponto.descricao,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF5F6368),
                      fontSize: 13,
                    ),
                  ),
                ],
                if (ponto.localizacao.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    ponto.localizacao,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Editar ponto de interesse',
            onPressed: () => _editarPonto(item),
            icon: const Icon(
              Icons.edit_outlined,
              color: color,
            ),
          ),
          const Icon(
            Icons.arrow_forward_rounded,
            color: color,
            size: 25,
          ),
        ],
      ),
      onTap: () async {
        final alterado = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => PontoInteresseScreen(
              localId: item.local?.id ?? '',
              local: item.local,
              ponto: ponto,
            ),
          ),
        );

        if (alterado == true && mounted) {
          await _carregarDados();
        }
      },
    );
  }

  Widget _buildBaseCard({
    required Color color,
    required IconData icon,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(
                alpha: 0.35,
              ),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.07,
                ),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildIconBox(
    Color color,
    IconData icon,
  ) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 33,
      ),
    );
  }

  Future<void> _adicionarAtual() async {
    switch (_categoria) {
      case _CategoriaMapa.locais:
        await _adicionarLocal();
        break;
      case _CategoriaMapa.eventos:
        await _adicionarEvento();
        break;
      case _CategoriaMapa.pontosInteresse:
        await _adicionarPonto();
        break;
    }
  }

  Future<void> _adicionarLocal() async {
    final agora = DateTime.now().microsecondsSinceEpoch;

    final local = Local.fromMap({
      'id': agora.toString(),
      'regiaoId': '',
      'nome': '',
      'descricao': '',
      'leguas': 0,
      'terreno': '',
      'nivelMinCriatura': 1,
      'nivelMaxCriatura': 100,
      'dadoEncontro': '',
      'dadoEncontroDiurno': '',
      'dadoEncontroNoturno': '',
      'dadoEncontroPesca': '',
      'dadoEncontroSurfe': '',
      'dadoEventos': '',
      'encontros': {
        'id': agora.toString(),
        'nome': '',
        'diurno': [],
        'noturno': [],
        'pesca': [],
        'surfe': [],
      },
      'treinadores': {
        'diurno': [],
        'noturno': [],
        'pesca': [],
        'surfe': [],
      },
      'rockets': {
        'diurno': [],
        'noturno': [],
        'pesca': [],
        'surfe': [],
      },
      'pontosInteresse': [],
      'eventos': [],
      'conexoes': [],
    });

    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => LocalEditScreen(
          local: local,
        ),
      ),
    );

    if (resultado == true && mounted) {
      await _carregarDados();
    }
  }

  Future<void> _adicionarEvento() async {
    final evento = await Navigator.push<Evento>(
      context,
      MaterialPageRoute(
        builder: (_) => const EventoEditScreen(),
      ),
    );

    if (evento == null) {
      return;
    }

    await CadastrosRepository().salvarEvento(evento);

    if (mounted) {
      await _carregarDados();
    }
  }

  Future<void> _adicionarPonto() async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    final ponto = await Navigator.push<PontoInteresse>(
      context,
      MaterialPageRoute(
        builder: (_) => PontoInteresseEditScreen(
          ponto: PontoInteresse(
            id: id,
            nome: '',
            descricao: '',
            localizacao: '',
          ),
        ),
      ),
    );

    if (ponto == null) {
      return;
    }

    await CadastrosRepository().salvarPonto(ponto);

    if (mounted) {
      await _carregarDados();
    }
  }

  Future<void> _editarLocal(
    Local local,
  ) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => LocalEditScreen(
          local: local,
        ),
      ),
    );

    if (resultado == true && mounted) {
      await _carregarDados();
    }
  }

  Future<void> _editarEvento(
    _EventoMapa item,
  ) async {
    final resultado = await Navigator.push<Evento>(
      context,
      MaterialPageRoute(
        builder: (_) => EventoEditScreen(
          evento: item.evento,
        ),
      ),
    );

    if (resultado == null) {
      return;
    }

    if (item.cadastroBase) {
      await CadastrosRepository().salvarEvento(
        resultado,
      );
    } else if (item.local != null) {
      if (item.ponto == null) {
        await _repository.salvarEventoDoLocal(
          item.local!.id,
          resultado,
        );
      } else {
        await _repository.salvarEventoDoPonto(
          item.local!.id,
          item.ponto!.id,
          resultado,
        );
      }
    }

    if (mounted) {
      await _carregarDados();
    }
  }

  Future<void> _editarPonto(
    _PontoMapa item,
  ) async {
    final resultado = await Navigator.push<PontoInteresse>(
      context,
      MaterialPageRoute(
        builder: (_) => PontoInteresseEditScreen(
          ponto: item.ponto,
        ),
      ),
    );

    if (resultado == null) {
      return;
    }

    if (item.cadastroBase) {
      await CadastrosRepository().salvarPonto(
        resultado,
      );
    } else if (item.local != null) {
      await _repository.salvarPontoInteresse(
        item.local!.id,
        resultado,
      );
    }

    if (mounted) {
      await _carregarDados();
    }
  }

  Color _colorForIndex(
    int index,
  ) {
    const colors = [
      Color(0xFF1976D2),
      Color(0xFF00897B),
      Color(0xFFE53935),
      Color(0xFF8E44AD),
      Color(0xFFF57C00),
      Color(0xFF43A047),
    ];

    return colors[index % colors.length];
  }

  Widget _buildNoResultsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFB8C7DD),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: _corCategoria,
          ),
          const SizedBox(height: 12),
          Text(
            _textoNenhumResultado,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Tente outro nome ou selecione outra região.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF5F6368),
            ),
          ),
        ],
      ),
    );
  }
}
