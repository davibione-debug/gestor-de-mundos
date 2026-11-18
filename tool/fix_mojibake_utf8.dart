import 'dart:io';

void main() {
  final dir = Directory('lib');
  if (!dir.existsSync()) { print('lib nao encontrada.'); exit(1); }

  const mapa = <String, String>{
    'Ã¡': 'á', 'Ã ': 'à', 'Ã£': 'ã', 'Ã¢': 'â', 'Ã¤': 'ä',
    'Ã©': 'é', 'Ã¨': 'è', 'Ãª': 'ê', 'Ã«': 'ë',
    'Ã­': 'í', 'Ã¬': 'ì', 'Ã®': 'î', 'Ã¯': 'ï',
    'Ã³': 'ó', 'Ã²': 'ò', 'Ãµ': 'õ', 'Ã´': 'ô', 'Ã¶': 'ö',
    'Ãº': 'ú', 'Ã¹': 'ù', 'Ã»': 'û', 'Ã¼': 'ü',
    'Ã§': 'ç', 'Ã±': 'ñ',
    'Ã': 'Á', 'Ã‰': 'É', 'Ã"': 'Ó', 'Ã‡': 'Ç', 'Ãš': 'Ú', 'Ãƒ': 'Ã',
    'â€¢': '•', 'â€“': '–', 'â€”': '—',
    'â€œ': '“', 'â€\u009d': '”', 'â€™': '’', 'â€˜': '‘', 'â€¦': '…',
    'Âº': 'º', 'Âª': 'ª', 'Â°': '°',
    'ÃƒÂ¡': 'á', 'ÃƒÂ£': 'ã', 'ÃƒÂ©': 'é', 'ÃƒÂ­': 'í', 'ÃƒÂ³': 'ó',
    'ÃƒÂº': 'ú', 'ÃƒÂ§': 'ç', 'ÃƒÂµ': 'õ',
    'Ã‚Â': '',
    'Ã¢â‚¬â„¢': '’', 'Ã¢â‚¬Å“': '“', 'Ã¢â‚¬\u009d': '”',
    'Ã¢â‚¬Â¢': '•', 'Ã¢â‚¬â€œ': '—', 'Ã¢â‚¬Â¦': '…', 'Ã¢â‚¬â€°': '°',
  };

  var total = 0, arquivos = 0;
  for (final f in dir.listSync(recursive: true).whereType<File>()) {
    if (!f.path.endsWith('.dart')) continue;
    var original = f.readAsStringSync();
    var texto = original;
    var subAqui = 0;
    mapa.forEach((de, para) {
      final count = de.allMatches(texto).length;
      if (count > 0) { texto = texto.replaceAll(de, para); subAqui += count; }
    });
    if (subAqui > 0) {
      File('${f.path}.bak_mojibake').writeAsStringSync(original);
      f.writeAsStringSync(texto);
      arquivos++;
      total += subAqui;
      print('  ${f.path}: $subAqui substituicoes');
    }
  }
  print('Total: $total substituicoes em $arquivos arquivos.');
}