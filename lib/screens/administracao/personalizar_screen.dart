import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalizarScreen extends StatefulWidget {
  const PersonalizarScreen({super.key});

  @override
  State<PersonalizarScreen> createState() => _PersonalizarScreenState();
}

class _PersonalizarScreenState extends State<PersonalizarScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para cada campo
  final _appTituloController = TextEditingController();
  final _appSubtituloController = TextEditingController();
  final _menuMapaController = TextEditingController();
  final _menuBestiarioController = TextEditingController();
  final _menuPersonagensController = TextEditingController();
  final _menuItensController = TextEditingController();
  final _menuCriaturasController = TextEditingController();
  final _menuAliadosController = TextEditingController();
  final _menuInimigosController = TextEditingController();
  final _nomePersonagemController = TextEditingController();
  final _nomeCriaturaController = TextEditingController();

  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _appTituloController.dispose();
    _appSubtituloController.dispose();
    _menuMapaController.dispose();
    _menuBestiarioController.dispose();
    _menuPersonagensController.dispose();
    _menuItensController.dispose();
    _menuCriaturasController.dispose();
    _menuAliadosController.dispose();
    _menuInimigosController.dispose();
    _nomePersonagemController.dispose();
    _nomeCriaturaController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _appTituloController.text = prefs.getString('app_titulo') ?? 'Painel do Mestre';
      _appSubtituloController.text = prefs.getString('app_subtitulo') ?? 'Escolha uma ferramenta';
      _menuMapaController.text = prefs.getString('menu_mapa') ?? 'Mapa';
      _menuBestiarioController.text = prefs.getString('menu_Bestiário') ?? 'Bestiário';
      _menuPersonagensController.text = prefs.getString('menu_personagens') ?? 'Personagens';
      _menuItensController.text = prefs.getString('menu_itens') ?? 'Itens';
      _menuCriaturasController.text = prefs.getString('menu_criaturas') ?? 'Criaturas';
      _menuAliadosController.text = prefs.getString('menu_aliados') ?? 'Aliados';
      _menuInimigosController.text = prefs.getString('menu_inimigos') ?? 'Inimigos';
      _nomePersonagemController.text = prefs.getString('nome_personagem') ?? 'Personagem';
      _nomeCriaturaController.text = prefs.getString('nome_criatura') ?? 'Criatura';
      _carregando = false;
    });
  }

    Future<void> _salvarString(SharedPreferences prefs, String chave, String valor) async {
    final texto = valor.trim();
    if (texto.isEmpty) {
      await prefs.remove(chave);
    } else {
      await prefs.setString(chave, texto);
    }
  }
Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      
      await _salvarString(prefs, 'app_titulo', _appTituloController.text);
      await _salvarString(prefs, 'app_subtitulo', _appSubtituloController.text);
      await _salvarString(prefs, 'menu_mapa', _menuMapaController.text);
      await _salvarString(prefs, 'menu_Bestiário', _menuBestiarioController.text);
      await _salvarString(prefs, 'menu_personagens', _menuPersonagensController.text);
      await _salvarString(prefs, 'menu_itens', _menuItensController.text);
      await _salvarString(prefs, 'menu_criaturas', _menuCriaturasController.text);
      await _salvarString(prefs, 'menu_aliados', _menuAliadosController.text);
      await _salvarString(prefs, 'menu_inimigos', _menuInimigosController.text);
      await _salvarString(prefs, 'nome_personagem', _nomePersonagemController.text);
      await _salvarString(prefs, 'nome_criatura', _nomeCriaturaController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configurações salvas com sucesso!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Widget _campo(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _secao(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        titulo,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Personalizar')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _secao('Geral'),
            _campo('Título do App', _appTituloController),
            _campo('Subtítulo do App', _appSubtituloController),
            
            _secao('Menus'),
            _campo('Menu Mapa', _menuMapaController),
            _campo('Menu Bestiário', _menuBestiarioController),
            _campo('Menu Personagens', _menuPersonagensController),
            _campo('Menu Itens', _menuItensController),
            _campo('Menu Criaturas', _menuCriaturasController),
            _campo('Menu Aliados', _menuAliadosController),
            _campo('Menu Inimigos', _menuInimigosController),
            
            _secao('Termos'),
            _campo('Termo para Personagem', _nomePersonagemController),
            _campo('Termo para Criatura', _nomeCriaturaController),
            
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: _salvando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
                label: Text(_salvando ? 'Salvando...' : 'Salvar Configurações'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
