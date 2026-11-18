import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/npc.dart';

class NPCsRepository {
  static const String _chave = 'npcs';

  Future<List<NPC>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getStringList(_chave);

    if (dados == null || dados.isEmpty) {
      return [];
    }

    return dados
        .map(
          (npcJson) => NPC.fromMap(
            jsonDecode(npcJson) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> salvarTodos(List<NPC> npcs) async {
    final prefs = await SharedPreferences.getInstance();
    final dados = npcs
        .map(
          (npc) => jsonEncode(
            npc.toMap(),
          ),
        )
        .toList();

    await prefs.setStringList(_chave, dados);
  }

  Future<void> salvar(NPC npc) async {
    final npcs = await carregar();

    final indice = npcs.indexWhere(
      (existente) => existente.id == npc.id || existente.nome.trim().toLowerCase() == npc.nome.trim().toLowerCase(),
    );

    if (indice == -1) {
      npcs.add(npc);
    } else {
      npcs[indice] = npc;
    }

    await salvarTodos(npcs);
  }

  Future<void> remover(String id) async {
    final npcs = await carregar();
    npcs.removeWhere(
      (npc) => npc.id == id,
    );
    await salvarTodos(npcs);
  }

  Future<void> limpar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chave);
  }
}

