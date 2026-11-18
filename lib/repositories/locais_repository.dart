import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/evento.dart';
import '../models/local.dart';
import '../models/ponto_interesse.dart';
import 'package:flutter/foundation.dart';

class LocaisRepository {
  static const String _chave = 'locais';

  Future<List<Local>> carregar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dados = prefs.getStringList(_chave);

      if (dados == null || dados.isEmpty) {
        return [];
      }

      return dados
          .map(
            (localJson) => Local.fromMap(
              jsonDecode(localJson) as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint("Erro ao carregar locais: \$e");
      return [];
    }
  }

  Future<void> salvarTodos(List<Local> locais) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dados = locais
          .map(
            (local) => jsonEncode(
              local.toMap(),
            ),
          )
          .toList();

      await prefs.setStringList(_chave, dados);
    } catch (e) {
      debugPrint("Erro ao salvar todos os locais: \$e");
    }
  }

  Future<void> salvar(Local local) async {
    try {
      final locais = await carregar();

      final indice = locais.indexWhere(
        (existente) => existente.id == local.id,
      );

      if (indice == -1) {
        locais.add(local);
      } else {
        locais[indice] = local;
      }

      await salvarTodos(locais);
    } catch (e) {
      debugPrint("Erro ao salvar local individual: \$e");
    }
  }

  Future<void> remover(String id) async {
    try {
      final locais = await carregar();
      locais.removeWhere(
        (local) => local.id == id,
      );
      await salvarTodos(locais);
    } catch (e) {
      debugPrint("Erro ao remover local: \$e");
    }
  }

  Future<void> salvarEventoDoLocal(String localId, Evento evento) async {
    final locais = await carregar();
    final indice = locais.indexWhere((local) => local.id == localId);
    if (indice == -1) return;

    final mapa = locais[indice].toMap();
    final eventos = mapa['eventos'];
    final lista = eventos is List ? List<dynamic>.from(eventos) : <dynamic>[];
    final eventoMap = evento.toMap();

    final eventoIndice = lista.indexWhere(
        (item) => item is Map && item['id']?.toString() == evento.id);
    if (eventoIndice == -1) {
      lista.add(eventoMap);
    } else {
      lista[eventoIndice] = eventoMap;
    }

    mapa['eventos'] = lista;
    locais[indice] = Local.fromMap(mapa);
    await salvarTodos(locais);
  }

  Future<void> salvarEventoDoPonto(
      String localId, String pontoId, Evento evento) async {
    final locais = await carregar();
    final indice = locais.indexWhere((local) => local.id == localId);
    if (indice == -1) return;

    final mapa = locais[indice].toMap();
    final pontos = mapa['pontosInteresse'];
    if (pontos is! List) return;

    for (final ponto in pontos) {
      if (ponto is! Map || ponto['id']?.toString() != pontoId) continue;
      final eventos = ponto['eventos'];
      final lista = eventos is List ? List<dynamic>.from(eventos) : <dynamic>[];
      final eventoMap = evento.toMap();

      final eventoIndice = lista.indexWhere(
          (item) => item is Map && item['id']?.toString() == evento.id);
      if (eventoIndice == -1) {
        lista.add(eventoMap);
      } else {
        lista[eventoIndice] = eventoMap;
      }
      ponto['eventos'] = lista;
      break;
    }

    locais[indice] = Local.fromMap(mapa);
    await salvarTodos(locais);
  }

  Future<void> salvarPontoInteresse(
      String localId, PontoInteresse ponto) async {
    final locais = await carregar();
    final indice = locais.indexWhere((local) => local.id == localId);
    if (indice == -1) return;

    final mapa = locais[indice].toMap();
    final pontosRaw = mapa['pontosInteresse'];
    final pontos =
        pontosRaw is List ? List<dynamic>.from(pontosRaw) : <dynamic>[];
    final pontoMap = _pontoToMap(ponto);

    final pontoIndice = pontos.indexWhere(
        (item) => item is Map && item['id']?.toString() == ponto.id);
    if (pontoIndice == -1) {
      pontos.add(pontoMap);
    } else {
      pontos[pontoIndice] = pontoMap;
    }

    mapa['pontosInteresse'] = pontos;
    locais[indice] = Local.fromMap(mapa);
    await salvarTodos(locais);
  }

  Future<void> removerPontoInteresse(String localId, String pontoId) async {
    final locais = await carregar();
    final indice = locais.indexWhere((local) => local.id == localId);
    if (indice == -1) return;

    final mapa = locais[indice].toMap();
    final pontos = mapa['pontosInteresse'];
    if (pontos is List) {
      pontos.removeWhere(
          (ponto) => ponto is Map && ponto['id']?.toString() == pontoId);
    }

    locais[indice] = Local.fromMap(mapa);
    await salvarTodos(locais);
  }

  Future<void> removerEventoDoLocal(String localId, String eventoId) async {
    final locais = await carregar();
    final indice = locais.indexWhere((local) => local.id == localId);
    if (indice == -1) return;

    final mapa = locais[indice].toMap();
    final eventos = mapa['eventos'];
    if (eventos is List) {
      eventos.removeWhere(
          (evento) => evento is Map && evento['id']?.toString() == eventoId);
    }

    locais[indice] = Local.fromMap(mapa);
    await salvarTodos(locais);
  }

  Future<void> removerEventoDoPonto(
      String localId, String pontoId, String eventoId) async {
    final locais = await carregar();
    final indice = locais.indexWhere((local) => local.id == localId);
    if (indice == -1) return;

    final mapa = locais[indice].toMap();
    final pontos = mapa['pontosInteresse'];
    if (pontos is List) {
      for (final ponto in pontos) {
        if (ponto is Map && ponto['id']?.toString() == pontoId) {
          final eventos = ponto['eventos'];
          if (eventos is List) {
            eventos.removeWhere((evento) =>
                evento is Map && evento['id']?.toString() == eventoId);
          }
          break;
        }
      }
    }

    locais[indice] = Local.fromMap(mapa);
    await salvarTodos(locais);
  }

  Map<String, dynamic> _pontoToMap(PontoInteresse ponto) {
    return ponto.toMap();
  }

  Future<void> limpar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chave);
  }
}
