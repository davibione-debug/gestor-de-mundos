import 'encontro.dart';


class Grupo {

  final String id;

  final String nome;


  final List<Encontro> diurno;

  final List<Encontro> noturno;


  final List<Encontro> pesca;

  final List<Encontro> surfe;



  const Grupo({

    required this.id,

    required this.nome,

    required this.diurno,

    required this.noturno,

    required this.pesca,

    required this.surfe,

  });

}