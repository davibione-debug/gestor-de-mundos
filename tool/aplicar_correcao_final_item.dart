
import "dart:io";

void main() async {
  final file = File("lib/screens/mapa/local_screen.dart");
  if (!await file.exists()) {
    print("Arquivo não encontrado!");
    return;
  }
  
  var content = await file.readAsString();

  // Substitui todo o trecho de mapeamento dos itens pelo correto e compatível com a classe Item
  // Vamos procurar onde começa o _local.itens.map e reescrever o bloco inteiro de forma limpa.
  
  // Vamos localizar o início do bloco de itens
  if (content.contains("_local.itens.map")) {
    // Substituição cirúrgica do bloco de mapeamento dos itens
    // Vamos usar uma regex para encontrar a listagem antiga de itens e substituir
    
    final regex = RegExp(r"\.\.\._local\.itens\.map\([\s\S]*?\)\.toList\(\)");
    
    const novoMapeamento = """..._local.itens.map((item) {
      final nome = item.nome;
      final descricao = item.descricao;
      final localizacao = item.localizacao.isNotEmpty ? item.localizacao : null;
      final tipo = item.tipo;
      final custo = item.custoEmCreditos;
      final efeito = item.efeito;

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
    }).toList()""";

    if (regex.hasMatch(content)) {
      content = content.replaceFirst(regex, novoMapeamento);
      await file.writeAsString(content);
      print("SUCESSO_ATUALIZACAO_ITENS_FINAL");
      return;
    }
  }

  print("AVISO: Padrao nao substituido automaticamente.");
}

