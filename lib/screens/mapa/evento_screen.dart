import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/evento.dart';
import '../../models/local.dart';
import '../../models/ponto_interesse.dart';
import '../../repositories/locais_repository.dart';
import 'local_screen.dart';
import 'ponto_interesse_screen.dart';
import '../itens/item_detalhe_screen.dart';
import '../../models/npc.dart';
import '../../repositories/npcs_repository.dart';
import '../npcs/npc_screen.dart';
import 'evento_edit_screen.dart';
import '../bestiario/criatura_detalhe_screen.dart';

class _EventoRegistros extends StatefulWidget {
  final Evento evento;
  final List<NPC> aliados;
  final List<NPC> inimigos;
  final String nomeCriatura;
  final String nomeAliados;
  final String nomeInimigos;
  final VoidCallback aoAbrirCriatura;

  const _EventoRegistros({
    required this.evento,
    required this.aliados,
    required this.inimigos,
    required this.nomeCriatura,
    required this.nomeAliados,
    required this.nomeInimigos,
    required this.aoAbrirCriatura,
  });

  @override
  State<_EventoRegistros> createState() => _EventoRegistrosState();
}

class _EventoRegistrosState extends State<_EventoRegistros> {
  String? _selecionado;

  static const Color _card = Colors.white;
  static const Color _borda = Color(0xFFD8D3C7);
  static const Color _vermelho = Color(0xFFD64545);
  static const Color _texto = Color(0xFF252525);

  Widget _botao(String chave, String titulo) {
    final ativo = _selecionado == chave;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              _selecionado = ativo ? null : chave;
            });
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: ativo ? _vermelho : _card,
            foregroundColor: ativo ? Colors.white : _texto,
            side: BorderSide(color: ativo ? _vermelho : _borda),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _cartaoPersonagens(List<NPC> personagens) {
    if (personagens.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('Nenhum registro deste tipo no evento.'),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: personagens.map((personagem) {
        return SizedBox(
          width: 104,
          height: 104,
          child: Card(
            color: _card,
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NPCScreen(npcId: personagem.id),
                  ),
                );
              },
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    personagem.nome,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _texto,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _conteudoSelecionado() {
    switch (_selecionado) {
      case 'criatura':
        final criatura = widget.evento.criatura;
        if (criatura == null) {
          return const Text('Nenhuma criatura neste evento.');
        }

        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 104,
            height: 104,
            child: Card(
              color: _card,
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.aoAbrirCriatura,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      criatura.nome,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _texto,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      case 'aliado':
        return _cartaoPersonagens(widget.aliados);
      case 'inimigo':
        return _cartaoPersonagens(widget.inimigos);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _botao('criatura', widget.nomeCriatura),
            _botao('aliado', widget.nomeAliados),
            _botao('inimigo', widget.nomeInimigos),
          ],
        ),
        if (_selecionado != null) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _borda),
            ),
            child: _conteudoSelecionado(),
          ),
        ],
        const SizedBox(height: 10),
      ],
    );
  }
}

class EventoScreen extends ConsumerWidget {
  final Evento evento;

  const EventoScreen({
    super.key,
    required this.evento,
  });

  static const Color _fundo = Color(0xFFF4F1E8);
  static const Color _card = Colors.white;
  static const Color _borda = Color(0xFFD8D3C7);

  static const Color _vermelho = Color(0xFFD64545);
  static const Color _azul = Color(0xFF3D73C9);
  static const Color _amarelo = Color(0xFFE3B341);
  static const Color _verde = Color(0xFF4D9A5F);
  static const Color _laranja = Color(0xFFE07A32);

  static const Color _texto = Color(0xFF252525);
  static const Color _textoSecundario = Color(0xFF66625B);

