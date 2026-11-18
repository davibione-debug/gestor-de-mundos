import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  final arquivo = File('Dados_Escudo_do_Mestre.xlsx');
  final bytes = arquivo.readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);

  final sheet = excel.tables['Locais'];

  if (sheet == null) {
    print('ABA LOCais NÃO ENCONTRADA');
    print('Abas existentes: ${excel.tables.keys.toList()}');
    return;
  }

  print('CABECALHOS DA ABA LOCAIS:');

  if (sheet.rows.isEmpty) {
    print('A aba está vazia.');
    return;
  }

  for (final celula in sheet.rows.first) {
    print(celula?.value);
  }

  print('');
  print('PRIMEIRA LINHA DE DADOS:');

  if (sheet.rows.length > 1) {
    for (final celula in sheet.rows[1]) {
      print(celula?.value);
    }
  }
}
