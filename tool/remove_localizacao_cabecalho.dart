import 'dart:io';

void main() {
  final path = 'lib/screens/npcs/npc_screen.dart';
  var src = File(path).readAsStringSync();
  final temCRLF = src.contains('\r\n');
  if (temCRLF) src = src.replaceAll('\r\n', '\n');

  // Bloco que exibe npc.localizacao no cabecalho vermelho
  const alvo = '''                if (npc.localizacao.trim().isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          npc.localizacao,
                          style: TextStyle(
                            color: Colors.white.withValues(
                              alpha: 0.92,
                            ),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
''';

  if (!src.contains(alvo)) {
    print('AVISO: bloco da localizacao no cabecalho nao encontrado.');
  } else {
    src = src.replaceFirst(alvo, '');
    print('Cabecalho da localizacao removido.');
  }

  if (temCRLF) src = src.replaceAll('\n', '\r\n');
  File(path).writeAsStringSync(src);
}