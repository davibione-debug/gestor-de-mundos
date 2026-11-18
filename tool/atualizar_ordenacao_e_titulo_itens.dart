
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

  print("Encontrado na linha ${targetIndex + 1}. Atualizando ordenação e título...");

  final novoBloco = [
    "...(() {",
    "  final itensOrdenados = List.from(_local.itens);",
    "  itensOrdenados.sort((a, b) {",
    "    int extrairNumero(String s) {",
    "      final reg = RegExp(r\"\\d+\");",
    "      final match = reg.firstMatch(s);",
    "      return match != null ? int.parse(match.group(0)!) : 0;",
    "    }",
    "    return extrairNumero(a.localizacao ?? \"\").compareTo(extrairNumero(b.localizacao ?? \"\"));",
    "  });",
    "  return itensOrdenados.map((item) {",
    "    final nome = item.nome ?? \"Item sem nome\";",
    "    final descricao = item.descricao ?? \"\";",
    "    final localizacao = (item.localizacao != null && item.localizacao.toString().isNotEmpty) ? item.localizacao.toString() : \"\";",
    "    final tituloCard = localizacao.isNotEmpty ? \"\$localizacao: \$nome\" : nome;",
    "    final tipo = item.tipo ?? \"\";",
    "    final custo = item.custoEmCreditos ?? 0;",
    "    final efeito = item.efeito ?? \"\";",
    "",
    "    return Card(",
    "      margin: const EdgeInsets.only(bottom: 8),",
    "      child: ListTile(",
    "        leading: const Icon(Icons.card_giftcard, color: Colors.orange),",
    "        title: Text(tituloCard, style: const TextStyle(fontWeight: FontWeight.bold)),",
    "        subtitle: Column(",
    "          crossAxisAlignment: CrossAxisAlignment.start,",
    "          children: [",
    "            if (descricao.isNotEmpty)",
    "              Text(descricao, maxLines: 2, overflow: TextOverflow.ellipsis),",
    "          ],",
    "        ),",
    "        trailing: const Icon(Icons.chevron_right, color: Colors.grey),",
    "        onTap: () {",
    "          showDialog(",
    "            context: context,",
    "            builder: (ctx) => AlertDialog(",
    "              title: Text(tituloCard),",
    "              content: SingleChildScrollView(",
    "                child: ListBody(",
    "                  children: [",
    "                    if (localizacao.isNotEmpty) ...[",
    "                      Text(\"Localização: \$localizacao\", style: const TextStyle(fontWeight: FontWeight.bold)),",
    "                      const SizedBox(height: 8),",
    "                    ],",
    "                    if (tipo.isNotEmpty) Text(\"Tipo: \$tipo\"),",
    "                    if (custo > 0) Text(\"Custo: \$custo créditos\"),",
    "                    const SizedBox(height: 8),",
    "                    const Text(\"Descrição:\", style: TextStyle(fontWeight: FontWeight.bold)),",
    "                    Text(descricao.isEmpty ? \"Sem descrição.\" : descricao),",
    "                    if (efeito.isNotEmpty) ...[",
    "                      const SizedBox(height: 8),",
    "                      const Text(\"Efeito:\", style: TextStyle(fontWeight: FontWeight.bold)),",
    "                      Text(efeito),",
    "                    ],",
    "                  ],",
    "                ),",
    "              ),",
    "              actions: [",
    "                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text(\"Fechar\")),",
    "              ],",
    "            ),",
    "          );",
    "        },",
    "      ),",
    "    );",
    "  }).toList();",
    "})()"
  ];

  int endIdx = targetIndex;
  int bracketCount = 0;
  bool started = false;

  for (int i = targetIndex; i < lines.length; i++) {
    for (int c = 0; c < lines[i].length; c++) {
      String char = lines[i][c];
      if (char == "(") {
        bracketCount++;
        started = true;
      } else if (char == ")") {
        bracketCount--;
      }
    }
    if (started && bracketCount == 0) {
      endIdx = i;
      break;
    }
  }

  if (endIdx >= targetIndex) {
    lines.removeRange(targetIndex, endIdx + 1);
    lines.insertAll(targetIndex, novoBloco);
    await file.writeAsString(lines.join("\\n"));
    print("ORDENACAO_E_TITULO_ATUALIZADOS_COM_SUCESSO");
  } else {
    print("ERRO ao delimitar o bloco.");
  }
}

