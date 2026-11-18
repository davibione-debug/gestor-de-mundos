import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/registro.dart';

class RegistrosRepository {
  static const _chave = 'registros_salvos';

  Future<List<Registro>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_chave);
    
    if (jsonString == null || jsonString.isEmpty) return [];
    
    try {
      final List<dynamic> lista = jsonDecode(jsonString);
      return lista.map((e) => Registro.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> salvar(List<Registro> registros) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(registros.map((e) => e.toJson()).toList());
    await prefs.setString(_chave, jsonString);
  }
}