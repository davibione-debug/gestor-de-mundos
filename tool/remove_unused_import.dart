import 'dart:io';

void main() {
  final path = 'lib/screens/npcs/npc_screen.dart';
  var src = File(path).readAsStringSync();
  final temCRLF = src.contains('\r\n');
  if (temCRLF) src = src.replaceAll('\r\n', '\n');

  if (src.contains("import '../../models/item.dart';\n")) {
    src = src.replaceFirst("import '../../models/item.dart';\n", '');
    print('Import nao usado removido.');
  }

  if (temCRLF) src = src.replaceAll('\n', '\r\n');
  File(path).writeAsStringSync(src);
}