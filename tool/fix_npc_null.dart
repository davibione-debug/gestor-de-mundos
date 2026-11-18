import 'dart:io';

void main() {
  final path = 'lib/screens/npcs/npc_screen.dart';
  var src = File(path).readAsStringSync();
  final temCRLF = src.contains('\r\n');
  if (temCRLF) src = src.replaceAll('\r\n', '\n');

  final alvo = '_localizacoesFuture = buscarLocalizacoesDoNPC(npc);';
  if (!src.contains(alvo)) {
    print('ERRO: chamada de buscarLocalizacoesDoNPC nao encontrada.');
    exit(1);
  }

  src = src.replaceFirst(
    alvo,
    '_localizacoesFuture = buscarLocalizacoesDoNPC(npc!);',
  );

  if (temCRLF) src = src.replaceAll('\n', '\r\n');
  File(path).writeAsStringSync(src);
  print('Adicionado ! no npc.');
}