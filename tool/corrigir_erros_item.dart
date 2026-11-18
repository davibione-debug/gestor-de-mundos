
import "dart:io";

void main() async {
  // 1. Inspeciona o model Item para ver os campos reais
  final itemFile = File("lib/models/item.dart");
  if (await itemFile.exists()) {
    print("--- CONTEUDO DE item.dart ---");
    print(await itemFile.readAsString());
    print("-----------------------------");
  }

  // 2. Corrige o local_screen.dart
  final file = File("lib/screens/mapa/local_screen.dart");
  if (!await file.exists()) {
    print("Arquivo local_screen.dart não encontrado!");
    return;
  }
  
  var content = await file.readAsString();

  // Substitui o bloco problemático por um Column seguro com os campos reais do Item
  // Vamos procurar onde está o mapeamento dos itens e substituir de forma limpa
  
  // Vamos criar um padrão robusto para o bloco de itens
  const novoBlocoItens = """
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: _local.itens.map((item) {
    final nome = item.nome ?? "Item sem nome";
    final descricao = item.descricao ?? "";
    final localizacao = (item.localizacao != null && item.localizacao.toString().isNotEmpty) ? item.localizacao.toString() : null;
    final tipo = item.tipo ?? "";
    final custo = item.custoEmCreditos?.toString();
    final efeito = item.efeito ?? "";

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.card_giftcard, color: Colors.orange),
        title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (localizacao != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Text("Localização: \$localizacao", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.brown)),
              ),
            if (descricao.isNotEmpty)
              Text(descricao, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(nome),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    if (localizacao != null) ...[
                      Text("Localização: \$localizacao", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                    ],
                    if (tipo.isNotEmpty) Text("Tipo: \$tipo"),
                    if (custo != null && custo != "0") Text("Custo: \$custo créditos"),
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
  }).toList(),
)
""";

  // Substitui a seção onde os itens são renderizados no local_screen.dart
  // Vamos buscar onde começa o map de itens
  if (content.contains("_local.itens.map")) {
    // Encontra o início do trecho dos itens e substitui de forma segura
    final startIdx = content.indexOf("_local.itens.map");
    // Vamos procurar o fechamento do map/toList
    // Para garantir, vamos usar uma substituição baseada em regex no bloco de renderização dos itens
    print("Encontrado _local.itens.map para substituição limpa.");
  }

  print("Script de analise concluido.");
}

