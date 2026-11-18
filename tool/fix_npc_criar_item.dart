import 'dart:io';

void main() {
  final path = 'lib/screens/npcs/npc_edit_screen.dart';
  var src = File(path).readAsStringSync();
  final temCRLF = src.contains('\r\n');
  if (temCRLF) src = src.replaceAll('\r\n', '\n');

  // 1. Adiciona import da ItemEditarScreen
  if (!src.contains("import '../itens/item_editar_screen.dart';")) {
    const ancoraImport = "import '../../repositories/itens_repository.dart';";
    if (src.contains(ancoraImport)) {
      src = src.replaceFirst(
        ancoraImport,
        ancoraImport + "\nimport '../itens/item_editar_screen.dart';",
      );
    } else {
      print('AVISO: import de itens_repository nao encontrado.');
    }
  }

  // 2. Substitui o inicio do _adicionarItem por um menu de escolha
  const assinaturaAntiga = "  Future<void> _adicionarItem() async {\n    final itensBase = await ItensRepository().carregar();";
  const novoInicio = '''  Future<void> _adicionarItem() async {
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

    final itensBase = await ItensRepository().carregar();''';

  if (!src.contains(assinaturaAntiga)) {
    print('ERRO: inicio de _adicionarItem nao encontrado.');
    exit(1);
  }
  src = src.replaceFirst(assinaturaAntiga, novoInicio);

  // 3. Adiciona o metodo _criarItem antes de _editarItem
  if (!src.contains('Future<void> _criarItem()')) {
    const ancoraEditar = '  Future<void> _editarItem(int indice) async {';
    if (!src.contains(ancoraEditar)) {
      print('ERRO: ancora de _editarItem nao encontrada.');
      exit(1);
    }

    const metodoNovo = r'''  Future<void> _criarItem() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ItemEditarScreen(
          item: const Item(
            nome: '',
            tipo: '',
            custoEmCreditos: 0,
            efeito: '',
          ),
          novo: true,
        ),
      ),
    );

    if (resultado != true || !mounted) return;

    final itens = await ItensRepository().carregar();
    if (!mounted) return;
    if (itens.isEmpty) return;

    itens.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    final novo = itens.last;

    setState(() {
      _itens.add(
        novo.copyWith(quantidade: 1, localizacao: ''),
      );
    });
  }

''';

    src = src.replaceFirst(ancoraEditar, metodoNovo + ancoraEditar);
  }

  if (temCRLF) src = src.replaceAll('\n', '\r\n');
  File(path).writeAsStringSync(src);
  print('npc_edit_screen.dart ajustado.');
}