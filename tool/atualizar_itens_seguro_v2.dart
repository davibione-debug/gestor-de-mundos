
import "dart:io";

void main() async {
  final file = File("lib/screens/mapa/local_screen.dart");
  if (!await file.exists()) {
    print("Arquivo não encontrado!");
    return;
  }
  
  var content = await file.readAsString();

  // Vamos procurar onde a seção de itens é renderizada no arquivo local_screen.dart
  // Procuramos por "Itens" e o .map dos itens
  if (!content.contains("Itens") || !content.contains("itens.map")) {
    print("ERRO: Seção de itens não encontrada no arquivo.");
    return;
  }

  // O bloco limpo, ordenado por légua e com o formato exato "Légua X: Nome"
  const blocoItensNovo = """...(() {
    final itensOrdenados = List.from(_local.itens);
    itensOrdenados.sort((a, b) {
      int extrairNumero(String s) {
        final reg = RegExp(r"\\d+");
        final match = reg.firstMatch(s);
        return match != null ? int.parse(match.group(0)!) : 0;
      }
      return extrairNumero(a.localizacao ?? "").compareTo(extrairNumero(b.localizacao ?? ""));
    });
    return itensOrdenados.map((item) {
      final nome = item.nome ?? "Item sem nome";
      final descricao = item.descricao ?? "";
      final localizacao = (item.localizacao != null && item.localizacao.toString().isNotEmpty) ? item.localizacao.toString() : "";
      final tituloCard = localizacao.isNotEmpty ? "\$localizacao: \$nome" : nome;
      final tipo = item.tipo ?? "";
      final custo = item.custoEmCreditos ?? 0;
      final efeito = item.efeito ?? "";

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(Icons.card_giftcard, color: Colors.orange),
          title: Text(tituloCard, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (descricao.isNotEmpty)
                Text(descricao, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(tituloCard),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      if (localizacao.isNotEmpty) ...[
                        Text("Localização: \$localizacao", style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                      ],
                      if (tipo.isNotEmpty) Text("Tipo: \$tipo"),
                      if (custo > 0) Text("Custo: \$custo créditos"),
                      const SizedBox(height: 8),
                      const Text("Descrição:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(descricao.isEmpty ? "Sem descrição." : descricao),
                      if (efeito.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text("Efeito:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(efeito),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Fechar")),
                ],
              ),
            );
          },
        ),
      );
    }).toList();
  })()""";

  // Encontra o trecho atual do .map de itens para substituir com precisão
  int startMap = content.indexOf("_local.itens.map");
  if (startMap == -1) {
    startMap = content.indexOf("itens.map");
  }

  if (startMap != -1) {
    // Vamos procurar o .toList() correspondente após o map
    int endMap = content.indexOf(".toList()", startMap);
    if (endMap != -1) {
      int realStart = startMap;
      if (startMap >= 3 && content.substring(startMap - 3, startMap) == "...") {
        realStart = startMap - 3;
      }

      String trechoAntigo = content.substring(realStart, endMap + 9);
      content = content.replaceFirst(trechoAntigo, blocoItensNovo);

      await file.writeAsString(content);
      print("ITENS_ATUALIZADOS_COM_SUCESSO");
      return;
    }
  }

  print("AVISO: Não foi possível delimitar o trecho automaticamente.");
}

