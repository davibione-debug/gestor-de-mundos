import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/criatura.dart';

class CriaturasRepository {
  static const String _chave = 'criaturas';

  Future<List<Criatura>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getStringList(_chave);

    if (dados == null || dados.isEmpty) {
      return [];
    }

    return dados
        .map(
          (criaturaJson) => Criatura.fromMap(
            jsonDecode(criaturaJson) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> salvarTodos(List<Criatura> criaturas) async {
    final prefs = await SharedPreferences.getInstance();
    final dados = criaturas
        .map(
          (criatura) => jsonEncode(
            criatura.toMap(),
          ),
        )
        .toList();

    await prefs.setStringList(_chave, dados);
  }

  Future<void> salvar(Criatura criatura) async {
    final criaturas = await carregar();

    final indice = criaturas.indexWhere(
      (existente) =>
          existente.id.trim().toLowerCase() == criatura.id.trim().toLowerCase() ||
          existente.nome.trim().toLowerCase() == criatura.nome.trim().toLowerCase(),
    );

    if (indice == -1) {
      criaturas.add(criatura);
    } else {
      criaturas[indice] = criatura;
    }

    await salvarTodos(criaturas);
  }

  Future<Criatura?> buscarPorId(String id) async {
    final criaturas = await carregar();
    for (final criatura in criaturas) {
      if (criatura.id == id) {
        return criatura;
      }
    }
    return null;
  }

  Future<void> remover(String id) async {
    final criaturas = await carregar();
    criaturas.removeWhere(
      (criatura) => criatura.id == id,
    );
    await salvarTodos(criaturas);
  }

  Future<void> limpar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chave);
  }
}