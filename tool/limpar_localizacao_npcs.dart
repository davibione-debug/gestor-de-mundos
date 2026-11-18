import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final prefs = await SharedPreferences.getInstance();
  final dados = prefs.getStringList('npcs');
  if (dados == null || dados.isEmpty) {
    print('Nenhum NPC salvo.');
    return;
  }

  var limpos = 0;
  final atualizados = <String>[];
  for (final jsonStr in dados) {
    final mapa = jsonDecode(jsonStr) as Map<String, dynamic>;
    if ((mapa['localizacao'] ?? '').toString().trim().isNotEmpty) {
      mapa['localizacao'] = '';
      limpos++;
    }
    atualizados.add(jsonEncode(mapa));
  }

  await prefs.setStringList('npcs', atualizados);
  print('NPCs com localizacao limpa: $limpos');
}