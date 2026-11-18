
import "dart:io";

void main() async {
  final file = File("lib/screens/mapa/local_screen.dart");
  if (!await file.exists()) {
    print("Erro: local_screen.dart não encontrado!");
    return;
  }
  
  var content = await file.readAsString();

  // Verifica se já existe o método _buildItemCard, se não, adiciona na classe
  const cardWidget = """
  Widget _buildItemCard(BuildContext context, dynamic item) {
    final nome = item.nome ?? "Item sem nome";
    final descricao = item.descricao ?? "";
    final localizacao = (item.localizacao != null && item.localizacao.toString().isNotEmpty) ? item.localizacao.toString() : null;

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
                    if (item.tipo != null) Text("Tipo: \${item.tipo}"),
                    if (item.raridade != null) Text("Raridade: \${item.raridade}"),
                    if (item.custo != null) Text("Custo: \${item.custo}"),
                    const SizedBox(height: 8),
                    const Text("Descrição:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(descricao.isEmpty ? "Sem descrição." : descricao),
                    if (item.efeito != null) ...[
                      const SizedBox(height: 8),
                      const Text("Efeito:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(item.efeito.toString()),
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
  }
""";

  if (!content.contains("_buildItemCard")) {
    final idx = content.lastIndexOf("}");
    if (idx != -1) {
      content = "${content.substring(0, idx)}\n\n$cardWidget\n\n}\n";
    }
  }

  // Substitui a listagem de itens antiga pelo builder do card
  // Procuramos por padrões comuns de mapeamento de itens na tela
  content = content.replaceAll(
    RegExp(r"local\.itens\.map\([\s\S]*?\)\.toList\(\)"),
    "local.itens.map((item) => _buildItemCard(context, item)).toList()",
  );

  await file.writeAsString(content);
  print("DART_ATUALIZACAO_CONCLUIDA");
}

