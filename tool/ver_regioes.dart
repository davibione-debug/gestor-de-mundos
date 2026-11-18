import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  final bytes = File('Dados_Escudo_do_Mestre.xlsx').readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);

  print('ABAS:');
  print(excel.tables.keys);

  print('\nREGIÕES:');

  final sheet = excel.tables['Regiões'];

  if (sheet == null) {
    print('Aba "Regiões" NÃO encontrada.');
    return;
  }

  for (final row in sheet.rows) {
    print(row.map((cell) => cell?.value).toList());
  }
}
