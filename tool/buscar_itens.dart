
import "dart:io";
void main() async {
  final lines = await File("lib/screens/mapa/local_screen.dart").readAsLines();
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains("item") || lines[i].contains("Item") || lines[i].contains("itens")) {
      print("Linha ${i + 1}: ${lines[i]}");
    }
  }
}

