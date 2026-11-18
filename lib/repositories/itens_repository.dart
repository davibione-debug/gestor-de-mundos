import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item.dart';

class ItensRepository {
  static const String _chave = 'itens';

  Future<List<Item>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getStringList(_chave);

    if (dados == null || dados.isEmpty) {
      return [];
    }

    return dados
        .map(
          (itemJson) => Item.fromMap(
            jsonDecode(itemJson) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> salvarTodos(List<Item> itens) async {
    final prefs = await SharedPreferences.getInstance();
    final dados = itens
        .map(
          (item) => jsonEncode(item.toMap()),
        )
        .toList();

    await prefs.setStringList(_chave, dados);
  }

  Future<void> salvar(Item item) async {
    final itens = await carregar();

    final indice = itens.indexWhere(
      (existente) =>
          existente.nome.trim().toLowerCase() == item.nome.trim().toLowerCase(),
    );

    if (indice == -1) {
      itens.add(item);
    } else {
      itens[indice] = item;
    }

    await salvarTodos(itens);
  }

  Future<void> remover(String nome) async {
    final itens = await carregar();
    itens.removeWhere(
      (item) => item.nome.trim().toLowerCase() == nome.trim().toLowerCase(),
    );
    await salvarTodos(itens);
  }

  Future<void> limpar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chave);
  }
}