  Widget _campo({
    required IconData icone,
    required String titulo,
    required String valor,
    required Color cor,
  }) {
    if (valor.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borda),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cor.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icone,
              color: cor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (titulo.isNotEmpty) ...[
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _textoSecundario,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.35,
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

  Widget _secaoTitulo(
    String titulo,
    IconData icone,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        bottom: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _vermelho.withAlpha(22),
              borderRadius: BorderRadius.circular(9),
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
              fontSize: 19,
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

  List<Widget> _localizacoesDoEvento(
    List<dynamic> locais,
    BuildContext context,
  ) {
    final resultado = <Widget>[];

    bool corresponde(dynamic valor) {
      if (valor is! Map) return false;
      final id = valor['id']?.toString();
      final baseId = valor['cadastroBaseId']?.toString();

      return id == evento.id ||
          (evento.cadastroBaseId != null &&
              (id == evento.cadastroBaseId ||
                  baseId == evento.cadastroBaseId)) ||
          (evento.cadastroBaseId == null && baseId == evento.id);
    }

    Widget link(String texto, VoidCallback aoClicar) {
      return InkWell(
        onTap: aoClicar,
        child: Text(
          texto,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    for (final item in locais) {
      if (item is! Local) continue;

      final mapa = item.toMap();
      final eventos = mapa['eventos'];

      if (eventos is List && eventos.any(corresponde)) {
        resultado.add(
          Wrap(
            children: [
              const Text('Local: '),
              link(
                item.nome,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => LocalScreen(local: item),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }

      final pontos = mapa['pontosInteresse'];
      if (pontos is List) {
        for (final pontoMapa in pontos) {
          if (pontoMapa is! Map) continue;

          final eventosPonto = pontoMapa['eventos'];
          if (eventosPonto is! List || !eventosPonto.any(corresponde)) {
            continue;
          }

          final idPonto = pontoMapa['id']?.toString();
          PontoInteresse? pontoEncontrado;

          for (final ponto in item.pontosInteresse) {
            if (ponto.id == idPonto) {
              pontoEncontrado = ponto;
              break;
            }
          }

          if (pontoEncontrado == null) continue;

          resultado.add(
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Ponto de Interesse: '),
                link(
                  pontoEncontrado.nome,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => PontoInteresseScreen(
                          localId: item.id,
                          local: item,
                          ponto: pontoEncontrado!,
                        ),
                      ),
                    );
                  },
                ),
                const Text(' (Local: '),
                link(
                  item.nome,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => LocalScreen(local: item),
                      ),
                    );
                  },
                ),
                const Text(')'),
              ],
            ),
          );
        }
      }
    }

    return resultado;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Object>>(
      future: Future.wait<Object>([
        NPCsRepository().carregar(),
        SharedPreferences.getInstance(),
        LocaisRepository().carregar(),
      ]),
      builder: (context, snapshot) {
        final dados = snapshot.data;
        final personagens =
            dados == null ? const <NPC>[] : dados[0] as List<NPC>;
        final prefs = dados == null ? null : dados[1] as SharedPreferences;
        final localizacoes = dados == null
            ? const <Widget>[]
            : _localizacoesDoEvento(
                dados[2] as List<dynamic>,
                context,
              );

        final configuradoAliados = prefs?.getString('menu_aliados')?.trim();
        final configuradoInimigos = prefs?.getString('menu_inimigos')?.trim();
        final configuradoCriatura = prefs?.getString('nome_criatura')?.trim();

        final nomeAliados = configuradoAliados?.isNotEmpty == true
            ? configuradoAliados!
            : 'Aliados';
        final nomeInimigos = configuradoInimigos?.isNotEmpty == true
            ? configuradoInimigos!
            : 'Inimigos';
        final nomeCriatura = configuradoCriatura?.isNotEmpty == true
            ? configuradoCriatura!
            : 'Criatura';

        final aliadosVisiveis =
            personagens.where((p) => evento.aliados.contains(p.id)).toList();
        final inimigosVisiveis =
            personagens.where((p) => evento.inimigos.contains(p.id)).toList();

        final temRegistros = aliadosVisiveis.isNotEmpty ||
            inimigosVisiveis.isNotEmpty ||
            evento.criatura != null;

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
            ),
          ),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                evento.nome,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              actions: [
                IconButton(
                  tooltip: 'Editar evento',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    final alterado = await Navigator.push<Evento>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventoEditScreen(evento: evento),
                      ),
                    );
                    if (!context.mounted || alterado == null) return;
                    Navigator.pop(context, alterado);
                  },
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                Container(
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
                              color: _laranja,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.white,
                              size: 29,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              evento.nome,
                              style: const TextStyle(
                                fontSize: 27,
                                color: _texto,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (evento.descricao.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.only(left: 13),
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(color: _amarelo, width: 4),
                            ),
                          ),
                          child: Text(
                            evento.descricao,
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
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _campo(
                        icone: Icons.schedule,
                        titulo: 'INÍCIO',
                        valor: evento.inicio,
                        cor: _azul,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _campo(
                        icone: Icons.timelapse,
                        titulo: 'DURAÇÁO',
                        valor: evento.duracao,
                        cor: _verde,
                      ),
                    ),
                  ],
                ),
                if (evento.efeito.isNotEmpty) ...[
                  _secaoTitulo('Efeito', Icons.auto_awesome),
                  _campo(
                    icone: Icons.auto_awesome,
                    titulo: '',
                    valor: evento.efeito,
                    cor: _amarelo,
                  ),
                ],
                if (temRegistros) ...[
                  _secaoTitulo('Encontros', Icons.groups_outlined),
                  _EventoRegistros(
                    evento: evento,
                    aliados: aliadosVisiveis,
                    inimigos: inimigosVisiveis,
                    nomeCriatura: nomeCriatura,
                    nomeAliados: nomeAliados,
                    nomeInimigos: nomeInimigos,
                    aoAbrirCriatura: () {
                      final criatura = evento.criatura;
                      if (criatura == null) return;

                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => CriaturaDetalheScreen(
                            criatura: criatura,
                            nivelAlteravel: true,
                            origem: OrigemCriatura.selvagem,
                          ),
                        ),
                      );
                    },
                  ),
                ],
                if (evento.itens.isNotEmpty) ...[
                  _secaoTitulo('Itens', Icons.inventory_2_outlined),
                  ...evento.itens.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFD8D3C7)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            ItemDetalheScreen(item: item),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    item.nome,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                if (item.descricao.trim().isNotEmpty) ...[
                                  const SizedBox(height: 5),
                                  Text(item.descricao),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F0E8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'x${item.quantidade}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (localizacoes.isNotEmpty) ...[
                  _secaoTitulo('LOCALIZAÇÃO', Icons.place_outlined),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _borda),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < localizacoes.length; i++) ...[
                          if (i > 0) const SizedBox(height: 8),
                          localizacoes[i],
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
