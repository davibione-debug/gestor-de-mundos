import 'package:flutter/material.dart';

import '../../models/item.dart';
import '../../repositories/itens_repository.dart';

class ItemEditarScreen extends StatefulWidget {
  final Item item;
  final bool novo;

  const ItemEditarScreen({
    super.key,
    required this.item,
    this.novo = false,
  });

  @override
  State<ItemEditarScreen> createState() => _ItemEditarScreenState();
}

class _ItemEditarScreenState extends State<ItemEditarScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _tipoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _custoController = TextEditingController();
  final _efeitoController = TextEditingController();

  final ItensRepository _repository = ItensRepository();

  bool _salvando = false;

  @override
  void initState() {
    super.initState();

    _nomeController.text = widget.item.nome;
    _tipoController.text = widget.item.tipo;
    _descricaoController.text = widget.item.descricao;
    _custoController.text = widget.item.custoEmCreditos.toString();
    _efeitoController.text = widget.item.efeito;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _tipoController.dispose();
    _descricaoController.dispose();
    _custoController.dispose();
    _efeitoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_salvando || !_formKey.currentState!.validate()) {
      return;
    }

    final custo = int.tryParse(
      _custoController.text.trim(),
    );

    if (custo == null || custo < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um custo válido.'),
        ),
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    final item = Item(
      nome: _nomeController.text.trim(),
      tipo: _tipoController.text.trim(),
      descricao: _descricaoController.text.trim(),
      custoEmCreditos: custo,
      efeito: _efeitoController.text.trim(),
      localizacao: widget.item.localizacao,
      quantidade: widget.item.quantidade,
    );

    try {
      final existente = await _repository.carregar();

      if (!mounted) {
        return;
      }

      final nomeOriginal = widget.item.nome.trim().toLowerCase();
      final nomeNovo = item.nome.trim().toLowerCase();

      final duplicado = existente.any(
        (outro) =>
            outro.nome.trim().toLowerCase() == nomeNovo &&
            (widget.novo || outro.nome.trim().toLowerCase() != nomeOriginal),
      );

      if (duplicado) {
        setState(() {
          _salvando = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Já existe um item com esse nome.'),
          ),
        );
        return;
      }

      if (!widget.novo && nomeNovo != nomeOriginal) {
        await _repository.remover(widget.item.nome);
      }

      await _repository.salvar(item);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop<Item>(item);
    } catch (e, stackTrace) {
      debugPrint('[ERRO AO SALVAR ITEM] $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        _salvando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível salvar o item: $e'),
          duration: const Duration(seconds: 10),
        ),
      );
    }
  }

  InputDecoration _decoracao({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titulo = widget.novo ? 'Adicionar Item' : 'Editar Item';

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        actions: [
          IconButton(
            tooltip: 'Salvar',
            onPressed: _salvando ? null : _salvar,
            icon: _salvando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            TextFormField(
              controller: _nomeController,
              textCapitalization: TextCapitalization.words,
              decoration: _decoracao(
                label: 'Nome',
                hint: 'Nome do item',
                icon: Icons.inventory_2_outlined,
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Informe o nome do item.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _tipoController,
              textCapitalization: TextCapitalization.words,
              decoration: _decoracao(
                label: 'Tipo',
                hint: 'Ex.: Cura, Equipamento...',
                icon: Icons.category_outlined,
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Informe o tipo do item.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _custoController,
              keyboardType: TextInputType.number,
              decoration: _decoracao(
                label: 'Custo',
                hint: '0',
                icon: Icons.monetization_on_outlined,
              ),
              validator: (valor) {
                final numero = int.tryParse(valor?.trim() ?? '');
                if (numero == null || numero < 0) {
                  return 'Informe um custo válido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descricaoController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 3,
              maxLines: 6,
              decoration: _decoracao(
                label: 'Descrição',
                hint: 'Descrição do item',
                icon: Icons.description_outlined,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _efeitoController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 3,
              maxLines: 6,
              decoration: _decoracao(
                label: 'Efeito',
                hint: 'Efeito mecânico ou narrativo',
                icon: Icons.auto_awesome_outlined,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  widget.novo ? 'Adicionar Item' : 'Salvar Alterações',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
