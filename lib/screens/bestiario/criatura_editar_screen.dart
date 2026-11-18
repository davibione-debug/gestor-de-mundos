import 'package:flutter/material.dart';

import '../../models/poder.dart';
import '../../models/item.dart';
import '../../repositories/itens_repository.dart';
import '../itens/item_editar_screen.dart';
import '../../models/criatura.dart';
import '../../repositories/criaturas_repository.dart';
import '../../tipo_criatura.dart';

class CriaturaEditarScreen extends StatefulWidget {
  final Criatura criatura;
  final bool novo;
  final bool salvarNoRepositorio;

  const CriaturaEditarScreen({
    super.key,
    required this.criatura,
    this.novo = false,
    this.salvarNoRepositorio = true,
  });

  @override
  State<CriaturaEditarScreen> createState() => _CriaturaEditarScreenState();
}

class _CriaturaEditarScreenState extends State<CriaturaEditarScreen> {
  final CriaturasRepository _repository = CriaturasRepository();

  late final TextEditingController _numero;
  late final TextEditingController _nome;
  late final TextEditingController _descricao;

  late final TextEditingController _superEfetivo;
  late final TextEditingController _poucoEfetivo;
  late final TextEditingController _imune;

  late final TextEditingController _forca;
  late final TextEditingController _habilidade;
  late final TextEditingController _resistencia;
  late final TextEditingController _armadura;
  late final TextEditingController _defesaEspecial;
  late final TextEditingController _poderDeFogo;

  late final TextEditingController _moves;

  late List<String> _tipos;
  late List<Poder> _poderes;
  bool _lendario = false;

  Item? _itemComum;
  Item? _itemRaro;

  @override
  void initState() {
    super.initState();

    final criatura = widget.criatura;
    _itemComum = criatura.itemComum;
    _itemRaro = criatura.itemRaro;
    _lendario = criatura.lendario;

    _numero = TextEditingController(
      text: criatura.numero?.toString() ?? '',
    );

    _nome = TextEditingController(text: criatura.nome);
    _descricao = TextEditingController(text: criatura.descricao);

    _superEfetivo = TextEditingController(text: criatura.superEfetivo);
    _poucoEfetivo = TextEditingController(text: criatura.poucoEfetivo);
    _imune = TextEditingController(text: criatura.imune);

    _forca = TextEditingController(text: criatura.forca.toString());
    _habilidade = TextEditingController(text: criatura.habilidade.toString());
    _resistencia = TextEditingController(text: criatura.resistencia.toString());
    _armadura = TextEditingController(text: criatura.armadura.toString());
    _defesaEspecial = TextEditingController(text: criatura.defesaEspecial.toString());
    _poderDeFogo = TextEditingController(text: criatura.poderDeFogo.toString());

    _moves = TextEditingController(text: criatura.moves.join('\n'));

    _tipos = List<String>.from(criatura.tipos);
    _poderes = List<Poder>.from(criatura.poderes);
  }

  @override
  void dispose() {
    _numero.dispose();
    _nome.dispose();
    _descricao.dispose();

    _superEfetivo.dispose();
    _poucoEfetivo.dispose();
    _imune.dispose();

    _forca.dispose();
    _habilidade.dispose();
    _resistencia.dispose();
    _armadura.dispose();
    _defesaEspecial.dispose();
    _poderDeFogo.dispose();

    _moves.dispose();

    super.dispose();
  }

  int _int(TextEditingController controller, {int padrao = 0}) {
    return int.tryParse(controller.text.trim()) ?? padrao;
  }

  int? _numeroInformado() {
    final texto = _numero.text.trim();
    if (texto.isEmpty) {
      return null;
    }
    return int.tryParse(texto);
  }

  void _alternarTipo(String tipo) {
    setState(() {
      if (_tipos.contains(tipo)) {
        _tipos.remove(tipo);
      } else {
        if (_tipos.length < 2) {
          _tipos.add(tipo);
        }
      }
    });
  }

  Future<void> _adicionarPoder() async {
    final resultado = await showDialog<Poder>(
      context: context,
      builder: (_) => const _PoderDialog(),
    );

    if (resultado == null || !mounted) {
      return;
    }

    setState(() {
      _poderes.add(resultado);
    });
  }

