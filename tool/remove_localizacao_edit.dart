import 'dart:io';

void main() {
  final path = 'lib/screens/npcs/npc_edit_screen.dart';
  var src = File(path).readAsStringSync();

  // Normaliza CRLF
  final temCRLF = src.contains('\r\n');
  if (temCRLF) src = src.replaceAll('\r\n', '\n');

  // Bloco EXATO do arquivo, com a indentação e quebras de linha corretas
  const alvo = '''            _campoTexto(
              'Localização',
              _localizacaoController,
            ),
''';

  if (!src.contains(alvo)) {
    print('ERRO: bloco do campo Localizacao nao encontrado. Abortando.');
    exit(1);
  }

  src = src.replaceFirst(alvo, '');
  print('Campo Localizacao removido do build().');

  if (temCRLF) src = src.replaceAll('\n', '\r\n');

  File(path).writeAsStringSync(src);
  print('npc_edit_screen.dart ajustado.');
}