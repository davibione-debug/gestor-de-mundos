import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'personalizar_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/registro.dart';
import '../../repositories/registros_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/encontro.dart';
import '../../models/encontro_npc.dart';
import '../../models/evento.dart';
import '../../models/grupo.dart';
import '../../models/grupo_npc.dart';
import '../../models/item.dart';
import '../../models/local.dart';
import '../../models/npc.dart';
import '../../models/poder.dart';
import '../../models/criatura.dart';
import '../../models/periodo_dia.dart';
import '../../models/ponto_interesse.dart';
import '../../repositories/itens_repository.dart';
import '../../repositories/locais_repository.dart';
import '../../repositories/npcs_repository.dart';
import '../../repositories/criaturas_repository.dart';
import '../../repositories/cadastros_repository.dart';

class AdministracaoScreen extends StatefulWidget {
  const AdministracaoScreen({super.key});

  @override
  State<AdministracaoScreen> createState() => _AdministracaoScreenState();
}

class _AdministracaoScreenState extends State<AdministracaoScreen> {
  final ItensRepository _itensRepository = ItensRepository();
  final NPCsRepository _npcsRepository = NPCsRepository();
  final CriaturasRepository _criaturasRepository = CriaturasRepository();
  final LocaisRepository _locaisRepository = LocaisRepository();

  bool _importando = false;

  String _texto(dynamic valor) {
    if (valor == null) return '';
    return valor.toString().trim();
  }