  Future<void> _editarPoder(int indice) async {
    final poder = _poderes[indice];
    if (!poder.original) {
      return;
    }

    final resultado = await showDialog<Poder>(
      context: context,
      builder: (_) => _PoderDialog(poder: poder),
    );

    if (resultado == null || !mounted) {
      return;
    }

    setState(() {
      _poderes[indice] = resultado;
    });
  }

  void _removerPoder(int indice) {
    final poder = _poderes[indice];
    if (!poder.original) {
      return;
    }

    setState(() {
      _poderes.removeAt(indice);
    });
  }

  Future<void> _salvar() async {
    final nome = _nome.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome da criatura.')),
      );
      return;
    }

    final numero = _numeroInformado();

    if (_numero.text.trim().isNotEmpty && numero == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O número deve ser um número inteiro.')),
      );
      return;
    }

    final moves = _moves.text
        .split('\n')
        .map((move) => move.trim())
        .where((move) => move.isNotEmpty)
        .toList();

    final criatura = Criatura(
      numero: numero,
      nome: nome,
      descricao: _descricao.text.trim(),
      nivel: widget.criatura.nivel,
      lendario: _lendario,
      tipos: List<String>.from(_tipos),
      superEfetivo: _superEfetivo.text.trim(),
      poucoEfetivo: _poucoEfetivo.text.trim(),
      imune: _imune.text.trim(),
      efetividadeTipo: widget.criatura.efetividadeTipo,
      forca: _int(_forca),
      habilidade: _int(_habilidade),
      resistencia: _int(_resistencia),
      armadura: _int(_armadura),
      defesaEspecial: _int(_defesaEspecial),
      poderDeFogo: _int(_poderDeFogo),
      bonusForca: widget.criatura.bonusForca,
      bonusHabilidade: widget.criatura.bonusHabilidade,
      bonusResistencia: widget.criatura.bonusResistencia,
      bonusArmadura: widget.criatura.bonusArmadura,
      bonusDefesaEspecial: widget.criatura.bonusDefesaEspecial,
      bonusPoderDeFogo: widget.criatura.bonusPoderDeFogo,
      forcaPlanilha: widget.criatura.forcaPlanilha,
      habilidadePlanilha: widget.criatura.habilidadePlanilha,
      resistenciaPlanilha: widget.criatura.resistenciaPlanilha,
      armaduraPlanilha: widget.criatura.armaduraPlanilha,
      defesaEspecialPlanilha: widget.criatura.defesaEspecialPlanilha,
      poderDeFogoPlanilha: widget.criatura.poderDeFogoPlanilha,
      valoresPlanilhaFixos: widget.criatura.valoresPlanilhaFixos,
      moves: moves,
      pontosMoveProgressao: widget.criatura.pontosMoveProgressao,
      poderes: List<Poder>.from(_poderes),
      poderesExtras: widget.criatura.poderesExtras,
      pv: (_int(_resistencia) + widget.criatura.bonusResistencia) * 5,
      pe: _poderes.fold(0, (somaTotal, poder) {
        final ehTipoUnico = _tipos.length == 1;
        final mesmoTipo = ehTipoUnico && _tipos.first.trim().toLowerCase() == poder.tipo.trim().toLowerCase();
        final valorPoder = mesmoTipo ? 2 : 1;
        return somaTotal + valorPoder;
      }),
      localizacao: widget.criatura.localizacao,
      itemComum: _itemComum,
      itemRaro: _itemRaro,
    );

    if (widget.salvarNoRepositorio) {
      await _repository.salvar(criatura);
    }

    if (!mounted) {
      return;
    }

    Navigator.pop(context, criatura);
  }

  Future<void> _adicionarItem({required bool raro}) async {
    final lista = await ItensRepository().carregar();
    if (!mounted) return;
    if (lista.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum item-base cadastrado.')),
      );
      return;
    }
    lista.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

    final escolhido = await showDialog<Item>(
      context: context,
      builder: (_) => _SelecionarItemCriaturaDialog(itens: lista),
    );
    if (escolhido == null || !mounted) return;

    setState(() {
      if (raro) {
        _itemRaro = escolhido;
      } else {
        _itemComum = escolhido;
      }
    });
  }

  Future<void> _criarItem({required bool raro}) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ItemEditarScreen(
          item: const Item(nome: '', tipo: '', custoEmCreditos: 0, efeito: ''),
          novo: true,
        ),
      ),
    );
    if (!mounted) return;
    final lista = await ItensRepository().carregar();
    if (!mounted) return;
    if (lista.isEmpty) return;
    lista.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    final escolhido = await showDialog<Item>(
      context: context,
      builder: (_) => _SelecionarItemCriaturaDialog(itens: lista),
    );
    if (escolhido == null || !mounted) return;
    setState(() {
      if (raro) {
        _itemRaro = escolhido;
      } else {
        _itemComum = escolhido;
      }
    });
  }

  Widget _buildItemSecao({
    required String titulo,
    required Item? item,
    required bool raro,
  }) {
    return _secao(
      titulo,
      [
        if (item != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: raro ? Colors.amber.withValues(alpha: 0.12) : const Color(0xFFF8F7F3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: raro ? Colors.amber.shade700 : const Color(0xFFD8D3C7),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: raro ? Colors.amber.shade800 : Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.nome, style: const TextStyle(fontWeight: FontWeight.w800)),
                      if (item.efeito.trim().isNotEmpty)
                        Text(item.efeito, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Remover',
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => setState(() {
                    if (raro) {
                      _itemRaro = null;
                    } else {
                      _itemComum = null;
                    }
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _adicionarItem(raro: raro),
                child: const Text('Adicionar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.tonal(
                onPressed: () => _criarItem(raro: raro),
                child: const Text('Criar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _campo(
    String label,
    TextEditingController controller, {
    TextInputType? teclado,
    int maxLinhas = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: teclado,
      maxLines: maxLinhas,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _campoInteiro(String label, TextEditingController controller) {
    return _campo(label, controller, teclado: TextInputType.number);
  }

  Widget _secao(String titulo, List<Widget> filhos) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            ...filhos,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.novo ? 'Adicionar Cadastro' : 'Editar Criatura'),
        actions: [
          IconButton(
            tooltip: 'Salvar',
            icon: const Icon(Icons.save_outlined),
            onPressed: _salvar,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
        children: [
          _secao(
            'Identificação',
            [
              _campoInteiro('Número', _numero),
              const SizedBox(height: 10),
              _campo('Nome', _nome),
              const SizedBox(height: 10),
              _campo('Descrição', _descricao, maxLinhas: 3),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Lendário'),
                value: _lendario,
                onChanged: (valor) {
                  setState(() {
                    _lendario = valor;
                  });
                },
              ),
            ],
          ),
          _secao(
            'Tipos',
            [
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: TipoCriatura.todos
                    .map(
                      (tipo) => FilterChip(
                        label: Text(tipo),
                        selected: _tipos.contains(tipo),
                        onSelected: (_) => _alternarTipo(tipo),
                      ),
                    )
                    .toList(),
              ),
              if (_tipos.length >= 2)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Máximo de 2 tipos.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          _secao(
            'Efetividade de Tipo',
            [
              _campo('Super Efetivo', _superEfetivo, maxLinhas: 2),
              const SizedBox(height: 10),
              _campo('Pouco Efetivo', _poucoEfetivo, maxLinhas: 2),
              const SizedBox(height: 10),
              _campo('Imune', _imune, maxLinhas: 2),
            ],
          ),
          _secao(
            'Atributos',
            [
              Row(
                children: [
                  Expanded(child: _campoInteiro('Força', _forca)),
                  const SizedBox(width: 8),
                  Expanded(child: _campoInteiro('Habilidade', _habilidade)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _campoInteiro('Resistência', _resistencia)),
                  const SizedBox(width: 8),
                  Expanded(child: _campoInteiro('Armadura', _armadura)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _campoInteiro('Defesa Especial', _defesaEspecial)),
                  const SizedBox(width: 8),
                  Expanded(child: _campoInteiro('Poder de Fogo', _poderDeFogo)),
                ],
              ),
            ],
          ),
          _buildItemSecao(titulo: 'Item Comum (50% de chance)', item: _itemComum, raro: false),
          _buildItemSecao(titulo: 'Item Raro (1/6 de chance)', item: _itemRaro, raro: true),
          _secao('Vantagens', [_campo('Um Move por linha', _moves, maxLinhas: 6)]),
          _secao(
            'Poderes',
            [
              if (_poderes.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('Nenhum Poder cadastrado.'),
                ),
              ...List.generate(
                _poderes.length,
                (indice) {
                  final poder = _poderes[indice];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 7),
                    child: ListTile(
                      title: Text(poder.texto, style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text(poder.original ? 'Original' : 'Adquirido por progressão'),
                      onTap: poder.original ? () => _editarPoder(indice) : null,
                      trailing: poder.original
                          ? IconButton(
                              tooltip: 'Excluir Poder',
                              onPressed: () => _removerPoder(indice),
                              icon: const Icon(Icons.delete_outline),
                            )
                          : const Icon(Icons.lock_outline),
                    ),
                  );
                },
              ),
              OutlinedButton.icon(
                onPressed: _adicionarPoder,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Poder Original'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FilledButton.icon(
            onPressed: _salvar,
            icon: const Icon(Icons.save),
            label: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

class _PoderDialog extends StatefulWidget {
  final Poder? poder;
  const _PoderDialog({this.poder});

  @override
  State<_PoderDialog> createState() => _PoderDialogState();
}

class _PoderDialogState extends State<_PoderDialog> {
  late final TextEditingController _tipo;
  late final TextEditingController _valorBase;
  late final TextEditingController _bonus;

  @override
  void initState() {
    super.initState();
    final poder = widget.poder;
    _tipo = TextEditingController(text: poder?.tipo ?? '');
    _valorBase = TextEditingController(text: poder?.valorBase.toString() ?? '1');
    _bonus = TextEditingController(text: poder?.bonus.toString() ?? '0');
  }

  @override
  void dispose() {
    _tipo.dispose();
    _valorBase.dispose();
    _bonus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.poder == null ? 'Adicionar Poder Original' : 'Editar Poder Original'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tipo,
              decoration: const InputDecoration(
                labelText: 'Tipo do Poder',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _valorBase,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Valor base',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bonus,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Bônus do Poder',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 4),
            const Text('A progressão da criatura é controlada pelo ajuste de nível.'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final tipo = _tipo.text.trim();
            if (tipo.isEmpty) return;
            Navigator.pop(
              context,
              Poder(
                tipo: tipo,
                valorBase: int.tryParse(_valorBase.text.trim()) ?? 0,
                bonus: int.tryParse(_bonus.text.trim()) ?? 0,
                original: true,
              ),
            );
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class _SelecionarItemCriaturaDialog extends StatefulWidget {
  final List<Item> itens;
  const _SelecionarItemCriaturaDialog({required this.itens});

  @override
  State<_SelecionarItemCriaturaDialog> createState() =>
      _SelecionarItemCriaturaDialogState();
}

class _SelecionarItemCriaturaDialogState
    extends State<_SelecionarItemCriaturaDialog> {
  final TextEditingController _busca = TextEditingController();

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final termo = _busca.text.trim().toLowerCase();
    final itens = widget.itens
        .where((item) => item.nome.toLowerCase().contains(termo))
        .toList();

    return AlertDialog(
      title: const Text('Selecionar Item'),
      content: SizedBox(
        width: 520,
        height: 460,
        child: Column(
          children: [
            TextField(
              controller: _busca,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Buscar item',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: itens.isEmpty
                  ? const Center(child: Text('Nenhum item encontrado.'))
                  : ListView.separated(
                      itemCount: itens.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = itens[index];
                        return ListTile(
                          leading: const Icon(Icons.inventory_2_outlined),
                          title: Text(item.nome),
                          subtitle: Text(item.tipo.isEmpty ? 'Sem tipo' : item.tipo),
                          onTap: () => Navigator.pop(context, item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
