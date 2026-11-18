import 'local.dart';

class Regiao {
  final String id;

  final String nome;

  final String descricao;

  final List<Local> locais;


  const Regiao({

    required this.id,

    required this.nome,

    required this.descricao,

    required this.locais,

  });
}