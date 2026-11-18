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
  const blocoInventario = '''          if (npc.manobras.isNotEmpty && npc.inventario.isNotEmpty)
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

  if (src.contains(blocoInventario)) {
    src = src.replaceFirst(blocoInventario, blocoManobras);
    print('Bloco de Inventario texto livre removido.');
  } else {
    print('AVISO: bloco de Inventario nao encontrado.');
  }

  // 3. Corrige o texto de "Criatura vazia"
  const textoErrado = "'O \\$_nomePersonagens \"\\${npc.nome}\" será removido apenas do armazenamento local do aplicativo.\\n\\nA planilha não será alterada.'";
  const textoCorreto = "'Nenhuma criatura cadastrada para \\$_nomePersonagens.'";
  if (src.contains(textoErrado)) {
    src = src.replaceFirst(textoErrado, textoCorreto);
    print('Texto de Criatura vazia corrigido.');
  } else {
    print('AVISO: texto de Criatura vazia nao encontrado.');
  }

  // 4. Adiciona o metodo _secaoItensNPC antes de _secaoLocalizacaoNPC
  if (!src.contains('Widget _secaoItensNPC(')) {
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
                    '\${item.nome} × \${item.quantidade}',
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

  // 5. Adiciona a chamada _secaoItensNPC no build (antes de _secaoLocalizacaoNPC)
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