  String _normalizar(String texto) {
    return texto
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  int _int(dynamic valor, {int padrao = 0}) {
    if (valor == null) return padrao;
    if (valor is int) return valor;
    if (valor is num) return valor.round();
    final texto = valor.toString().trim();
    if (texto.isEmpty) return padrao;
    return double.tryParse(texto.replaceAll(',', '.'))?.round() ?? padrao;
  }

  bool _bool(dynamic valor) {
    final texto = _texto(valor).toLowerCase();
    return texto == 'sim' || texto == 's' || texto == 'true' || texto == '1';
  }

  String _idInterno(String prefixo, String nome) {
    final normalizado = _normalizar(nome);
    if (normalizado.isEmpty) {
      throw Exception('Não foi possível gerar ID para "$nome".');
    }
    return '${prefixo}_$normalizado';
  }

  Map<String, int> _cabecalhos(List<Data?> linha) {
    final resultado = <String, int>{};
    for (int i = 0; i < linha.length; i++) {
      final valor = linha[i]?.value;
      if (valor == null) continue;
      final chave = _normalizar(valor.toString());
      if (chave.isNotEmpty) resultado[chave] = i;
    }
    return resultado;
  }

  String _celula(List<Data?> linha, Map<String, int> cabecalhos, String nome) {
    final chave = _normalizar(nome);
    final indice = cabecalhos[chave];
    if (indice != null && indice < linha.length) {
      return _texto(linha[indice]?.value);
    }
    if (chave == 'moves' && linha.length > 17) {
      return _texto(linha[17]?.value);
    }
    return '';
  }

  String _celulaAlternativa(
      List<Data?> linha, Map<String, int> cabecalhos, List<String> nomes) {
    for (final nome in nomes) {
      final valor = _celula(linha, cabecalhos, nome);
      if (valor.isNotEmpty) return valor;
    }
    return '';
  }

  String _efetividadeTipo(List<Data?> linha, Map<String, int> cabecalhos) {
    final superEfetivo = _celula(linha, cabecalhos, 'Super Efetivo');
    final poucoEfetivo = _celula(linha, cabecalhos, 'Pouco Efetivo');
    final imune = _celula(linha, cabecalhos, 'Imune');
    final partes = <String>[];
    if (superEfetivo.isNotEmpty && superEfetivo != '-')
      partes.add('Super Efetivo: $superEfetivo');
    if (poucoEfetivo.isNotEmpty && poucoEfetivo != '-')
      partes.add('Pouco Efetivo: $poucoEfetivo');
    if (imune.isNotEmpty && imune != '-') partes.add('Imune: $imune');
    if (partes.isEmpty) {
      final antigo = _celula(linha, cabecalhos, 'Efetivo');
      if (antigo.isNotEmpty && antigo != '-') return antigo;
    }
    return partes.join(' | ');
  }

  List<String> _lista(String valor) {
    final texto = valor.trim();
    if (texto.isEmpty || texto == '-') return [];
    final resultado = <String>[];
    final atual = StringBuffer();
    int parenteses = 0;
    for (int i = 0; i < texto.length; i++) {
      final caractere = texto[i];
      if (caractere == '(') {
        parenteses++;
        atual.write(caractere);
        continue;
      }
      if (caractere == ')') {
        if (parenteses > 0) parenteses--;
        atual.write(caractere);
        continue;
      }
      if (caractere == ',' && parenteses == 0) {
        final item = atual.toString().trim();
        if (item.isNotEmpty) resultado.add(item);
        atual.clear();
        continue;
      }
      atual.write(caractere);
    }
    final ultimo = atual.toString().trim();
    if (ultimo.isNotEmpty) resultado.add(ultimo);
    return resultado;
  }

  List<dynamic> _converterConexoes(String valor) {
    final resultado = <dynamic>[];
    for (final item in _lista(valor)) {
      final texto = item.trim();
      if (texto.isEmpty) continue;
      String nomeLocal = texto;
      String direcao = 'Norte';
      int leguas = 0;
      final abreParentese = texto.indexOf('(');
      final fechaParentese = texto.lastIndexOf(')');
      if (abreParentese >= 0 && fechaParentese > abreParentese) {
        nomeLocal = texto.substring(0, abreParentese).trim();
        final dentro =
            texto.substring(abreParentese + 1, fechaParentese).trim();
        final partes = <String>[];
        final buf = StringBuffer();
        int parenteses = 0;
        for (var i = 0; i < dentro.length; i++) {
          final ch = dentro[i];
          if (ch == '(') parenteses++;
          if (ch == ')') parenteses--;
          if (ch == ',' && parenteses == 0) {
            partes.add(buf.toString().trim());
            buf.clear();
            continue;
          }
          buf.write(ch);
        }
        if (buf.toString().trim().isNotEmpty) partes.add(buf.toString().trim());
        for (final parte in partes) {
          final dirEncontrada =
              RegExp(r'^(norte|sul|leste|oeste)$', caseSensitive: false)
                  .firstMatch(parte);
          if (dirEncontrada != null) {
            final d = dirEncontrada.group(1)!.toLowerCase();
            direcao = d[0].toUpperCase() + d.substring(1);
            continue;
          }
          final leguaEncontrada =
              RegExp(r'l[eé]gua[s]?\s*(\d+)', caseSensitive: false)
                  .firstMatch(parte);
          if (leguaEncontrada != null)
            leguas = int.tryParse(leguaEncontrada.group(1)!) ?? 0;
        }
      }
      if (nomeLocal.isEmpty) continue;
      resultado.add(<String, dynamic>{
        'direcao': direcao,
        'leguas': leguas,
        'localId': _idInterno('LOCAL', nomeLocal)
      });
    }
    return resultado;
  }

  String _nomeSemRestricao(String valor) {
    final texto = valor.trim();
    final inicio = texto.indexOf('(');
    if (inicio < 0) return texto;
    return texto.substring(0, inicio).trim();
  }

  String _restricaoTexto(String valor) {
    final texto = valor.trim();
    final inicio = texto.indexOf('(');
    final fim = texto.lastIndexOf(')');
    if (inicio < 0 || fim <= inicio) return '';
    return texto.substring(inicio + 1, fim).trim();
  }

  _RestricaoLocal _extrairRestricao(String valor) {
    final restricao = _restricaoTexto(valor);
    if (restricao.isEmpty) return const _RestricaoLocal();
    PeriodoDia? periodo;
    int? leguaMin;
    int? leguaMax;
    int? nivelFixo;
    final partes = _lista(restricao);
    for (final parte in partes) {
      final texto = parte.trim();
      final periodoEncontrado = _periodoFromString(texto);
      if (periodoEncontrado != null) {
        periodo = periodoEncontrado;
        continue;
      }
      final nivelEncontrado =
          RegExp(r'n[ií]vel\s*(\d+)', caseSensitive: false).firstMatch(texto);
      if (nivelEncontrado != null) {
        nivelFixo = int.tryParse(nivelEncontrado.group(1)!);
        continue;
      }
      final leguaEncontrada = _extrairFaixaLegua(texto);
      if (leguaEncontrada != null) {
        leguaMin = leguaEncontrada.$1;
        leguaMax = leguaEncontrada.$2;
      }
    }
    return _RestricaoLocal(
        periodo: periodo,
        leguaMin: leguaMin,
        leguaMax: leguaMax,
        nivelFixo: nivelFixo);
  }

  (int, int)? _extrairFaixaLegua(String texto) {
    final textoNormalizado =
        texto.toLowerCase().replaceAll('é', 'e').replaceAll('ê', 'e');
    final match = RegExp(r'legua(?:s)?\s*(\d+)\s*(?:[-–—]\s*(\d+))?',
            caseSensitive: false)
        .firstMatch(textoNormalizado);
    if (match == null) return null;
    final minimo = int.tryParse(match.group(1)!);
    if (minimo == null) return null;
    final segundo = match.group(2);
    if (segundo == null || segundo.isEmpty) return (minimo, minimo);
    final maximo = int.tryParse(segundo);
    if (maximo == null) return (minimo, minimo);
    return (minimo, maximo);
  }

  List<Evento> _eventosDaTabelaLocal(String tabela,
      Map<String, Evento> eventosPorNome, int linhaExcel, List<String> erros) {
    final resultado = <Evento>[];
    for (final entrada in _lista(tabela)) {
      var nomeResultado = entrada.trim();
      nomeResultado = nomeResultado
          .replaceFirst(RegExp(r'^\s*\d+\s*(?:[-–—]\s*\d+)?\s+'), '')
          .trim();
      nomeResultado = _nomeSemRestricao(nomeResultado);
      if (nomeResultado.isEmpty) continue;
      final evento = eventosPorNome[_normalizar(nomeResultado)];
      if (evento != null) {
        if (!resultado.any((item) => item.id == evento.id))
          resultado.add(evento);
        continue;
      }
      if (_normalizar(nomeResultado) == 'nada') continue;
      erros.add(
          'LOCAIS linha $linhaExcel: Resultado de evento "$nomeResultado" não encontrado na aba "Eventos".');
    }
    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administração')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _botao(
              context,
              Icons.color_lens,
              'Personalizar Menus',
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PersonalizarScreen()))),
          _botao(
              context,
              Icons.upload_file,
              _importando ? 'Importando...' : 'Importar Dados',
              _importando ? null : _importarDados),
          _botao(context, Icons.download, 'Exportar Dados', _exportarDados),
          _botao(context, Icons.unarchive, 'Importar Registros (.zip)',
              _importarRegistros),
          _botao(context, Icons.archive, 'Exportar Registros (.zip)',
              _exportarRegistros),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          _botao(context, Icons.folder_open, 'Downloads', _abrirDownloads),
        ],
      ),
    );
  }

  Widget _botao(BuildContext context, IconData icone, String texto,
      VoidCallback? onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        height: 60,
        child: ElevatedButton.icon(
            icon: Icon(icone), label: Text(texto), onPressed: onPressed),
      ),
    );
  }

  Future<void> _salvarAsset(
      {required String assetPath,
      required String nomeArquivo,
      required String titulo}) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
      final caminho = await FilePicker.saveFile(
          dialogTitle: titulo, fileName: nomeArquivo, bytes: bytes);
      if (!mounted) return;
      if (caminho == null) {
        _mensagem('Download cancelado.');
        return;
      }
      _mensagem('Arquivo salvo com sucesso.');
    } catch (e) {
      if (!mounted) return;
      _mensagem('Não foi possível salvar o arquivo.', erro: true);
    }
  }

  Future<void> _importarDados() async {
    setState(() {
      _importando = true;
    });
    try {
      final resultado = await FilePicker.pickFiles(
          type: FileType.custom, allowedExtensions: ['xlsx']);
      if (resultado.isEmpty) return;
      final arquivo = resultado.single;
      final bytes = await arquivo.readAsBytes();
      if (bytes.isEmpty)
        throw Exception('Não foi possível ler o arquivo selecionado.');

      final excel = Excel.decodeBytes(bytes);
      final prefsConfiguracao = await SharedPreferences.getInstance();
      final tabelaConfiguracao = excel.tables['Configuração'];

      if (tabelaConfiguracao != null) {
        for (final linhaConfiguracao in tabelaConfiguracao.rows.skip(1)) {
          if (linhaConfiguracao.isEmpty || linhaConfiguracao.length < 2)
            continue;
          final chaveConfiguracao =
              linhaConfiguracao[0]?.value?.toString().trim() ?? '';
          final valorConfiguracao =
              linhaConfiguracao[1]?.value?.toString().trim() ?? '';
          if (chaveConfiguracao.isEmpty) continue;
          switch (chaveConfiguracao) {
            case 'MenuBestiario':
              await prefsConfiguracao.setString('menu_bestiario',
                  valorConfiguracao.isEmpty ? 'Bestiário' : valorConfiguracao);
              break;
            case 'MenuPersonagens':
              await prefsConfiguracao.setString(
                  'menu_personagens',
                  valorConfiguracao.isEmpty
                      ? 'Personagens'
                      : valorConfiguracao);
              break;
            case 'MenuMapa':
              await prefsConfiguracao.setString('menu_mapa',
                  valorConfiguracao.isEmpty ? 'Mapa' : valorConfiguracao);
              break;
            case 'MenuItens':
              await prefsConfiguracao.setString('menu_itens',
                  valorConfiguracao.isEmpty ? 'Itens' : valorConfiguracao);
              break;
            case 'AppTitulo':
              await prefsConfiguracao.setString(
                  'app_titulo',
                  valorConfiguracao.isEmpty
                      ? 'Painel do Mestre'
                      : valorConfiguracao);
              break;
            case 'AppSubtitulo':
              await prefsConfiguracao.setString(
                  'app_subtitulo',
                  valorConfiguracao.isEmpty
                      ? 'Escolha uma ferramenta'
                      : valorConfiguracao);
              break;
            case 'NomeCriatura':
            case 'MenuCriatura':
            case 'MenuCriaturas':
            case 'NomeCriaturas':
            case 'Criaturas':
              await prefsConfiguracao.setString('menu_criaturas',
                  valorConfiguracao.isEmpty ? 'Criaturas' : valorConfiguracao);
              break;
            case 'NomePersonagem':
              await prefsConfiguracao.setString('nome_personagem',
                  valorConfiguracao.isEmpty ? 'Personagem' : valorConfiguracao);
              break;
            case 'MenuAliados':
              await prefsConfiguracao.setString('menu_aliados',
                  valorConfiguracao.isEmpty ? 'Aliados' : valorConfiguracao);
              break;
            case 'MenuInimigos':
              await prefsConfiguracao.setString('menu_inimigos',
                  valorConfiguracao.isEmpty ? 'Inimigos' : valorConfiguracao);
              break;
          }
        }
      }

      final abaConfiguracao = _tabela(excel, 'Configuração');
      if (abaConfiguracao != null && abaConfiguracao.rows.isNotEmpty) {
        final cabConfig = _cabecalhos(abaConfiguracao.rows.first);
        final prefs = await SharedPreferences.getInstance();
        for (final linhaConfig in abaConfiguracao.rows.skip(1)) {
          if (linhaConfig.isEmpty) continue;
          final chave = _normalizar(_celula(linhaConfig, cabConfig, 'Chave'));
          final valor = _celula(linhaConfig, cabConfig, 'Valor').trim();
          if (chave.isEmpty) continue;
          if (chave == _normalizar('MenuBestiario'))
            await prefs.setString(
                'menu_bestiario', valor.isEmpty ? 'Bestiário' : valor);
          else if (chave == _normalizar('MenuPersonagens'))
            await prefs.setString(
                'menu_personagens', valor.isEmpty ? 'Personagens' : valor);
          else if (chave == _normalizar('MenuMapa'))
            await prefs.setString('menu_mapa', valor.isEmpty ? 'Mapa' : valor);
          else if (chave == _normalizar('MenuItens'))
            await prefs.setString(
                'menu_itens', valor.isEmpty ? 'Itens' : valor);
          else if (chave == _normalizar('AppTitulo'))
            await prefs.setString(
                'app_titulo', valor.isEmpty ? 'Painel do Mestre' : valor);
          else if (chave == _normalizar('AppSubtitulo'))
            await prefs.setString('app_subtitulo',
                valor.isEmpty ? 'Escolha uma ferramenta' : valor);
          else if (chave == _normalizar('MenuAliados'))
            await prefs.setString(
                'menu_aliados', valor.isEmpty ? 'Aliados' : valor);
          else if (chave == _normalizar('MenuInimigos'))
            await prefs.setString(
                'menu_inimigos', valor.isEmpty ? 'Inimigos' : valor);
          else if (chave == _normalizar('NomeCriatura') ||
              chave == _normalizar('MenuCriatura') ||
              chave == _normalizar('MenuCriaturas') ||
              chave == _normalizar('NomeCriaturas'))
            await prefs.setString(
                'nome_criatura', valor.isEmpty ? 'Criatura' : valor);
          else if (chave == _normalizar('Criaturas'))
            await prefs.setString(
                'menu_criaturas', valor.isEmpty ? 'Criaturas' : valor);
          else if (chave == _normalizar('NomePersonagem'))
            await prefs.setString(
                'nome_personagem', valor.isEmpty ? 'Personagem' : valor);
        }
      }

      final criaturas = <String, Criatura>{
        for (final c in await _criaturasRepository.carregar()) c.id: c
      };
      final npcs = <String, NPC>{
        for (final n in await _npcsRepository.carregar()) n.id: n
      };
      final itens = <String, Item>{
        for (final i in await _itensRepository.carregar())
          _normalizar(i.nome): i
      };
      final locais = <String, Local>{
        for (final l in await _locaisRepository.carregar()) l.id: l
      };

      // Limpa as listas antigas para garantir que a importação seja exata
      criaturas.clear();
      npcs.clear();
      itens.clear();
      locais.clear();

      final erros = <String>[];
      int qtdCriatura = 0,
          qtdNPC = 0,
          qtdItem = 0,
          qtdLocal = 0,
          qtdPOI = 0,
          qtdEvento = 0;

      // 1. IMPORTAR ITENS PRIMEIRO
      final abaItens = _tabela(excel, 'Itens');
      if (abaItens != null && abaItens.rows.isNotEmpty) {
        final cab = _cabecalhos(abaItens.rows.first);
        for (int i = 1; i < abaItens.rows.length; i++) {
          final linha = abaItens.rows[i];
          if (_linhaVazia(linha)) continue;
          try {
            final nome = _celula(linha, cab, 'Nome');
            if (nome.isEmpty) throw Exception('Nome vazio.');
            final item = Item(
                nome: nome,
                tipo: _celula(linha, cab, 'Tipo'),
                descricao: _celula(linha, cab, 'Descrição'),
                custoEmCreditos: _int(_celula(linha, cab, 'Preço')),
                efeito: _celula(linha, cab, 'Efeito'),
                localizacao: _celula(linha, cab, 'Localização'));
            itens[_normalizar(nome)] = item;
            qtdItem++;
          } catch (e) {
            erros.add('ITENS linha ${i + 1}: $e');
          }
        }
      }

      // 2. IMPORTAR CRIATURAS
      final abaCriatura = _tabela(excel, 'Criatura');
      if (abaCriatura != null && abaCriatura.rows.isNotEmpty) {
        final cab = _cabecalhos(abaCriatura.rows.first);
        for (int i = 1; i < abaCriatura.rows.length; i++) {
          final linha = abaCriatura.rows[i];
          if (_linhaVazia(linha)) continue;
          try {
            final nome = _celula(linha, cab, 'Nome');
            if (nome.isEmpty) throw Exception('Nome vazio.');
            final itemComum = itens[_normalizar(
                _nomeSemRestricao(_celula(linha, cab, 'Item Comum')))];
            final itemRaro = itens[_normalizar(
                _nomeSemRestricao(_celula(linha, cab, 'Item Raro')))];
            final criatura = Criatura(
              id: _idInterno('POKE', nome),
              numero: _int(_celula(linha, cab, 'Número')),
              nome: nome,
              descricao: _celula(linha, cab, 'Descrição'),
              nivel: 1,
              lendario: _bool(_celula(linha, cab, 'Lendário')),
              tipos: [
                if (_celula(linha, cab, 'Tipo 1').isNotEmpty)
                  _celula(linha, cab, 'Tipo 1'),
                if (_celula(linha, cab, 'Tipo 2').isNotEmpty)
                  _celula(linha, cab, 'Tipo 2')
              ],
              superEfetivo: _celula(linha, cab, 'Super Efetivo'),
              poucoEfetivo: _celula(linha, cab, 'Pouco Efetivo'),
              imune: _celula(linha, cab, 'Imune'),
              efetividadeTipo: _efetividadeTipo(linha, cab),
              forca: _int(_celula(linha, cab, 'Força')),
              habilidade: _int(_celula(linha, cab, 'Habilidade')),
              resistencia: _int(_celula(linha, cab, 'Resistência')),
              armadura: _int(_celula(linha, cab, 'Armadura')),
              defesaEspecial: _int(_celula(linha, cab, 'Defesa Especial')),
              poderDeFogo: _int(_celula(linha, cab, 'Poder de Fogo')),
              forcaPlanilha: _celula(linha, cab, 'Força'),
              habilidadePlanilha: _celula(linha, cab, 'Habilidade'),
              resistenciaPlanilha: _celula(linha, cab, 'Resistência'),
              armaduraPlanilha: _celula(linha, cab, 'Armadura'),
              defesaEspecialPlanilha: _celula(linha, cab, 'Defesa Especial'),
              poderDeFogoPlanilha: _celula(linha, cab, 'Poder de Fogo'),
              poderes: _poderes(_celula(linha, cab, 'Poderes')),
              pv: _int(_celula(linha, cab, 'PV')),
              pe: _int(_celula(linha, cab, 'PE')),
              moves: _lista(_celula(linha, cab, 'Moves')),
              localizacao: _celula(linha, cab, 'Localização'),
              itemComum: itemComum,
              itemRaro: itemRaro,
            );
            criaturas[criatura.id] = criatura;
            qtdCriatura++;
          } catch (e) {
            erros.add('Criatura linha ${i + 1}: $e');
          }
        }
      }

      // 3. IMPORTAR NPCs (Agora eles acham os itens)
      final abaNPC = _tabela(excel, 'NPCs');
      if (abaNPC != null && abaNPC.rows.isNotEmpty) {
        final cab = _cabecalhos(abaNPC.rows.first);
        for (int i = 1; i < abaNPC.rows.length; i++) {
          final linha = abaNPC.rows[i];
          if (_linhaVazia(linha)) continue;
          try {
            final nome = _celula(linha, cab, 'Nome');
            if (nome.isEmpty) throw Exception('Nome vazio.');
            // Separa as criaturas dos ajustes
            final criaturasLista = <String>[];
            final fichasLista = <CriaturaTreinador>[];

            for (final itemCriatura
                in _lista(_celula(linha, cab, 'Criatura'))) {
              final nomeCriatura = _nomeSemRestricao(itemCriatura);
              final restricao = _restricaoTexto(itemCriatura);

              if (nomeCriatura.isEmpty) continue;

              criaturasLista.add(nomeCriatura);

              // Busca a criatura base pelo nome normalizado
              Criatura? baseCriatura;
              for (final c in criaturas.values) {
                if (_normalizar(c.nome) == _normalizar(nomeCriatura)) {
                  baseCriatura = c;
                  break;
                }
              }

              // Cria a ficha mesmo que a base nao exista (para nao perder o vinculo)
              final ajustes = <String, int>{};
              final poderesLista = <Poder>[];
              List<String> movesLista = [];
              String? itemEquipadoLista;

              // Extrai os MOVES primeiro (se existirem)
              String? movesStr;
              final matchMoves = RegExp(r'Moves:\s*(.+)$', caseSensitive: false)
                  .firstMatch(restricao);
              if (matchMoves != null) {
                movesStr = matchMoves.group(1)?.trim();
              }

              // Remove os MOVES da string para processar o resto
              final restricaoSemMoves = restricao
                  .replaceAll(
                      RegExp(r'Moves:\s*(.+)$', caseSensitive: false), '')
                  .trim();
              final partes = restricaoSemMoves
                  .split(',')
                  .map((p) => p.trim())
                  .where((p) => p.isNotEmpty);

              for (final parte in partes) {
                final p = parte.trim();
                final lower = p.toLowerCase();

                if (lower.startsWith('nv')) {
                  ajustes['nv'] = int.tryParse(lower.replaceAll('nv', '')) ?? 1;
                } else if (lower.startsWith('f+')) {
                  ajustes['f'] = int.tryParse(lower.replaceAll('f+', '')) ?? 0;
                } else if (lower.startsWith('h+')) {
                  ajustes['h'] = int.tryParse(lower.replaceAll('h+', '')) ?? 0;
                } else if (lower.startsWith('r+')) {
                  ajustes['r'] = int.tryParse(lower.replaceAll('r+', '')) ?? 0;
                } else if (lower.startsWith('a+')) {
                  ajustes['a'] = int.tryParse(lower.replaceAll('a+', '')) ?? 0;
                } else if (lower.startsWith('d+')) {
                  ajustes['d'] = int.tryParse(lower.replaceAll('d+', '')) ?? 0;
                } else if (lower.startsWith('p+')) {
                  ajustes['p'] = int.tryParse(lower.replaceAll('p+', '')) ?? 0;
                } else if (lower.startsWith('item:')) {
                  final nomeItem = p.replaceAll('Item:', '').trim();
                  itemEquipadoLista = itens[_normalizar(nomeItem)]?.nome;
                } else {
                  final partesPoder = p.split(RegExp(r'\s+'));
                  if (partesPoder.length >= 2) {
                    final tipo = partesPoder[0];
                    int valorBase = 1;
                    int bonus = 0;

                    if (partesPoder[1].startsWith('+')) {
                      bonus =
                          int.tryParse(partesPoder[1].replaceAll('+', '')) ?? 0;
                    } else {
                      valorBase = int.tryParse(partesPoder[1]) ?? 1;
                      if (partesPoder.length > 2 &&
                          partesPoder[2].startsWith('+')) {
                        bonus =
                            int.tryParse(partesPoder[2].replaceAll('+', '')) ??
                                0;
                      }
                    }
                    poderesLista.add(Poder(
                        tipo: tipo,
                        valorBase: valorBase,
                        bonus: bonus,
                        original: false));
                  }
                }
              }

              // Processa os MOVES separadamente (se existirem)
              if (movesStr != null && movesStr.isNotEmpty) {
                movesLista = movesStr
                    .split(',')
                    .map((m) {
                      return m
                          .trim()
                          .replaceAll(RegExp(r'\s*\(.*?\)'), '')
                          .trim();
                    })
                    .where((m) => m.isNotEmpty)
                    .toList();
              }

              fichasLista.add(CriaturaTreinador(
                nome: nomeCriatura,
                nivel: ajustes['nv'] ?? 1,
                bonusForca: ajustes['f'] ?? 0,
                bonusHabilidade: ajustes['h'] ?? 0,
                bonusResistencia: ajustes['r'] ?? 0,
                bonusArmadura: ajustes['a'] ?? 0,
                bonusDefesaEspecial: ajustes['d'] ?? 0,
                bonusPoderDeFogo: ajustes['p'] ?? 0,
                poderes: poderesLista,
                itemEquipado: itemEquipadoLista,
                moves: movesLista,
              ));
            }

            final npc = NPC(
              id: _idInterno('NPC', nome),
              nome: nome,
              tipo: _celula(linha, cab, 'Tipo'),
              descricao: _celula(linha, cab, 'Descrição'),
              localizacao: _celula(linha, cab, 'Localização'),
              forca: _int(_celula(linha, cab, 'Força')),
              habilidade: _int(_celula(linha, cab, 'Habilidade')),
              inteligencia: _int(_celula(linha, cab, 'Inteligência')),
              resistencia: _int(_celula(linha, cab, 'Resistência')),
              armadura: _int(_celula(linha, cab, 'Armadura')),
              poderDeFogo: _int(_celula(linha, cab, 'Poder de Fogo')),
              captura: _int(_celula(linha, cab, 'Captura')),
              controle: _int(_celula(linha, cab, 'Controle')),
              compreensao: _int(_celula(linha, cab, 'Compreensão')),
              tratamento: _int(_celula(linha, cab, 'Tratamento')),
              ecologia: _int(_celula(linha, cab, 'Ecologia')),
              kit: _celula(linha, cab, 'Kit'),
              manobras: _celula(linha, cab, 'Manobras'),
              vantagens: _celula(linha, cab, 'Vantagens'),
              desvantagens: _celula(linha, cab, 'Desvantagens'),
              criaturas: criaturasLista,
              fichasCriatura: fichasLista,
              nivelCriatura: '',
              inventario: _celula(linha, cab, 'Inventário'),
              pv: _int(_celula(linha, cab, 'Resistência')) * 5,
              creditos: _int(_celula(linha, cab, 'Créditos')),
              itens:
                  _itensDoInventario(_celula(linha, cab, 'Inventário'), itens),
            );
            npcs[npc.id] = npc;
            qtdNPC++;
          } catch (e) {
            erros.add('NPCs linha ${i + 1}: $e');
          }
        }
      }
      final eventosPorNome = <String, Evento>{};
      final abaEventos = _tabela(excel, 'Eventos');
      if (abaEventos != null && abaEventos.rows.isNotEmpty) {
        final cab = _cabecalhos(abaEventos.rows.first);
        for (int i = 1; i < abaEventos.rows.length; i++) {
          final linha = abaEventos.rows[i];
          if (_linhaVazia(linha)) continue;
          try {
            final nome = _celula(linha, cab, 'Nome');
            if (nome.isEmpty) throw Exception('Nome vazio.');
            final evento = Evento(
              id: _idInterno('EVENTO', nome),
              nome: nome,
              descricao: _celula(linha, cab, 'Descrição'),
              localizacao: _celula(linha, cab, 'Localização'),
              efeito: _celula(linha, cab, 'Efeito'),
              inicio: _celula(linha, cab, 'Início'),
              duracao: _celula(linha, cab, 'Duração'),
              aliados: _nulo(_celula(linha, cab, 'NPC')) == null
                  ? const <String>[]
                  : [_nulo(_celula(linha, cab, 'NPC'))!],
              inimigos: const <String>[],
              criatura: null,
              nivelCriatura: '',
              itens: [
                for (final ref in _lista(_celula(linha, cab, 'Item')))
                  if (itens[_normalizar(_nomeSemRestricao(ref))] != null)
                    itens[_normalizar(_nomeSemRestricao(ref))]!
              ],
            );
            eventosPorNome[_normalizar(nome)] = evento;
            qtdEvento++;
          } catch (e) {
            erros.add('EVENTOS linha ${i + 1}: $e');
          }
        }
      }

      final poisPorNome = <String, PontoInteresse>{};
      final abaPOI = _tabela(excel, 'Pontos de Interesse');
      if (abaPOI != null && abaPOI.rows.isNotEmpty) {
        final cab = _cabecalhos(abaPOI.rows.first);
        for (int i = 1; i < abaPOI.rows.length; i++) {
          final linha = abaPOI.rows[i];
          if (_linhaVazia(linha)) continue;
          try {
            final nome = _celula(linha, cab, 'Nome');
            if (nome.isEmpty) throw Exception('Nome vazio.');
            final listaEventos = <Evento>[];
            for (final ref in _lista(_celula(linha, cab, 'Eventos'))) {
              final ev = eventosPorNome[_normalizar(_nomeSemRestricao(ref))];
              if (ev != null) listaEventos.add(ev);
            }
            final listaNPC = <NPC>[];
            for (final ref in _lista(_celula(linha, cab, 'NPC'))) {
              final npc = npcs[_idInterno('NPC', _nomeSemRestricao(ref))];
              if (npc != null) listaNPC.add(npc);
            }
            final listaCriatura = <Criatura>[];
            for (final ref in _lista(_celula(linha, cab, 'Criatura'))) {
              final c = criaturas[_idInterno('POKE', _nomeSemRestricao(ref))];
              if (c != null) listaCriatura.add(c);
            }
            final listaItens = <Item>[];
            final itensRefs = _lista(_celula(linha, cab, 'Item'));
            final qtds = _lista(_celula(linha, cab, 'Qt'));
            final locs = _lista(_celula(linha, cab, 'Localização do Item'));
            for (var idx = 0; idx < itensRefs.length; idx++) {
              final itemBase =
                  itens[_normalizar(_nomeSemRestricao(itensRefs[idx]))];
              if (itemBase == null) continue;
              final qtd =
                  idx < qtds.length ? (int.tryParse(qtds[idx]) ?? 1) : 1;
              final loc = idx < locs.length ? locs[idx] : '';
              listaItens
                  .add(itemBase.copyWith(quantidade: qtd, localizacao: loc));
            }
            final faixaNivelPonto =
                _extrairFaixaNivel(_celula(linha, cab, 'Faixa de Nível'));
            final encontrosCriaturaPonto = _encontrosCriatura(
                _celula(linha, cab, 'Criatura'), criaturas, null);
            final encontrosNPCPonto =
                _encontrosNPC(_celula(linha, cab, 'NPC'), npcs);
            final poi = PontoInteresse(
              id: _idInterno('POI', nome),
              nome: nome,
              descricao: _celula(linha, cab, 'Descrição'),
              localizacao: _celula(linha, cab, 'Localização'),
              eventos: listaEventos,
              npcs: listaNPC,
              criaturas: listaCriatura,
              nivelCriatura: '',
              itens: listaItens,
              dadoEncontros: _celula(linha, cab, 'Encontro'),
              nivelMinCriatura: faixaNivelPonto.$1,
              nivelMaxCriatura: faixaNivelPonto.$2,
              encontrosCriaturas: Grupo(
                  id: _idInterno('GRUPO_PONTO', nome),
                  nome: nome,
                  diurno: encontrosCriaturaPonto,
                  noturno: const [],
                  pesca: const [],
                  surfe: const []),
              encontrosAliados: GrupoNPC(
                  diurno: encontrosNPCPonto,
                  noturno: const [],
                  pesca: const [],
                  surfe: const []),
            );
            poisPorNome[_normalizar(nome)] = poi;
            qtdPOI++;
          } catch (e) {
            erros.add('PONTOS DE INTERESSE linha ${i + 1}: $e');
          }
        }
      }

      final abaLocais = _tabela(excel, 'Locais');
      if (abaLocais != null && abaLocais.rows.isNotEmpty) {
        final cab = _cabecalhos(abaLocais.rows.first);
        for (int i = 1; i < abaLocais.rows.length; i++) {
          final linha = abaLocais.rows[i];
          if (_linhaVazia(linha)) continue;
          try {
            final nome = _celula(linha, cab, 'Nome');
            if (nome.isEmpty) throw Exception('Nome vazio.');
            final faixaNivel =
                _extrairFaixaNivel(_celula(linha, cab, 'Faixa de Nível'));
            final tabelaEventos = _celula(linha, cab, 'Eventos');
            final eventos = _eventosDaTabelaLocal(
                tabelaEventos, eventosPorNome, i + 1, erros);
            final pontos = <PontoInteresse>[];
            for (final ref
                in _lista(_celula(linha, cab, 'Pontos de Interesse'))) {
              final poi = poisPorNome[_normalizar(_nomeSemRestricao(ref))];
              if (poi != null)
                pontos.add(poi);
              else
                erros.add(
                    'LOCAIS linha ${i + 1}: Ponto de Interesse "${_nomeSemRestricao(ref)}" não encontrado.');
            }
            final local = Local(
              id: _idInterno('LOCAL', nome),
              regiaoId: _celula(linha, cab, 'Região'),
              nome: nome,
              descricao: _celula(linha, cab, 'Descrição'),
              leguas: _int(_celula(linha, cab, 'Léguas')),
              terreno: _celula(linha, cab, 'Terreno'),
              nivelMinCriatura: faixaNivel.$1,
              nivelMaxCriatura: faixaNivel.$2,
              dadoEncontroDiurno: _celula(linha, cab, 'Encontro Diurno'),
              dadoEncontroNoturno: _celula(linha, cab, 'Encontro Noturno'),
              dadoEncontroPesca: _celula(linha, cab, 'Encontro Pesca'),
              dadoEncontroSurfe: _celula(linha, cab, 'Encontro Aquático'),
              dadoEventos: tabelaEventos,
              encontros: Grupo(
                id: _idInterno('GRUPO', nome),
                nome: nome,
                diurno: _encontrosCriatura(
                    _celula(linha, cab, 'Criatura Diurno'), criaturas, null),
                noturno: _encontrosCriatura(
                    _celula(linha, cab, 'Criatura Noturno'), criaturas, null),
                pesca: _encontrosCriatura(
                    _celulaAlternativa(
                        linha, cab, const ['Criatura Pesca', 'Pesca Criatura']),
                    criaturas,
                    null),
                surfe: _encontrosCriatura(
                    _celulaAlternativa(linha, cab,
                        const ['Criatura Aquático', 'Aquático Criatura']),
                    criaturas,
                    null),
              ),
              treinadores: GrupoNPC(
                diurno: _encontrosNPC(_celula(linha, cab, 'NPC Diurno'), npcs),
                noturno:
                    _encontrosNPC(_celula(linha, cab, 'NPC Noturno'), npcs),
                pesca: _encontrosNPC(
                    _celulaAlternativa(
                        linha, cab, const ['NPC Pesca', 'Pesca NPC']),
                    npcs),
                surfe: _encontrosNPC(
                    _celulaAlternativa(
                        linha, cab, const ['NPC Aquático', 'Aquático NPC']),
                    npcs),
              ),
              rockets: GrupoNPC(
                diurno: _encontrosNPC(_celula(linha, cab, 'NPC Diurno'), npcs,
                    somenteRocket: true),
                noturno: _encontrosNPC(_celula(linha, cab, 'NPC Noturno'), npcs,
                    somenteRocket: true),
                pesca: _encontrosNPC(
                    _celulaAlternativa(
                        linha, cab, const ['NPC Pesca', 'Pesca NPC']),
                    npcs,
                    somenteRocket: true),
                surfe: _encontrosNPC(
                    _celulaAlternativa(
                        linha, cab, const ['NPC Aquático', 'Aquático NPC']),
                    npcs,
                    somenteRocket: true),
              ),
              pontosInteresse: pontos,
              eventos: eventos,
              conexoes: _converterConexoes(_celula(linha, cab, 'Conexões')),
            );
            locais[local.id] = local;
            qtdLocal++;
          } catch (e) {
            erros.add('LOCAIS linha ${i + 1}: $e');
          }
        }
      }

      // Limpa e salva os dados corrigidos
      await _criaturasRepository.salvarTodos(criaturas.values.toList());
      await _npcsRepository.salvarTodos(npcs.values.toList());
      await _itensRepository.salvarTodos(itens.values.toList());
      await _locaisRepository.salvarTodos(locais.values.toList());

      final cadastrosRepository = CadastrosRepository();
      for (final evento in eventosPorNome.values) {
        await cadastrosRepository.salvarEvento(evento);
      }
      for (final ponto in poisPorNome.values) {
        await cadastrosRepository.salvarPonto(ponto);
      }

      if (!mounted) return;
      _mostrarResultado(
          criatura: qtdCriatura,
          npc: qtdNPC,
          item: qtdItem,
          local: qtdLocal,
          poi: qtdPOI,
          evento: qtdEvento,
          erros: erros);
    } catch (e) {
      if (!mounted) return;
      _mensagem('Erro durante a importação:\n$e', erro: true);
    } finally {
      if (mounted)
        setState(() {
          _importando = false;
        });
    }
  }

  Future<void> _exportarDados() async {
    setState(() {
      _importando = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final criaturas = await _criaturasRepository.carregar();
      final npcs = await _npcsRepository.carregar();
      final itens = await _itensRepository.carregar();
      final locais = await _locaisRepository.carregar();
      final cadastros = CadastrosRepository();
      final eventos = await cadastros.carregarEventos();
      final pontos = await cadastros.carregarPontos();

      final excel = Excel.createExcel();

      // 1. Configuração
      final configSheet = excel['Configuração'];
      configSheet.appendRow([TextCellValue('Chave'), TextCellValue('Valor')]);
      final configuracoes = <String, String>{
        'AppTitulo': prefs.getString('app_titulo') ?? 'Painel do Mestre',
        'AppSubtitulo':
            prefs.getString('app_subtitulo') ?? 'Escolha uma ferramenta',
        'MenuMapa': prefs.getString('menu_mapa') ?? 'Mapa',
        'MenuBestiario': prefs.getString('menu_bestiario') ?? 'Bestiário',
        'MenuPersonagens': prefs.getString('menu_personagens') ?? 'Personagens',
        'MenuItens': prefs.getString('menu_itens') ?? 'Itens',
        'MenuCriaturas': prefs.getString('menu_criaturas') ?? 'Criatura',
        'MenuAliados': prefs.getString('menu_aliados') ?? 'Aliados',
        'MenuInimigos': prefs.getString('menu_inimigos') ?? 'Inimigos',
        'NomePersonagem': prefs.getString('nome_personagem') ?? 'Personagem',
        'NomeCriatura': prefs.getString('nome_criatura') ?? 'Criatura',
      };
      configuracoes.forEach((k, v) =>
          configSheet.appendRow([TextCellValue(k), TextCellValue(v)]));

      // 2. Itens
      final itensSheet = excel['Itens'];
      itensSheet.appendRow([
        TextCellValue('Nome'),
        TextCellValue('Tipo'),
        TextCellValue('Descrição'),
        TextCellValue('Efeito'),
        TextCellValue('Preço')
      ]);
      for (final i in itens)
        itensSheet.appendRow([
          TextCellValue(i.nome),
          TextCellValue(i.tipo),
          TextCellValue(i.descricao),
          TextCellValue(i.efeito),
          IntCellValue(i.custoEmCreditos)
        ]);

      // 3. Criatura (Sem PV e PE)
      final criaturaSheet = excel['Criatura'];
      criaturaSheet.appendRow([
        TextCellValue('Nome'),
        TextCellValue('Descrição'),
        TextCellValue('Número'),
        TextCellValue('Lendário'),
        TextCellValue('Tipo 1'),
        TextCellValue('Tipo 2'),
        TextCellValue('Força'),
        TextCellValue('Habilidade'),
        TextCellValue('Resistência'),
        TextCellValue('Armadura'),
        TextCellValue('Defesa Especial'),
        TextCellValue('Poder de Fogo'),
        TextCellValue('Super Efetivo'),
        TextCellValue('Pouco Efetivo'),
        TextCellValue('Imune'),
        TextCellValue('Poderes'),
        TextCellValue('Moves'),
        TextCellValue('Item Comum'),
        TextCellValue('Item Raro')
      ]);
      for (final c in criaturas) {
        criaturaSheet.appendRow([
          TextCellValue(c.nome),
          TextCellValue(c.descricao),
          IntCellValue(c.numero ?? 0),
          TextCellValue(c.lendario ? 'Sim' : 'Não'),
          TextCellValue(c.tipos.isNotEmpty ? c.tipos[0] : ''),
          TextCellValue(c.tipos.length > 1 ? c.tipos[1] : ''),
          TextCellValue(c.forcaPlanilha.isNotEmpty
              ? c.forcaPlanilha
              : c.forca.toString()),
          TextCellValue(c.habilidadePlanilha.isNotEmpty
              ? c.habilidadePlanilha
              : c.habilidade.toString()),
          TextCellValue(c.resistenciaPlanilha.isNotEmpty
              ? c.resistenciaPlanilha
              : c.resistencia.toString()),
          TextCellValue(c.armaduraPlanilha.isNotEmpty
              ? c.armaduraPlanilha
              : c.armadura.toString()),
          TextCellValue(c.defesaEspecialPlanilha.isNotEmpty
              ? c.defesaEspecialPlanilha
              : c.defesaEspecial.toString()),
          TextCellValue(c.poderDeFogoPlanilha.isNotEmpty
              ? c.poderDeFogoPlanilha
              : c.poderDeFogo.toString()),
          TextCellValue(c.superEfetivo),
          TextCellValue(c.poucoEfetivo),
          TextCellValue(c.imune),
          TextCellValue(
              c.poderes.map((p) => '${p.tipo} ${p.valorBase}').join(', ')),
          TextCellValue(c.moves.join(', ')),
          TextCellValue(c.itemComum?.nome ?? ''),
          TextCellValue(c.itemRaro?.nome ?? '')
        ]);
      }

      // 4. NPCs (Sem Localização e Faixa de Nível, com Créditos)
      final npcSheet = excel['NPCs'];
      npcSheet.appendRow([
        TextCellValue('Nome'),
        TextCellValue('Tipo'),
        TextCellValue('Descrição'),
        TextCellValue('Força'),
        TextCellValue('Habilidade'),
        TextCellValue('Inteligência'),
        TextCellValue('Resistência'),
        TextCellValue('Armadura'),
        TextCellValue('Poder de Fogo'),
        TextCellValue('Captura'),
        TextCellValue('Controle'),
        TextCellValue('Compreensão'),
        TextCellValue('Tratamento'),
        TextCellValue('Ecologia'),
        TextCellValue('Kit'),
        TextCellValue('Créditos'),
        TextCellValue('Vantagens'),
        TextCellValue('Desvantagens'),
        TextCellValue('Manobras'),
        TextCellValue('Criatura'),
        TextCellValue('Inventário')
      ]);
      for (final n in npcs) {
        npcSheet.appendRow([
          TextCellValue(n.nome),
          TextCellValue(n.tipo),
          TextCellValue(n.descricao),
          IntCellValue(n.forca),
          IntCellValue(n.habilidade),
          IntCellValue(n.inteligencia),
          IntCellValue(n.resistencia),
          IntCellValue(n.armadura),
          IntCellValue(n.poderDeFogo),
          IntCellValue(n.captura),
          IntCellValue(n.controle),
          IntCellValue(n.compreensao),
          IntCellValue(n.tratamento),
          IntCellValue(n.ecologia),
          TextCellValue(n.kit),
          IntCellValue(n.creditos),
          TextCellValue(n.vantagens),
          TextCellValue(n.desvantagens),
          TextCellValue(n.manobras),
          TextCellValue(n.criaturas.map((nome) {
            final ficha = n.fichasCriatura.firstWhere(
              (f) => f.nome.toLowerCase() == nome.toLowerCase(),
              orElse: () => CriaturaTreinador(nome: nome, nivel: 1),
            );
            final ajustes = <String>[];
            if (ficha.nivel != 1) ajustes.add('Nv${ficha.nivel}');
            if (ficha.bonusForca > 0) ajustes.add('F+${ficha.bonusForca}');
            if (ficha.bonusHabilidade > 0)
              ajustes.add('H+${ficha.bonusHabilidade}');
            if (ficha.bonusResistencia > 0)
              ajustes.add('R+${ficha.bonusResistencia}');
            if (ficha.bonusArmadura > 0)
              ajustes.add('A+${ficha.bonusArmadura}');
            if (ficha.bonusDefesaEspecial > 0)
              ajustes.add('D+${ficha.bonusDefesaEspecial}');
            if (ficha.bonusPoderDeFogo > 0)
              ajustes.add('P+${ficha.bonusPoderDeFogo}');
            for (final poder in ficha.poderes) {
              if (poder.original) {
                if (poder.bonus > 0)
                  ajustes.add('${poder.tipo} +${poder.bonus}');
              } else {
                if (poder.bonus > 0) {
                  ajustes
                      .add('${poder.tipo} ${poder.valorBase} +${poder.bonus}');
                } else {
                  ajustes.add('${poder.tipo} ${poder.valorBase}');
                }
              }
            }
            if (ficha.itemEquipado != null)
              ajustes.add('Item: ${ficha.itemEquipado}');
            if (ficha.moves.isNotEmpty)
              ajustes.add('Moves: ${ficha.moves.join(', ')}');
            if (ajustes.isEmpty) return nome;
            return '${nome} (${ajustes.join(', ')})';
          }).join(', ')),
          TextCellValue(
              n.itens.map((i) => '${i.nome} x${i.quantidade}').join(', '))
        ]);
      }

      // 5. Locais
      final localSheet = excel['Locais'];
      localSheet.appendRow([
        TextCellValue('Nome'),
        TextCellValue('Região'),
        TextCellValue('Descrição'),
        TextCellValue('Léguas'),
        TextCellValue('Terreno'),
        TextCellValue('Eventos'),
        TextCellValue('Pontos de Interesse'),
        TextCellValue('Faixa de Nível'),
        TextCellValue('Encontro Diurno'),
        TextCellValue('Criatura Diurno'),
        TextCellValue('NPC Diurno'),
        TextCellValue('Encontro Noturno'),
        TextCellValue('Criatura Noturno'),
        TextCellValue('NPC Noturno'),
        TextCellValue('Pesca'),
        TextCellValue('Aquático'),
        TextCellValue('Conexões')
      ]);
      for (final l in locais) {
        localSheet.appendRow([
          TextCellValue(l.nome),
          TextCellValue(l.regiaoId),
          TextCellValue(l.descricao),
          IntCellValue(l.leguas),
          TextCellValue(l.terreno),
          TextCellValue(l.dadoEventos),
          TextCellValue(l.pontosInteresse.map((p) => p.nome).join(', ')),
          TextCellValue('${l.nivelMinCriatura}-${l.nivelMaxCriatura}'),
          TextCellValue(l.dadoEncontroDiurno),
          TextCellValue(
              l.encontros.diurno.map((e) => e.criatura.nome).join(', ')),
          TextCellValue(l.treinadores.diurno.map((e) => e.npc.nome).join(', ')),
          TextCellValue(l.dadoEncontroNoturno),
          TextCellValue(
              l.encontros.noturno.map((e) => e.criatura.nome).join(', ')),
          TextCellValue(
              l.treinadores.noturno.map((e) => e.npc.nome).join(', ')),
          TextCellValue(l.dadoEncontroPesca),
          TextCellValue(l.dadoEncontroSurfe),
          TextCellValue(l.conexoes
              .map((c) => c is Map
                  ? '${c['localId']} (${c['direcao']}, Légua ${c['leguas']})'
                  : '')
              .join(', '))
        ]);
      }

      // 6. Eventos
      final eventoSheet = excel['Eventos'];
      eventoSheet.appendRow([
        TextCellValue('Nome'),
        TextCellValue('Descrição'),
        TextCellValue('Efeito'),
        TextCellValue('Início'),
        TextCellValue('Fim'),
        TextCellValue('NPC'),
        TextCellValue('Criatura'),
        TextCellValue('Faixa de Nível'),
        TextCellValue('Item')
      ]);
      for (final e in eventos) {
        eventoSheet.appendRow([
          TextCellValue(e.nome),
          TextCellValue(e.descricao),
          TextCellValue(e.efeito),
          TextCellValue(e.inicio),
          TextCellValue(e.duracao),
          TextCellValue(e.aliados.join(', ')),
          TextCellValue(e.criatura?.nome ?? ''),
          TextCellValue(e.nivelCriatura),
          TextCellValue(e.itens.map((i) => i.nome).join(', '))
        ]);
      }

      // 7. Pontos de Interesse
      final poiSheet = excel['Pontos de Interesse'];
      poiSheet.appendRow([
        TextCellValue('Nome'),
        TextCellValue('Descrição'),
        TextCellValue('Faixa de Nível'),
        TextCellValue('Eventos'),
        TextCellValue('Encontro'),
        TextCellValue('Criatura'),
        TextCellValue('NPC'),
        TextCellValue('Item'),
        TextCellValue('Qt'),
        TextCellValue('Localização do Item')
      ]);
      for (final p in pontos) {
        poiSheet.appendRow([
          TextCellValue(p.nome),
          TextCellValue(p.descricao),
          TextCellValue('${p.nivelMinCriatura}-${p.nivelMaxCriatura}'),
          TextCellValue(p.eventos.map((e) => e.nome).join(', ')),
          TextCellValue(p.dadoEncontros),
          TextCellValue([
            ...p.encontrosCriaturas.diurno,
            ...p.encontrosCriaturas.noturno,
            ...p.encontrosCriaturas.pesca,
            ...p.encontrosCriaturas.surfe
          ].map((e) => e.criatura.nome).join(', ')),
          TextCellValue([
            ...p.encontrosAliados.diurno,
            ...p.encontrosAliados.noturno,
            ...p.encontrosAliados.pesca,
            ...p.encontrosAliados.surfe,
            ...p.encontrosInimigos.diurno,
            ...p.encontrosInimigos.noturno,
            ...p.encontrosInimigos.pesca,
            ...p.encontrosInimigos.surfe
          ].map((e) => e.npc.nome).join(', ')),
          TextCellValue(p.itens.map((i) => i.nome).join(', ')),
          TextCellValue(p.itens.map((i) => i.quantidade.toString()).join(', ')),
          TextCellValue(p.itens.map((i) => i.localizacao).join(', '))
        ]);
      }

      // Remove a aba Sheet1 padrão
      if (excel.tables.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      final bytes = excel.encode();
      if (bytes == null) throw Exception('Falha ao gerar arquivo.');
      final caminho = await FilePicker.saveFile(
          dialogTitle: 'Salvar planilha',
          fileName: 'Gestor_de_Mundo_export.xlsx',
          bytes: Uint8List.fromList(bytes));

      if (!mounted) return;
      if (kIsWeb) {
        _mensagem('Planilha exportada com sucesso.');
        return;
      }
      if (caminho == null) {
        _mensagem('Exportação cancelada.');
        return;
      }
      _mensagem('Planilha exportada com sucesso.');
    } catch (e) {
      if (!mounted) return;
      _mensagem('Erro na exportação: $e', erro: true);
    } finally {
      if (mounted)
        setState(() {
          _importando = false;
        });
    }
  }

  List<Item> _itensDoInventario(String texto, Map<String, Item> itensBase) {
    final resultado = <Item>[];
    for (final entrada in _lista(texto)) {
      final pedaco = entrada.trim();
      if (pedaco.isEmpty) continue;
      int quantidade = 1;
      String nome = pedaco;
      final match = RegExp('^(.*?)\\s*[xX]\\s*(\\d+)\\s*\$').firstMatch(pedaco);
      if (match != null) {
        nome = match.group(1)!.trim();
        quantidade = int.tryParse(match.group(2)!) ?? 1;
      }
      final itemBase = itensBase[_normalizar(nome)];
      if (itemBase == null) continue;
      resultado.add(itemBase.copyWith(quantidade: quantidade, localizacao: ''));
    }
    return resultado;
  }

  List<Poder> _poderes(String valor) {
    final resultado = <Poder>[];
    for (final parte in _lista(valor)) {
      final pedacos = parte.trim().split(RegExp(r'\s+'));
      if (pedacos.isEmpty) continue;
      final tipo = pedacos.first;
      int valorBase = 1;
      if (pedacos.length > 1) {
        final numero = RegExp(r'\d+').firstMatch(pedacos.sublist(1).join(' '));
        if (numero != null) valorBase = int.tryParse(numero.group(0)!) ?? 1;
      }
      resultado.add(Poder(tipo: tipo, valorBase: valorBase, original: true));
    }
    return resultado;
  }

  List<Encontro> _encontrosCriatura(String texto,
      Map<String, Criatura> criaturas, PeriodoDia? periodoPadrao) {
    final resultado = <Encontro>[];
    for (final referencia in _lista(texto)) {
      final textoReferencia = referencia.trim();
      final nome = _nomeSemRestricao(textoReferencia).trim();
      if (nome.isEmpty) continue;
      Criatura? criatura;
      for (final candidato in criaturas.values) {
        if (_normalizar(candidato.nome) == _normalizar(nome)) {
          criatura = candidato;
          break;
        }
      }
      if (criatura == null) continue;
      final restricao = _extrairRestricao(textoReferencia);
      final periodo = restricao.periodo ?? periodoPadrao;
      final raro = RegExp(r'\braro\b', caseSensitive: false)
          .hasMatch(_restricaoTexto(textoReferencia));
      resultado.add(Encontro(
          criatura: criatura,
          condicao: '',
          raro: raro,
          periodo: periodo,
          leguaMin: restricao.leguaMin,
          leguaMax: restricao.leguaMax,
          nivelFixo: restricao.nivelFixo));
    }
    return resultado;
  }

  List<EncontroNPC> _encontrosNPC(String texto, Map<String, NPC> npcs,
      {bool somenteRocket = false}) {
    final resultado = <EncontroNPC>[];
    for (final referencia in _lista(texto)) {
      final nome = _nomeSemRestricao(referencia);
      final npc = npcs[_idInterno('NPC', nome)];
      if (npc == null) continue;
      final ehRocket = _normalizar(nome).contains('rocket');
      if (somenteRocket != ehRocket) continue;
      final restricao = _extrairRestricao(referencia);
      resultado.add(EncontroNPC(
          npc: npc,
          raro: false,
          periodo: restricao.periodo,
          leguaMin: restricao.leguaMin,
          leguaMax: restricao.leguaMax));
    }
    return resultado;
  }

  PeriodoDia? _periodoFromString(String valor) {
    switch (_normalizarPeriodo(valor)) {
      case 'amanhecer':
        return PeriodoDia.amanhecer;
      case 'manha':
        return PeriodoDia.manha;
      case 'tarde':
        return PeriodoDia.tarde;
      case 'anoitecer':
        return PeriodoDia.anoitecer;
      case 'noite':
        return PeriodoDia.noite;
      case 'madrugada':
        return PeriodoDia.madrugada;
      case 'qualquer':
        return PeriodoDia.qualquer;
      default:
        return null;
    }
  }

  String _normalizarPeriodo(String texto) =>
      _normalizar(texto).replaceAll(RegExp(r'\s+'), '');

  (int, int) _extrairFaixaNivel(String texto) {
    final numeros = RegExp(r'\d+')
        .allMatches(texto)
        .map((m) => int.parse(m.group(0)!))
        .toList();
    if (numeros.isEmpty) return (0, 0);
    if (numeros.length == 1) return (numeros.first, numeros.first);
    return (numeros.first, numeros[1]);
  }

  String? _nulo(String texto) {
    if (texto.trim().isEmpty || texto.trim() == '-') return null;
    return texto.trim();
  }

  bool _linhaVazia(List<Data?> linha) {
    for (final celula in linha) {
      final valor = celula?.value;
      if (valor != null && valor.toString().trim().isNotEmpty) return false;
    }
    return true;
  }

  Sheet? _tabela(Excel excel, String nome) {
    final procurada = _normalizar(nome);
    for (final entrada in excel.tables.entries) {
      if (_normalizar(entrada.key) == procurada) return entrada.value;
    }
    return null;
  }

  Future<void> _exportarRegistros() async {
    setState(() => _importando = true);
    try {
      final repo = RegistrosRepository();
      final registros = await repo.carregar();
      if (registros.isEmpty) {
        _mensagem('Nenhum registro para exportar.', erro: true);
        return;
      }
      final archive = Archive();
      final jsonString = jsonEncode(registros.map((e) => e.toJson()).toList());
      final jsonBytes = utf8.encode(jsonString);
      archive
          .addFile(ArchiveFile('registros.json', jsonBytes.length, jsonBytes));
      if (!kIsWeb) {
        final dir = await getTemporaryDirectory();
        for (final r in registros) {
          final caminho = '${dir.path}/${r.nomeArquivoAudio}';
          final file = File(caminho);
          if (file.existsSync()) {
            final bytes = await file.readAsBytes();
            archive
                .addFile(ArchiveFile(r.nomeArquivoAudio, bytes.length, bytes));
          }
        }
      }
      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes == null) throw Exception('Falha ao gerar ZIP.');
      await FilePicker.saveFile(
          dialogTitle: 'Salvar Registros',
          fileName: 'Registros_Mundo.zip',
          bytes: Uint8List.fromList(zipBytes));
      if (!mounted) return;
      if (kIsWeb) {
        _mensagem('ZIP de registros exportado!');
        return;
      }
      _mensagem('Registros exportados!');
    } catch (e) {
      if (!mounted) return;
      _mensagem('Erro ao exportar registros: $e', erro: true);
    } finally {
      if (mounted) setState(() => _importando = false);
    }
  }

  Future<void> _importarRegistros() async {
    setState(() => _importando = true);
    try {
      final resultado = await FilePicker.pickFiles(
          type: FileType.custom, allowedExtensions: ['zip']);
      if (resultado.isEmpty) return;
      final arquivo = resultado.single;
      final bytes = await arquivo.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      List<Registro> registrosImportados = [];
      final tempDir = kIsWeb ? null : await getTemporaryDirectory();
      for (final file in archive) {
        if (file.name == 'registros.json') {
          final jsonString = utf8.decode(file.content as List<int>);
          final List<dynamic> lista = jsonDecode(jsonString);
          registrosImportados = lista.map((e) => Registro.fromJson(e)).toList();
        } else if (tempDir != null && file.isFile) {
          final outFile = File('${tempDir.path}/${file.name}');
          await outFile.writeAsBytes(file.content as List<int>);
        }
      }
      if (registrosImportados.isEmpty) {
        _mensagem('Nenhum registro encontrado no ZIP.', erro: true);
        return;
      }
      final repo = RegistrosRepository();
      final atuais = await repo.carregar();
      final idsAtuais = atuais.map((e) => e.id).toSet();
      final novos = registrosImportados.where((r) => !idsAtuais.contains(r.id));
      await repo.salvar([...atuais, ...novos]);
      _mensagem('${novos.length} registros importados!');
    } catch (e) {
      if (!mounted) return;
      _mensagem('Erro ao importar registros: $e', erro: true);
    } finally {
      if (mounted) setState(() => _importando = false);
    }
  }

  void _mostrarResultado(
      {required int criatura,
      required int npc,
      required int item,
      required int local,
      required int poi,
      required int evento,
      required List<String> erros}) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(erros.isEmpty
              ? 'Importação concluída'
              : 'Importação concluída com erros'),
          content: SingleChildScrollView(
            child: Text(
                'Criatura importados: $criatura\nNPCs importados: $npc\nItens importados: $item\nLocais importados: $local\nPontos de Interesse: $poi\nEventos: $evento\n\n${erros.isEmpty ? 'Nenhum erro encontrado.' : 'ERROS:\n${erros.join('\n')}'}'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'))
          ],
        );
      },
    );
  }

  void _abrirDownloads() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloads: em construcao.')));
  }

  void _mensagem(String texto, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(texto), backgroundColor: erro ? Colors.red : null));
  }
}

class _RestricaoLocal {
  final PeriodoDia? periodo;
  final int? leguaMin;
  final int? leguaMax;
  final int? nivelFixo;

  const _RestricaoLocal({
    this.periodo,
    this.leguaMin,
    this.leguaMax,
    this.nivelFixo,
  });
}
