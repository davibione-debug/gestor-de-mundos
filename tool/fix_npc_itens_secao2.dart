import 'dart:io';

void main() {
  final path = 'lib/screens/npcs/npc_screen.dart';
  var src = File(path).readAsStringSync();
  final temCRLF = src.contains('\r\n');
  if (temCRLF) src = src.replaceAll('\r\n', '\n');

  // 1. Adiciona imports
  if (!src.contains("import '../itens/item_detalhe_screen.dart';")) {
    src = src.replaceFirst(
      "import '../bestiario/criatura_detalhe_screen.dart';",
      "import '../bestiario/criatura_detalhe_screen.dart';\nimport '../itens/item_detalhe_screen.dart';\nimport '../../models/item.dart';",
    );
    print('Imports adicionados.');
  }

  // 2. Remove o bloco de texto livre do Inventario
  final regexInventario = RegExp(
    r"          if \(npc\.manobras\.isNotEmpty && npc\.inventario\.isNotEmpty\)[\s\S]*?Icons\.inventory_2_outlined,\n            \),\n",
  );
  if (regexInventario.hasMatch(src)) {
    src = src.replaceFirst(
      regexInventario,
      '''          if (npc.manobras.isNotEmpty)
            _textoSecao(
              'Manobras',
              npc.manobras,
              _azul,
              Icons.sports_martial_arts,
            ),
''',
    );
    print('Bloco de Inventario texto livre removido.');
  } else {
    print('AVISO: bloco de Inventario nao encontrado.');
  }

  // 3. Adiciona o metodo _secaoItensNPC antes de _secaoLocalizacaoNPC
  if (!src.contains('Widget _secaoItensNPC(')) {
    const ancora = '  Widget _secaoLocalizacaoNPC() {';
    const novoMetodo = r'''  Widget _secaoItensNPC(NPC npc) {
    if (npc.itens.isEmpty) {
      return const SizedBox.shrink();
    }

    return _cabecalhoSecao(
      'Itens',
      _amarelo,
      Icons.inventory_2_outlined,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: npc.itens
            .map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                child: ListTile(
                  leading: const Icon(
                    Icons.inventory_2_outlined,
                    color: _amarelo,
                  ),
                  title: Text(
                    '${item.nome} \u00d7 ${item.quantidade}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: _texto,
                    ),
                  ),
                  subtitle: Text(
                    item.tipo.isEmpty ? item.descricao : item.tipo,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: _textoSecundario,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemDetalheScreen(item: item),
                      ),
                    );
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _secaoLocalizacaoNPC() {''';

    if (src.contains(ancora)) {
      src = src.replaceFirst(ancora, novoMetodo);
      print('Metodo _secaoItensNPC adicionado.');
    } else {
      print('AVISO: ancora _secaoLocalizacaoNPC nao encontrada.');
      exit(1);
    }
  }

  // 4. Adiciona a chamada _secaoItensNPC no build
  if (!src.contains('_secaoItensNPC(npc)')) {
    const ancoraBuild = '          _secaoLocalizacaoNPC(),';
    const novoBuild = '''          _secaoItensNPC(npc),
          _secaoLocalizacaoNPC(),''';

    if (src.contains(ancoraBuild)) {
      src = src.replaceFirst(ancoraBuild, novoBuild);
      print('Chamada _secaoItensNPC adicionada no build.');
    } else {
      print('AVISO: ancora _secaoLocalizacaoNPC() nao encontrada no build.');
    }
  }

  if (temCRLF) src = src.replaceAll('\n', '\r\n');
  File(path).writeAsStringSync(src);
  print('npc_screen.dart ajustado.');
}