
import "dart:io";

void main() async {
  final file = File("lib/screens/mapa/local_screen.dart");
  if (!await file.exists()) {
    print("Arquivo não encontrado!");
    return;
  }
  
  var content = await file.readAsString();

  // Substitui o bloco antigo de exibição direta dos itens pelo uso do _buildItemCard
  // Vamos procurar o trecho que começa em ..._local.itens.map e vai até o fechamento do Card
  final regexBlocoAntigo = RegExp(
    r"\.\.\._local\.itens\.map\([\s\S]*?\(item\) => Card\([\s\S]*?\),\s*\)\.toList\(\)",
    multiLine: true,
  );

  if (regexBlocoAntigo.hasMatch(content)) {
    content = content.replaceFirst(
      regexBlocoAntigo,
      "_local.itens.map((item) => _buildItemCard(context, item)).toList()",
    );
    await file.writeAsString(content);
    print("RENDERIZACAO_CORRIGIDA_COM_SUCESSO");
  } else {
    print("AVISO: O bloco exato não foi encontrado por regex, aplicando substituição ampla...");
    
    // Alternativa: substituir a linha de mapeamento diretamente
    if (content.contains("..._local.itens.map(")) {
      // Substitui o miolo do map pelo builder correto
      content = content.replaceAll(
        RegExp(r"\.\.\._local\.itens\.map\([\s\S]*?\},?\s*\)\.toList\(\)"),
        "_local.itens.map((item) => _buildItemCard(context, item)).toList()",
      );
      await file.writeAsString(content);
      print("SUBSTITUICAO_AMPLA_CONCLUIDA");
    } else {
      print("ERRO: Nao foi possivel localizar o mapeamento de _local.itens");
    }
  }
}

