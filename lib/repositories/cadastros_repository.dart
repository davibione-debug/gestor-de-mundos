import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/evento.dart';
import '../models/ponto_interesse.dart';

class CadastrosRepository {
  static const String _chaveEventos = 'cadastros_eventos';
  static const String _chavePontos = 'cadastros_pontos_interesse';

  Future<List<Evento>> carregarEventos() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getStringList(_chaveEventos);

    if (dados == null || dados.isEmpty) {
      return [];
    }

    return dados
        .map(
          (item) => Evento.fromMap(
            jsonDecode(item) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> salvarEvento(Evento evento) async {
    final prefs = await SharedPreferences.getInstance();
    final eventos = await carregarEventos();
    final indice = eventos.indexWhere(
      (item) => item.id == evento.id,
    );

    if (indice == -1) {
      eventos.add(evento);
    } else {
      eventos[indice] = evento;
    }

    await prefs.setStringList(
      _chaveEventos,
      eventos.map((item) => jsonEncode(item.toMap())).toList(),
    );
  }

  Future<void> removerEvento(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final eventos = await carregarEventos();
    eventos.removeWhere((item) => item.id == id);

    await prefs.setStringList(
      _chaveEventos,
      eventos.map((item) => jsonEncode(item.toMap())).toList(),
    );
  }

  Future<List<PontoInteresse>> carregarPontos() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getStringList(_chavePontos);

    if (dados == null || dados.isEmpty) {
      return [];
    }

    return dados
        .map(
          (item) => PontoInteresse.fromMap(
            jsonDecode(item) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> salvarPonto(PontoInteresse ponto) async {
    final prefs = await SharedPreferences.getInstance();
    final pontos = await carregarPontos();
    final indice = pontos.indexWhere(
      (item) => item.id == ponto.id,
    );

    if (indice == -1) {
      pontos.add(ponto);
    } else {
      pontos[indice] = ponto;
    }

    await prefs.setStringList(
      _chavePontos,
      pontos.map((item) => jsonEncode(item.toMap())).toList(),
    );
  }

  Future<void> removerPonto(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final pontos = await carregarPontos();
    pontos.removeWhere((item) => item.id == id);

    await prefs.setStringList(
      _chavePontos,
      pontos.map((item) => jsonEncode(item.toMap())).toList(),
    );
  }
}

