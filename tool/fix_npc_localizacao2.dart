import 'dart:io';

void main() {
  final path = 'lib/screens/npcs/npc_localizacao.dart';
  var src = File(path).readAsStringSync();
  final temCRLF = src.contains('\r\n');
  if (temCRLF) src = src.replaceAll('\r\n', '\n');

  // Localiza as três linhas que usam evento.npc e substitui por lista
  src = src.replaceAll(
    "      if (referenciaEstaNPC(evento.npc)) {\n        adicionar('Evento', evento);\n        localTemReferencia = true;\n      }",
    "      if (eventoTemNPC(evento, nomeAtual)) {\n        adicionar('Evento', evento);\n        localTemReferencia = true;\n      }",
  );

  src = src.replaceAll(
    "        if (referenciaEstaNPC(evento.npc)) {\n          adicionar('Evento', evento);\n          localTemReferencia = true;\n        }",
    "        if (eventoTemNPC(evento, nomeAtual)) {\n          adicionar('Evento', evento);\n          localTemReferencia = true;\n        }",
  );

  src = src.replaceAll(
    "      if (referenciaEstaNPC(evento.npc)) {\n        adicionar('Evento', evento);\n      }",
    "      if (eventoTemNPC(evento, nomeAtual)) {\n        adicionar('Evento', evento);\n      }",
  );

  // Adiciona o helper eventoTemNPC antes de buscarLocalizacoesDoNPC
  if (!src.contains('bool eventoTemNPC(')) {
    src = src.replaceFirst(
      'Future<List<ReferenciaLocalizacaoNPC>> buscarLocalizacoesDoNPC(NPC npc) async {',
      '''bool eventoTemNPC(Evento evento, String nomeAtual) {
  bool contem(String id) {
    return id.trim().toLowerCase() == nomeAtual;
  }

  return evento.aliados.any(contem) || evento.inimigos.any(contem);
}

Future<List<ReferenciaLocalizacaoNPC>> buscarLocalizacoesDoNPC(NPC npc) async {''',
    );
  }

  if (temCRLF) src = src.replaceAll('\n', '\r\n');
  File(path).writeAsStringSync(src);
  print('npc_localizacao.dart ajustado.');
}