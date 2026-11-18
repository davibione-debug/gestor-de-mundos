import 'dart:io';

void main() {
  final dir = Directory('lib');
  int corrigidos = 0;
  final regex = RegExp(r'\u00C3(.)');

  for (final entidade in dir.listSync(recursive: true)) {
    if (entidade is! File || !entidade.path.endsWith('.dart')) continue;
    var content = entidade.readAsStringSync();
    final original = content;

    // Substitui o padrão 'Ã' + caractere pelo acento correto
    content = content.replaceAllMapped(regex, (match) {
      final next = match.group(1)!;
      final code = next.codeUnitAt(0);
      switch (code) {
        case 0x00A1: return 'á'; // Ã¡
        case 0x00A9: return 'é'; // Ã©
        case 0x00AD: return 'í'; // Ã­
        case 0x00B3: return 'ó'; // Ã³
        case 0x00BA: return 'ú'; // Ãº
        case 0x00A3: return 'ã'; // Ã£
        case 0x00B5: return 'õ'; // Ãµ
        case 0x00A7: return 'ç'; // Ã§
        case 0x00A2: return 'â'; // Ã¢
        case 0x00AA: return 'ê'; // Ãª
        case 0x00B4: return 'ô'; // Ã´
        case 0x0020: return 'à'; // Ã 
        case 0x0089: return 'É'; // Ã‰
        case 0x0087: return 'Ç'; // Ã‡
        default: return match.group(0)!; // Se não for conhecido, mantém
      }
    });

    // Corrige o caso especial "пїЅ" (Pokémon) que o detector encontrou
    content = content.replaceAll(String.fromCharCodes([0x043F, 0x0457, 0x0405]), 'é');

    if (content != original) {
      entidade.writeAsStringSync(content);
      print('Corrigido: ${entidade.path}');
      corrigidos++;
    }
  }
  print('Total de arquivos corrigidos: $corrigidos');
}