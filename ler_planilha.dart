import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  final arquivo = File('Dados_Escudo_do_Mestre.xlsx');

  if (!arquivo.existsSync()) {
    print('Arquivo não encontrado.');
    return;
  }

  final bytes = arquivo.readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);

  print('');
  print('============================================');
  print('ABAS DA PLANILHA');
  print('============================================');

  for (final nomeAba in excel.tables.keys) {
    print('');
    print('============================================');
    print('ABA: $nomeAba');
    print('============================================');

    final planilha = excel.tables[nomeAba];

    if (planilha == null || planilha.rows.isEmpty) {
      print('(vazia)');
      continue;
    }

    final cabecalho = planilha.rows.first;

    for (int i = 0; i < cabecalho.length; i++) {
      final valor = cabecalho[i]?.value;

      print(
        '[${i + 1}] ${valor ?? ''}',
      );
    }

    print('');
    print('Linhas: ${planilha.rows.length}');
  }

  print('');
  print('============================================');
  print('FIM');
  print('============================================');
}