import 'dart:io';

void main() {
  final path = 'lib/screens/administracao/administracao_screen.dart';
  var src = File(path).readAsStringSync();
  final temCRLF = src.contains('\r\n');
  if (temCRLF) src = src.replaceAll('\r\n', '\n');

  // Procuramos o trecho LITERAL exato do seu arquivo.
  // A string contém `\${...}` (barra + $), que é texto literal no arquivo.
  const alvo = r"'\${i.nome} x\${i.quantidade}'";
  const correto = r"'${i.nome} x${i.quantidade}'";

  if (!src.contains(alvo)) {
    print(r'ERRO: string literal \${i.nome} nao encontrada.');
    exit(1);
  }

  src = src.replaceFirst(alvo, correto);

  if (temCRLF) src = src.replaceAll('\n', '\r\n');
  File(path).writeAsStringSync(src);
  print('Exportacao do NPC corrigida: interpolacao ativa.');
}