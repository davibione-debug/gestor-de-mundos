import 'dart:io';

import 'package:excel/excel.dart';

void main() {
  final excel = Excel.createExcel();

  // Remove a aba padrão criada pelo pacote.
  final nomePadrao = excel.getDefaultSheet();

  if (nomePadrao != null) {
    excel.delete(nomePadrao);
  }

  // ============================================================
  // CONFIGURAÇÃO
  // ============================================================

  final configuracao = excel['Configuração'];

  _cabecalhos(
    configuracao,
    [
      'Chave',
      'Valor',
      'Descricao',
    ],
  );

  _linha(
    configuracao,
    2,
    [
      'Versao',
      '1.0',
      'Versão do modelo de dados.',
    ],
  );

  _linha(
    configuracao,
    3,
    [
      'Fonte',
      'Dados_Escudo_do_Mestre.xlsx',
      'Arquivo oficial de dados do aplicativo.',
    ],
  );

  _linha(
    configuracao,
    4,
    [
      'Regra',
      'AtualizacaoPorID',
      'Registros existentes são atualizados pelo ID.',
    ],
  );

  // ============================================================
  // ITENS
  // ============================================================

  _linha(configuracao, 5, [
    'MenuBestiario',
    '',
    'Nome do menu do bestiário. Vazio usa Bestiário.',
  ]);

  _linha(configuracao, 6, [
    'MenuPersonagens',
    '',
    'Nome do menu de personagens. Vazio usa Personagens.',
  ]);
  _linha(configuracao, 7, [
    'MenuAliados',
    '',
    'Nome do menu de aliados. Vazio usa Aliados.',
  ]);

  _linha(configuracao, 8, [
    'MenuInimigos',
    '',
    'Nome do menu de inimigos. Vazio usa Inimigos.',
  ]);

  _linha(configuracao, 9, [
    'NomeCriatura',
    '',
    'Nome singular exibido para criaturas. Vazio usa Criatura.',
  ]);

  _linha(configuracao, 10, [
    'NomePersonagem',
    '',
    'Nome singular exibido para personagens. Vazio usa Personagem.',
  ]);
  final itens = excel['Itens'];

  _cabecalhos(
    itens,
    [
      'ID',
      'Nome',
      'Tipo',
      'CustoEmCreditos',
      'Efeito',
    ],
  );

  // ============================================================
  // POKÉMON
  // ============================================================

  final pokemon = excel['Pokémon'];

  _cabecalhos(
    pokemon,
    [
      'Numero',
      'Nome',
      'Lendario',
      'Tipos',
      'EfetividadeTipo',
      'Forca',
      'Habilidade',
      'Resistencia',
      'Armadura',
      'DefesaEspecial',
      'PoderDeFogo',
      'BonusForca',
      'BonusHabilidade',
      'BonusResistencia',
      'BonusArmadura',
      'BonusDefesaEspecial',
      'BonusPoderDeFogo',
      'MovesBase',
      'BonusMoves',
      'PoderesExtras',
    ],
  );

  // Pidgey de teste
  _linha(
    pokemon,
    2,
    [
      16,
      'Pidgey',
      'Não',
      'Normal,Voador',
      '',
      1,
      2,
      2,
      1,
      1,
      1,
      0,
      0,
      0,
      0,
      0,
      0,
      3,
      0,
      0,
    ],
  );

  // ============================================================
  // POKÉMON MOVES
  // ============================================================

  final pokemonMoves = excel['Pokémon_Moves'];

  _cabecalhos(
    pokemonMoves,
    [
      'PokemonNumero',
      'Ordem',
      'Move',
    ],
  );

  // ============================================================
  // POKÉMON PODERES
  // ============================================================

  final pokemonPoderes = excel['Pokémon_Poderes'];

  _cabecalhos(
    pokemonPoderes,
    [
      'PokemonNumero',
      'Ordem',
      'Tipo',
      'Nome',
      'ValorBase',
      'Bonus',
    ],
  );

  // ============================================================
  // TREINADOR POKÉMON
  // ============================================================

  final treinadorPokemon = excel['Treinador_Pokémon'];

  _cabecalhos(
    treinadorPokemon,
    [
      'NPC_ID',
      'PokemonNumero',
      'Nivel',
      'Ordem',
    ],
  );

  // ============================================================
  // NPCs
  // ============================================================

  final npcs = excel['NPCs'];

  _cabecalhos(
    npcs,
    [
      'ID',
      'Nome',
      'Descricao',
      'Forca',
      'Habilidade',
      'Inteligencia',
      'Resistencia',
      'Armadura',
      'PoderDeFogo',
      'Captura',
      'Controle',
      'Compreensao',
      'Tratamento',
      'Ecologia',
      'Kit',
      'Manobras',
      'Vantagens',
      'Desvantagens',
    ],
  );

  // Treinador teste
  _linha(
    npcs,
    2,
    [
      '0001',
      'Treinador Teste',
      'Treinador utilizado para teste de importação.',
      1,
      2,
      1,
      2,
      1,
      0,
      1,
      1,
      1,
      1,
      1,
      '',
      '',
      '',
      '',
    ],
  );

  // Rocket teste
  _linha(
    npcs,
    3,
    [
      'R0001',
      'Rocket Teste',
      'Rocket utilizado para teste de importação.',
      1,
      2,
      1,
      2,
      1,
      0,
      1,
      1,
      1,
      1,
      1,
      '',
      '',
      '',
      '',
    ],
  );

  // ============================================================
  // REGIÕES
  // ============================================================

  final regioes = excel['Regiões'];

  _cabecalhos(
    regioes,
    [
      'ID',
      'Nome',
      'Descricao',
    ],
  );

  _linha(
    regioes,
    2,
    [
      'REGIAO_001',
      'Kanto',
      'Região de teste.',
    ],
  );

  // ============================================================
  // LOCAIS
  // ============================================================

  final locais = excel['Locais'];

  _cabecalhos(
    locais,
    [
      'ID',
      'RegiaoID',
      'Nome',
      'Descricao',
      'Leguas',
      'Terreno',
    ],
  );

  _linha(
    locais,
    2,
    [
      'LOCAL_001',
      'REGIAO_001',
      'Rota 1',
      'Primeira rota da região.',
      5,
      'Fácil',
    ],
  );

  // ============================================================
  // PONTOS DE INTERESSE
  // ============================================================

  final pontos = excel['Pontos de Interesse'];

  _cabecalhos(
    pontos,
    [
      'ID',
      'LocalID',
      'Nome',
      'Descricao',
    ],
  );

  // ============================================================
  // ENCONTROS
  // ============================================================

  final encontros = excel['Encontros'];

  _cabecalhos(
    encontros,
    [
      'LocalID',
      'Tipo',
      'Categoria',
      'Codigo',
      'PokemonNumero',
      'NivelMin',
      'NivelMax',
      'Condicao',
      'Raro',
      'Periodo',
    ],
  );

  // ------------------------------------------------------------
  // Pokémon - Diurno
  // ------------------------------------------------------------

  _linha(
    encontros,
    2,
    [
      'LOCAL_001',
      'Diurno',
      'Pokemon',
      '',
      16,
      2,
      5,
      '',
      'Não',
      '',
    ],
  );

  // ------------------------------------------------------------
  // Pokémon - Noturno
  // ------------------------------------------------------------

  _linha(
    encontros,
    3,
    [
      'LOCAL_001',
      'Noturno',
      'Pokemon',
      '',
      16,
      3,
      6,
      '',
      'Não',
      '',
    ],
  );

  // ------------------------------------------------------------
  // Pokémon - Pesca
  // ------------------------------------------------------------

  _linha(
    encontros,
    4,
    [
      'LOCAL_001',
      'Pesca',
      'Pokemon',
      '',
      16,
      5,
      8,
      '',
      'Não',
      '',
    ],
  );

  // ------------------------------------------------------------
  // Pokémon - Surfe
  // ------------------------------------------------------------

  _linha(
    encontros,
    5,
    [
      'LOCAL_001',
      'Surfe',
      'Pokemon',
      '',
      16,
      5,
      10,
      '',
      'Não',
      '',
    ],
  );

  // ------------------------------------------------------------
  // Treinador - Surfe
  // ------------------------------------------------------------

  _linha(
    encontros,
    6,
    [
      'LOCAL_001',
      'Surfe',
      'Treinador',
      '0001',
      '',
      '',
      '',
      '',
      'Não',
      'Noite',
    ],
  );

  // ------------------------------------------------------------
  // Treinador - Diurno
  // ------------------------------------------------------------

  _linha(
    encontros,
    7,
    [
      'LOCAL_001',
      'Diurno',
      'Treinador',
      '0001',
      '',
      '',
      '',
      '',
      'Não',
      '',
    ],
  );

  // ------------------------------------------------------------
  // Rocket - Noturno
  // ------------------------------------------------------------

  _linha(
    encontros,
    8,
    [
      'LOCAL_001',
      'Noturno',
      'Rocket',
      'R0001',
      '',
      '',
      '',
      '',
      'Não',
      'Madrugada',
    ],
  );

  // ------------------------------------------------------------
  // Rocket - Surfe
  // ------------------------------------------------------------

  _linha(
    encontros,
    9,
    [
      'LOCAL_001',
      'Surfe',
      'Rocket',
      'R0001',
      '',
      '',
      '',
      '',
      'Não',
      'Noite',
    ],
  );

  // ============================================================
  // EVENTOS
  // ============================================================

  final eventos = excel['Eventos'];

  _cabecalhos(
    eventos,
    [
      'ID',
      'LocalID',
      'PontoInteresseID',
      'Nome',
      'Descricao',
      'DadosInicio',
      'FacesInicio',
      'DadosDuracao',
      'FacesDuracao',
      'Periodo',
    ],
  );

  // ============================================================
  // SALVAR
  // ============================================================

  final caminho = '${Directory.current.path}/Dados_Escudo_do_Mestre.xlsx';

  final bytes = excel.encode();

  if (bytes == null) {
    throw Exception(
      'Não foi possível gerar o arquivo Excel.',
    );
  }

  final arquivo = File(caminho);

  arquivo.writeAsBytesSync(
    bytes,
    flush: true,
  );

  // ============================================================
  // VERIFICAÇÃO
  // ============================================================

  print('');
  print('============================================');
  print('PLANILHA GERADA COM SUCESSO');
  print('============================================');
  print('');
  print('Arquivo:');
  print(caminho);
  print('');
  print('Abas:');
  print('');
  print(' - Configuração');
  print(' - Itens');
  print(' - Pokémon');
  print(' - Pokémon_Moves');
  print(' - Pokémon_Poderes');
  print(' - Treinador_Pokémon');
  print(' - NPCs');
  print(' - Regiões');
  print(' - Locais');
  print(' - Pontos de Interesse');
  print(' - Encontros');
  print(' - Eventos');
  print('');
  print('Total: 12 abas');
  print('');
  print('============================================');
}

void _cabecalhos(
  Sheet sheet,
  List<String> valores,
) {
  for (int i = 0; i < valores.length; i++) {
    sheet
        .cell(
          CellIndex.indexByColumnRow(
            columnIndex: i,
            rowIndex: 0,
          ),
        )
        .value = TextCellValue(
      valores[i],
    );
  }
}

void _linha(
  Sheet sheet,
  int linha,
  List<dynamic> valores,
) {
  for (int i = 0; i < valores.length; i++) {
    final valor = valores[i];

    final celula = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: i,
        rowIndex: linha - 1,
      ),
    );

    if (valor == null) {
      celula.value = TextCellValue('');
    } else if (valor is int) {
      celula.value = IntCellValue(valor);
    } else if (valor is double) {
      celula.value = DoubleCellValue(valor);
    } else {
      celula.value = TextCellValue(
        valor.toString(),
      );
    }
  }
}
