import 'dart:io';

void main() {
  final path = 'lib/screens/administracao/administracao_screen.dart';
  var src = File(path).readAsStringSync();
  final temCRLF = src.contains('\r\n');
  if (temCRLF) src = src.replaceAll('\r\n', '\n');

  const alvo = r"n.itens\n                .map((i) => '\${i.nome} x\${i.quantidade}')\n                .join(', '),";
  const correto = r"n.itens\n                .map((i) => '${i.nome} x${i.quantidade}')\n                .join(', '),";

  if (!src.contains(alvo)) {
    print(r'ERRO: trecho literal com \${...} nao encontrado.');
    exit(1);
  }

  src = src.replaceFirst(alvo, correto);

  if (temCRLF) src = src.replaceAll('\n', '\r\n');
  File(path).writeAsStringSync(src);
  print('Exportacao do NPC corrigida.');
}