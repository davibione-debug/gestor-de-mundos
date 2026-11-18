
import "dart:io";

void main() async {
  final file = File("lib/screens/mapa/local_screen.dart");
  if (!await file.exists()) {
    print("Arquivo não encontrado!");
    return;
  }
  
  var lines = await file.readAsLines();
  int targetIndex = -1;

  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains("_local.itens.map")) {
      targetIndex = i;
      break;
    }
  }

  if (targetIndex == -1) {
    print("ERRO: _local.itens.map não encontrado.");
    return;
  }

  // Verifica se já tem o ...
  if (!lines[targetIndex].trim().startsWith("...")) {
    lines[targetIndex] = "...${lines[targetIndex].trim()}";
    await file.writeAsString(lines.join("\n"));
    print("SPREAD_ADICIONADO_COM_SUCESSO");
  } else {
    print("O spread já está presente.");
  }
}

