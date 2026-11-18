import 'dart:io';

void main() {
  final path = 'lib/screens/npcs/npc_edit_screen.dart';
  var src = File(path).readAsStringSync();
  final temCRLF = src.contains('\r\n');
  if (temCRLF) src = src.replaceAll('\r\n', '\n');

  // Bloco que abre o menu de escolha no inicio do _adicionarItem
  const blocoAntigo = '''  Future<void> _adicionarItem() async {
    final acao = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Adicionar Item'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'selecionar'),
              child: const ListTile(
                leading: Icon(Icons.search),
                title: Text('Selecionar do Cadastro'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'criar'),
              child: const ListTile(
                leading: Icon(Icons.add_circle_outline),
                title: Text('Criar novo item'),
              ),
            ),
          ],
        );
      },
    );

    if (acao == null || !mounted) return;

    if (acao == 'criar') {
      await _criarItem();
      return;
    }

    final itensBase = await ItensRepository().carregar();
''';

  const blocoNovo = '''  Future<void> _adicionarItem() async {
    final itensBase = await ItensRepository().carregar();
''';

  if (!src.contains(blocoAntigo)) {
    print('ERRO: bloco do menu de adicionar item nao encontrado.');
    exit(1);
  }

  src = src.replaceFirst(blocoAntigo, blocoNovo);

  if (temCRLF) src = src.replaceAll('\n', '\r\n');
  File(path).writeAsStringSync(src);
  print('npc_edit_screen.dart ajustado: Adicionar vai direto ao cadastro.');
}