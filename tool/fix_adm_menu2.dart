import 'dart:io';

void main() {
  final path = 'lib/screens/administracao/administracao_screen.dart';
  var src = File(path).readAsStringSync();

  // Normaliza CRLF para LF para achar as ancoras
  final temCRLF = src.contains('\r\n');
  if (temCRLF) src = src.replaceAll('\r\n', '\n');

  // Ancoras por conteudo, ignorando indentacao
  final inicio = src.indexOf('Icons.color_lens');
  final fim = src.indexOf('_baixarManualBasico');

  if (inicio == -1 || fim == -1) {
    print('ERRO: Nao encontrei "Icons.color_lens" ou "_baixarManualBasico".');
    exit(1);
  }

  // Encontra o inicio do _botao( que precede color_lens
  var startIdx = src.lastIndexOf('_botao(', inicio);
  // Encontra o fim do bloco: o ")," que fecha o _botao do ManualBasico
  var endIdx = src.indexOf('_baixarManualBasico', fim) + '_baixarManualBasico'.length;
  // A partir daí, avança até o ")," mais próximo
  var closeIdx = src.indexOf('),', endIdx);
  if (closeIdx == -1) {
    print('ERRO: Nao encontrei o fechamento do botao ManualBasico.');
    exit(1);
  }
  // Inclui o "),"
  final finalIdx = closeIdx + 2;

  const novoBloco = '''_botao(
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

  // Adiciona o metodo _abrirDownloads antes de _mensagem
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

  // Remove os metodos _baixarModeloDados e _baixarManualBasico
  final regexBaixarModelo = RegExp(
    r'\n  Future<void> _baixarModeloDados\(\) async \{[\s\S]*?\n  \}\n',
  );
  src = src.replaceAll(regexBaixarModelo, '\n');

  final regexBaixarManual = RegExp(
    r'\n  Future<void> _baixarManualBasico\(\) async \{[\s\S]*?\n  \}\n',
  );
  src = src.replaceAll(regexBaixarManual, '\n');

  // Remove _salvarAsset se nao for mais usado
  if (!src.contains('_salvarAsset(')) {
    final regexSalvarAsset = RegExp(
      r'\n  Future<void> _salvarAsset\(\{[\s\S]*?\n  \}\n',
    );
    src = src.replaceAll(regexSalvarAsset, '\n');
  }

  if (temCRLF) src = src.replaceAll('\n', '\r\n');

  File(path).writeAsStringSync(src);
  print('administracao_screen.dart ajustado.');
}