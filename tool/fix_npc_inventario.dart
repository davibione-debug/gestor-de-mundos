import 'dart:io';

void main() {
  // ================================================================
  // 1) npc_edit_screen.dart: remover o campo de texto Inventário
  // ================================================================
  {
    final path = 'lib/screens/npcs/npc_edit_screen.dart';
    var src = File(path).readAsStringSync();
    final temCRLF = src.contains('\r\n');
    if (temCRLF) src = src.replaceAll('\r\n', '\n');

    // Remove o campo visual de Inventario no build
    const blocoBuild = '''            _campoTexto(
              'Inventário',
              _inventarioController,
              maxLines: 4,
            ),
''';
    if (src.contains(blocoBuild)) {
      src = src.replaceFirst(blocoBuild, '');
    } else {
      print('AVISO edit: bloco visual do Inventario nao encontrado.');
    }

    // Remove a declaracao do controller
    src = src.replaceFirst(
      '  late final TextEditingController _inventarioController;\n',
      '',
    );

    // Remove inicializacao no initState
    src = src.replaceFirst(
      "    _inventarioController = TextEditingController(\n      text: npc.inventario,\n    );\n\n",
      '',
    );

    // Remove dispose
    src = src.replaceFirst(
      '    _inventarioController.dispose();\n',
      '',
    );

    // Remove do _salvar, passando string vazia
    src = src.replaceFirst(
      "        inventario: _inventarioController.text.trim(),\n",
      "        inventario: '',\n",
    );

    if (temCRLF) src = src.replaceAll('\n', '\r\n');
    File(path).writeAsStringSync(src);
    print('npc_edit_screen.dart ajustado: campo Inventario removido.');
  }

  // ================================================================
  // 2) npc_screen.dart: substituir secao de Inventario por lista de Itens
  // ================================================================
  {
    final path = 'lib/screens/npcs/npc_screen.dart';
    var src = File(path).readAsStringSync();
    final temCRLF = src.contains('\r\n');
    if (temCRLF) src = src.replaceAll('\r\n', '\n');

    // Adiciona import da ItemDetalheScreen
    if (!src.contains("import '../itens/item_detalhe_screen.dart';")) {
      src = src.replaceFirst(
        "import '../bestiario/criatura_detalhe_screen.dart';",
        "import '../bestiario/criatura_detalhe_screen.dart';\nimport '../itens/item_detalhe_screen.dart';\nimport '../../models/item.dart';",
      );
    }

    // Remove o bloco if/else if que mostra Manobras junto com Inventario
    const blocoManobrasInventario = '''          if (npc.manobras.isNotEmpty && npc.inventario.isNotEmpty)
            _linhaSecoesTexto(
              _textoSecao(
                'Manobras',
                npc.manobras,
                _azul,
                Icons.sports_martial_arts,
              ),
              _textoSecao(
                'Inventário',
                npc.inventario,
                _amarelo,
                Icons.inventory_2_outlined,
              ),
            )
          else if (npc.manobras.isNotEmpty)
            _textoSecao(
              'Manobras',
              npc.manobras,
              _azul,
              Icons.sports_martial_arts,
            )
          else if (npc.inventario.isNotEmpty)
            _textoSecao(
              'Inventário',
              npc.inventario,
              _amarelo,
              Icons.inventory_2_outlined,
            ),
''';

    const blocoManobras = '''          if (npc.manobras.isNotEmpty)
            _textoSecao(
              'Manobras',
              npc.manobras,
              _azul,
              Icons.sports_martial_arts,
            ),
''';

    if (src.contains(blocoManobrasInventario)) {
      src = src.replaceFirst(blocoManobrasInventario, blocoManobras);
    } else {
      print('AVISO screen: bloco Manobras/Inventario nao encontrado.');
    }

    // Adiciona a nova secao de Itens (com links) antes de Criaturas
    if (!src.contains("_secaoItensNPC()")) {
      src = src.replaceFirst(
        "          if (npc.criaturas.isNotEmpty) ...[",
        "          _secaoItensNPC(npc),\n          if (npc.criaturas.isNotEmpty) ...[",
      );

      // Cria o metodo _secaoItensNPC
      const ancora = '  Widget _secaoLocalizacaoNPC() {';
      const novoMetodo = '''  Widget _secaoItensNPC(NPC npc) {
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
                    '${item.nome} \\u00d7 ${item.quantidade}',
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
      } else {
        print('AVISO screen: ancora _secaoLocalizacaoNPC nao encontrada.');
      }
    }

    if (temCRLF) src = src.replaceAll('\n', '\r\n');
    File(path).writeAsStringSync(src);
    print('npc_screen.dart ajustado: secao Itens adicionada e Inventario removido.');
  }
}