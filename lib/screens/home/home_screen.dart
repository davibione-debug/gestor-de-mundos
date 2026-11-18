import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_colors.dart';
import '../../widgets/context_selector.dart';
import '../administracao/administracao_screen.dart';
import '../itens/itens_screen.dart';
import '../mapa/mapa_screen.dart';
import '../bestiario/bestiario_screen.dart';
import '../treinadores/treinadores_screen.dart';
import '../registros/registros_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _menuBestiario = 'Bestiário';
  String _menuMapa = 'Mapa';
  String _menuItens = 'Itens';
  String _appTitulo = 'Painel do Mestre';
  String _appSubtitulo = 'Escolha uma ferramenta';
  String _menuPersonagens = 'Personagens';
  String _menuRegistros = 'Registros';

  @override
  void initState() {
    super.initState();
    _carregarConfiguracao();
  }

  Future<void> _carregarConfiguracao() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _menuBestiario =
          prefs.getString('menu_bestiario')?.trim().isNotEmpty == true
              ? prefs.getString('menu_bestiario')!.trim()
              : 'Bestiário';

      _appTitulo =
          prefs.getString('app_titulo')?.trim().isNotEmpty == true
              ? prefs.getString('app_titulo')!.trim()
              : 'Painel do Mestre';

      _appSubtitulo =
          prefs.getString('app_subtitulo')?.trim().isNotEmpty == true
              ? prefs.getString('app_subtitulo')!.trim()
              : 'Escolha uma ferramenta';

      _menuMapa =
          prefs.getString('menu_mapa')?.trim().isNotEmpty == true
              ? prefs.getString('menu_mapa')!.trim()
              : 'Mapa';

      _menuItens =
          prefs.getString('menu_itens')?.trim().isNotEmpty == true
              ? prefs.getString('menu_itens')!.trim()
              : 'Itens';

      _menuRegistros =
          prefs.getString('menu_registros')?.trim().isNotEmpty == true
              ? prefs.getString('menu_registros')!.trim()
              : 'Registros';

      _menuPersonagens =
          prefs.getString('menu_personagens')?.trim().isNotEmpty == true
              ? prefs.getString('menu_personagens')!.trim()
              : 'Personagens';
    });
  }

  Future<void> _abrirAdministracao() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const AdministracaoScreen(),
      ),
    );

    await _carregarConfiguracao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Mundo'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: ContextSelector(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          Text(
            _appTitulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: PTColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _appSubtitulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: PTColors.subtitle,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          
          // ===== MAPA (Botao Principal - Grande) =====
          SizedBox(
            height: 110,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const MapaScreen()),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map, size: 44),
                  const SizedBox(height: 8),
                  Text(
                    _menuMapa,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // ===== GRADE 2x2 (Botoes Menores) =====
          Row(
            children: [
              Expanded(
                child: _menuCard(context, Icons.menu_book, _menuBestiario, const PokedexScreen()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _menuCard(context, Icons.person, _menuPersonagens, const TreinadoresScreen()),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _menuCard(context, Icons.backpack, _menuItens, const ItensScreen()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _menuCard(context, Icons.mic, _menuRegistros, const RegistrosScreen()),
              ),
            ],
          ),
          
          const SizedBox(height: 25),
          const Divider(),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: SizedBox(
              height: 60,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text('Administração'),
                onPressed: _abrirAdministracao,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _menuCard(
    BuildContext context,
    IconData icon,
    String texto,
    Widget tela,
  ) {
    return SizedBox(
      height: 120,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => tela),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}