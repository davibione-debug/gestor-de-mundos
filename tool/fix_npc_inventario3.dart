import 'dart:io';

void main() {
  final path = 'lib/screens/npcs/npc_edit_screen.dart';
  var src = File(path).readAsStringSync();
  final temCRLF = src.contains('\r\n');
  if (temCRLF) src = src.replaceAll('\r\n', '\n');

  // 1. Remove o bloco visual do campo Inventário (com maxLines: 4)
  const blocoBuild = '''            _campoTexto(
              'Inventário',
              _inventarioController,
              maxLines: 4,
            ),
''';

  if (src.contains(blocoBuild)) {
    src = src.replaceFirst(blocoBuild, '');
    print('Campo visual Inventario removido.');
  } else {
    print('AVISO: bloco visual do Inventario nao encontrado.');
    exit(1);
  }

  // 2. Remove declaração, initState, dispose e troca no _salvar
  if (src.contains('  late final TextEditingController _inventarioController;')) {
    src = src.replaceFirst(
      '  late final TextEditingController _inventarioController;\n',
      '',
    );
    print('Declaracao do controller removida.');
  }

  const blocoInit = '''    _inventarioController = TextEditingController(
      text: npc.inventario,
    );

''';
  if (src.contains(blocoInit)) {
    src = src.replaceFirst(blocoInit, '');
    print('Inicializacao no initState removida.');
  }

  if (src.contains('    _inventarioController.dispose();\n')) {
    src = src.replaceFirst('    _inventarioController.dispose();\n', '');
    print('Dispose removido.');
  }

  if (src.contains("inventario: _inventarioController.text.trim(),")) {
    src = src.replaceFirst(
      "inventario: _inventarioController.text.trim(),",
      "inventario: '',",
    );
    print('_salvar ajustado para inventario vazio.');
  }

  if (temCRLF) src = src.replaceAll('\n', '\r\n');
  File(path).writeAsStringSync(src);
  print('npc_edit_screen.dart ajustado.');
}