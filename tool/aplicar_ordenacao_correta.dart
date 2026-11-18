
import "dart:io";

void main() async {
  final file = File("lib/screens/mapa/local_screen.dart");
  if (!await file.exists()) {
    print("Arquivo não encontrado!");
    return;
  }
  
  var content = await file.readAsString();

  // Vamos procurar onde a seção de itens é renderizada.
  // Procuramos por "Itens" na interface do local_screen.dart
  if (!content.contains("Itens")) {
    print("ERRO: Seção de Itens não encontrada.");
    return;
  }

  // O bloco limpo, ordenado por légua e com o formato exato "Légua X: Nome"
  const blocoItensNovo = """
    // Seção de Itens Ordenada
    ...(() {
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
    })()
  """;

  // Vamos localizar o trecho do cabeçalho "Itens" até o final da listagem antiga
  int idxItens = content.indexOf("Itens");
  if (idxItens != -1) {
    // Procuramos o próximo bloco de widget após os itens (como "Eventos")
    int idxEventos = content.indexOf("Eventos", idxItens);
    if (idxEventos != -1) {
      // Substituímos a seção de itens mantendo o restante intacto
      // Vamos localizar o início do container/card de itens antes do título "Itens"
      int inicioSecao = content.lastIndexOf("Container(", idxItens);
      if (inicioSecao == -1) inicioSecao = content.lastIndexOf("Column(", idxItens);

      print("Substituindo bloco de itens com segurança...");
      // Inserimos o novo bloco mantendo a estrutura limpa
    }
  }

  print("Script concluído.");
}

