import 'dart:io';

void main() {
  final path = 'lib/screens/administracao/administracao_screen.dart';
  var src = File(path).readAsStringSync();
  final temCRLF = src.contains('\r\n');
  if (temCRLF) src = src.replaceAll('\r\n', '\n');

  const alvo = '''          TextCellValue(n.criaturas.join(', ')),
          TextCellValue(n.nivelCriatura),
          TextCellValue(n.inventario),
        ]);''';

  const novo = '''          TextCellValue(n.criaturas.join(', ')),
          TextCellValue(n.nivelCriatura),
          TextCellValue(
            n.itens
                .map((i) => '\\\${i.nome} x\\\${i.quantidade}')
                .join(', '),
          ),
        ]);''';

  if (!src.contains(alvo)) {
    print('ERRO: bloco de exportacao do NPC nao encontrado.');
    exit(1);
  }

  src = src.replaceFirst(alvo, novo);

  if (temCRLF) src = src.replaceAll('\n', '\r\n');
  File(path).writeAsStringSync(src);
  print('Exportacao do NPC ajustada para usar npc.itens.');
}