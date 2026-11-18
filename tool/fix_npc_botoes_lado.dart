import 'dart:io';

void main() {
  final path = 'lib/screens/npcs/npc_edit_screen.dart';
  var src = File(path).readAsStringSync();
  final temCRLF = src.contains('\r\n');
  if (temCRLF) src = src.replaceAll('\r\n', '\n');

  // O script anterior provavelmente deixou o botao "Adicionar item" sozinho.
  // Vamos localizar esse bloco e substituir por uma Row com os dois botoes.
  const ancora = '''            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _salvando ? null : _adicionarItem,
                icon: const Icon(Icons.add),
                label: const Text(
                  'Adicionar item',
                ),
              ),
            ),
''';

  const novoBloco = '''            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _salvando ? null : _adicionarItem,
                    icon: const Icon(Icons.library_add_outlined),
                    label: const Text('Adicionar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _salvando ? null : _criarItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Criar'),
                  ),
                ),
              ],
            ),
''';

  if (!src.contains(ancora)) {
    print('ERRO: bloco do botao Adicionar item nao encontrado.');
    exit(1);
  }

  src = src.replaceFirst(ancora, novoBloco);

  if (temCRLF) src = src.replaceAll('\n', '\r\n');
  File(path).writeAsStringSync(src);
  print('npc_edit_screen.dart ajustado: botoes lado a lado.');
}