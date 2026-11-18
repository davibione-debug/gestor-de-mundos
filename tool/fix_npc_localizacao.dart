import 'dart:io';

void main() {
  final path = 'lib/screens/npcs/npc_screen.dart';
  var src = File(path).readAsStringSync();
  final temCRLF = src.contains('\r\n');
  if (temCRLF) src = src.replaceAll('\r\n', '\n');

  // 1. Adiciona import
  if (!src.contains("import 'npc_localizacao.dart';")) {
    src = src.replaceFirst(
      "import '../../repositories/criaturas_repository.dart';",
      "import '../../repositories/criaturas_repository.dart';\nimport 'npc_localizacao.dart';",
    );
  }

  // 2. Adiciona o future no initState
  if (!src.contains('_localizacoesFuture')) {
    src = src.replaceFirst(
      'NPC? _npc;\n  List<Criatura> _criaturas = [];',
      'NPC? _npc;\n  List<Criatura> _criaturas = [];\n  Future<List<ReferenciaLocalizacaoNPC>>? _localizacoesFuture;',
    );
    src = src.replaceFirst(
      '_carregar();\n    _carregarNomesConfigurados();',
      '_carregar();\n    _carregarNomesConfigurados();\n  }\n\n  void _recalcularLocalizacoes(NPC npc) {\n    _localizacoesFuture = buscarLocalizacoesDoNPC(npc);\n  }\n\n  @override\n  void initState() {\n    super.initState();',
    );
    src = src.replaceFirst(
      '_npc = npc;\n        _criaturas = encontrados;\n        _carregando = false;',
      '_npc = npc;\n        _criaturas = encontrados;\n        _localizacoesFuture = buscarLocalizacoesDoNPC(npc);\n        _carregando = false;',
    );
  }

  // 3. Adiciona a seção de localização no build
  if (!src.contains('_secaoLocalizacaoNPC')) {
    src = src.replaceFirst(
      '  @override\n  Widget build(',
      '''  Widget _secaoLocalizacaoNPC() {
    final future = _localizacoesFuture;
    if (future == null) return const SizedBox.shrink();
    return FutureBuilder<List<ReferenciaLocalizacaoNPC>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(child: Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())));
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
                        Text('$tipo: ', style: const TextStyle(fontWeight: FontWeight.w600)),
                        for (var i = 0, indice = 0; i < referencias.length; i++)
                          if (referencias[i].tipo == tipo) ...[
                            if (indice++ > 0) const Text(', '),
                            InkWell(
                              onTap: () {
                                final tela = widgetReferenciaNPC(context, referencias[i]);
                                if (tela != null) Navigator.push(context, MaterialPageRoute(builder: (_) => tela));
                              },
                              child: Text(
                                referencias[i].localNome != null
                                    ? '${referencias[i].nome} (${referencias[i].localNome})'
                                    : referencias[i].nome,
                                style: TextStyle(color: Theme.of(context).colorScheme.primary, decoration: TextDecoration.underline),
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
  Widget build(''',
    );
  }

  // 4. Adiciona a chamada no build depois das criaturas
  if (!src.contains('_secaoLocalizacaoNPC(),')) {
    final regex = RegExp(
      r'(\],\s*\n\s*\);\s*\n\s*\},\s*\n\s*\}\s*)$',
    );
    final match = regex.firstMatch(src);
    if (match == null) {
      print('AVISO: nao foi possivel inserir a chamada de localizacao.');
      exit(1);
    }
    final pos = src.indexOf('],\n      ),\n    );', src.indexOf('_buildCriaturaResumo'));
    if (pos == -1) {
      print('AVISO: nao foi possivel inserir a chamada de localizacao.');
    } else {
      src = src.replaceRange(pos, pos + 1, '],\n      ),\n    );');
    }
  }

  if (temCRLF) src = src.replaceAll('\n', '\r\n');
  File(path).writeAsStringSync(src);
  print('npc_screen.dart ajustado.');
}