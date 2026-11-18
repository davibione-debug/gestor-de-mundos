import 'dart:io';

void main() {
  final path = 'lib/screens/administracao/administracao_screen.dart';
  var src = File(path).readAsStringSync();
  final temCRLF = src.contains('\r\n');
  if (temCRLF) src = src.replaceAll('\r\n', '\n');

  if (!src.contains('List<Item> _itensDoInventario(')) {
    const ancora = '  List<Poder> _poderes(String valor) {';
    const novoMetodo = '''  List<Item> _itensDoInventario(
    String texto,
    Map<String, Item> itensBase,
  ) {
    final resultado = <Item>[];
    for (final entrada in _lista(texto)) {
      final pedaco = entrada.trim();
      if (pedaco.isEmpty) continue;

      int quantidade = 1;
      String nome = pedaco;

      final match = RegExp(
        '^(.*?)\\\\s*[xX]\\\\s*(\\\\d+)\\\\s*\\\$',
      ).firstMatch(pedaco);
      if (match != null) {
        nome = match.group(1)!.trim();
        quantidade = int.tryParse(match.group(2)!) ?? 1;
      }

      final itemBase = itensBase[_normalizar(nome)];
      if (itemBase == null) continue;

      resultado.add(
        itemBase.copyWith(quantidade: quantidade, localizacao: ''),
      );
    }
    return resultado;
  }

  List<Poder> _poderes(String valor) {''';

    if (src.contains(ancora)) {
      src = src.replaceFirst(ancora, novoMetodo);
      print('Helper _itensDoInventario adicionado.');
    } else {
      print('ERRO: ancora _poderes nao encontrada.');
      exit(1);
    }
  }

  const alvoNpc = '''              inventario: _celula(linha, cab, 'Inventário'),
              pv: _int(_celula(linha, cab, 'PV')),
            );''';

  const novoNpc = '''              inventario: _celula(linha, cab, 'Inventário'),
              pv: _int(_celula(linha, cab, 'PV')),
              itens: _itensDoInventario(
                _celula(linha, cab, 'Inventário'),
                itens,
              ),
            );''';

  if (src.contains(alvoNpc)) {
    src = src.replaceFirst(alvoNpc, novoNpc);
    print('Construcao do NPC ajustada para preencher itens.');
  } else {
    print('ERRO: bloco de construcao do NPC nao encontrado.');
    exit(1);
  }

  if (temCRLF) src = src.replaceAll('\n', '\r\n');
  File(path).writeAsStringSync(src);
  print('administracao_screen.dart ajustado.');
}