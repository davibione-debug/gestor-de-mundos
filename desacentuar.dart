import 'dart:io';

void main() {
  final file = File('lib/screens/administracao/personalizar_screen.dart');
  var content = file.readAsStringSync();
  final original = content;

  String u(List<int> c) => String.fromCharCodes(c);

  // Troca TODOS os identificadores acentuados por versões sem acento
  final mapa = <String, String>{
    '_appT' + u([0xED]) + 'tuloController': '_appTituloController',
    '_appSubt' + u([0xED]) + 'tuloController': '_appSubtituloController',
    '_menuBesti' + u([0xE1]) + 'rioController': '_menuBestiarioController',
    // Caso o PowerShell tenha corrompido pra 'Ã­' (U+00C3 + U+00AD)
    '_appT' + u([0xC3, 0xAD]) + 'tuloController': '_appTituloController',
    '_appSubt' + u([0xC3, 0xAD]) + 'tuloController': '_appSubtituloController',
    '_menuBesti' + u([0xC3, 0xA1]) + 'rioController': '_menuBestiarioController',
  };

  for (final e in mapa.entries) {
    content = content.replaceAll(e.key, e.value);
  }

  if (content != original) {
    file.writeAsStringSync(content);
    print('Identificadores desacentuados.');
  } else {
    print('Nenhuma substituicao feita.');
  }
}