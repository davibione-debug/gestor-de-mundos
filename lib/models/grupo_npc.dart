import 'encontro_npc.dart';

class GrupoNPC {
  final List<EncontroNPC> diurno;

  final List<EncontroNPC> noturno;

  final List<EncontroNPC> pesca;

  final List<EncontroNPC> surfe;

  const GrupoNPC({
    this.diurno = const [],
    this.noturno = const [],
    this.pesca = const [],
    this.surfe = const [],
  });
}