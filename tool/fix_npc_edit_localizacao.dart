import 'dart:io';

void main() {
  final path = 'lib/screens/npcs/npc_edit_screen.dart';
  var src = File(path).readAsStringSync();

  // 1. Corrige o titulo do item (mojibake de ×)
  final regexItem = RegExp(
    r"title:\s*Text\(\s*' Á— ',\s*style:",
  );
  if (regexItem.hasMatch(src)) {
    src = src.replaceFirst(
      regexItem,
      "title: Text(\n                '\${item.nome} \\u00d7 \${item.quantidade}',\n                style:",
    );
    print('Item title corrigido.');
  } else {
    print('AVISO: titulo do item nao encontrado (pode ja ter sido corrigido).');
  }

  // 2. Localiza o campo "Localização" dentro do build
  // e troca o _campoTexto por um TextField desabilitado com ícone de cadeado.
  final alvo = """            _campoTexto(
              'Localização',
              _localizacaoController,
            ),""";

  const novoCampo = """            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _localizacaoController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Localização',
                  hintText: 'Preenchido automaticamente pelo app',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                  filled: true,
                  helperText:
                      'Definido automaticamente quando o personagem é '
                      'vinculado a um Local, Evento ou Ponto de Interesse.',
                ),
              ),
            ),""";

  if (src.contains(alvo)) {
    src = src.replaceFirst(alvo, novoCampo);
    print('Campo Localizacao agora e somente leitura.');
  } else {
    print('AVISO: campo Localizacao nao encontrado no formato esperado.');
  }

  File(path).writeAsStringSync(src);
  print('npc_edit_screen.dart ajustado.');
}