
import "dart:io";

void main() async {
  final file = File("lib/screens/mapa/local_screen.dart");
  if (!await file.exists()) {
    print("Arquivo não encontrado!");
    return;
  }
  
  var content = await file.readAsString();

  // Remove o _buildItemCard solto anterior se existir
  if (content.contains("_buildItemCard")) {
    final reg = RegExp(r"Widget _buildItemCard\([\s\S]*?\n\s{2}\}\n");
    content = content.replaceFirst(reg, "");
  }

  // O card limpo e idêntico ao padrão de eventos, construído direto na listagem
  const novoMapeamentoItens = """
_local.itens.map((item) {
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
                      }).toList()
""";

  // Substitui o bloco antigo de exibição de itens na marra pelo novo mapeamento seguro
  if (content.contains("..._local.itens.map(")) {
    // Vamos achar o bloco exato do map de itens
    final startIdx = content.indexOf("..._local.itens.map(");
    // Encontra o fecho correspondente .toList()
    final endIdx = content.indexOf(".toList()", startIdx);
    if (startIdx != -1 && endIdx != -1) {
      final blocoAntigo = content.substring(startIdx, endIdx + 9);
      content = content.replaceFirst(blocoAntigo, "...$novoMapeamentoItens");
      await file.writeAsString(content);
      print("TELA_ATUALIZADA_COM_SUCESSO");
      return;
    }
  }

  print("AVISO: Padrao exato nao encontrado para substituicao direta.");
}

