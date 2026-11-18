import 'dart:io';

void main() {
  final path = 'lib/screens/administracao/administracao_screen.dart';
  var src = File(path).readAsStringSync();

  // 1. Localiza o inicio e o fim do bloco de botoes dentro do build
  final startMarker = "          _botao(\n            context,\n            Icons.color_lens,";
  final endMarker = "          _botao(\n            context,\n            Icons.picture_as_pdf,\n            'Manual Básico',\n            _baixarManualBasico,\n          ),";

  final startIdx = src.indexOf(startMarker);
  final endIdx = src.indexOf(endMarker);

  if (startIdx == -1 || endIdx == -1) {
    print('ERRO: Nao foi possivel localizar o inicio ou o fim do bloco de botoes.');
    exit(1);
  }

  final finalIdx = endIdx + endMarker.length;

  const novoBloco = '''          _botao(
            context,
            Icons.color_lens,
            'Personalizar Menus',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PersonalizarScreen()),
            ),
          ),
          _botao(
            context,
            Icons.upload_file,
            _importando ? 'Importando...' : 'Importar Dados',
            _importando ? null : _importarDados,
          ),
          _botao(
            context,
            Icons.download,
            'Exportar Dados',
            _exportarDados,
          ),
          _botao(
            context,
            Icons.unarchive,
            'Importar Registros (.zip)',
            _importarRegistros,
          ),
          _botao(
            context,
            Icons.archive,
            'Exportar Registros (.zip)',
            _exportarRegistros,
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          _botao(
            context,
            Icons.folder_open,
            'Downloads',
            _abrirDownloads,
          ),''';

  src = src.substring(0, startIdx) + novoBloco + src.substring(finalIdx);

  // 2. Adiciona o metodo _abrirDownloads antes de _mensagem
  if (!src.contains('void _abrirDownloads()')) {
    src = src.replaceFirst(
      '  void _mensagem(String texto, {bool erro = false}) {',
      '''  void _abrirDownloads() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloads: em construcao.')),
    );
  }

  void _mensagem(String texto, {bool erro = false}) {''',
    );
  }

  // 3. Remove os metodos _baixarModeloDados e _baixarManualBasico (nao sao mais usados)
  final regexBaixarModelo = RegExp(
    r'\n  Future<void> _baixarModeloDados\(\) async \{[\s\S]*?\n  \}\n',
  );
  src = src.replaceAll(regexBaixarModelo, '\n');

  final regexBaixarManual = RegExp(
    r'\n  Future<void> _baixarManualBasico\(\) async \{[\s\S]*?\n  \}\n',
  );
  src = src.replaceAll(regexBaixarManual, '\n');

  // 4. Remove o metodo _salvarAsset se nao for mais usado
  if (!src.contains('_salvarAsset(')) {
    final regexSalvarAsset = RegExp(
      r'\n  Future<void> _salvarAsset\(\{[\s\S]*?\n  \}\n',
    );
    src = src.replaceAll(regexSalvarAsset, '\n');
  }

  File(path).writeAsStringSync(src);
  print('administracao_screen.dart ajustado com sucesso.');
}