import 'package:flutter/material.dart';

import '../geradores/gerador_evento.dart';

class EventoCard extends StatelessWidget {
  final ResultadoEvento resultado;

  const EventoCard({
    super.key,
    required this.resultado,
  });

  @override
  Widget build(BuildContext context) {
    final evento = resultado.evento;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    evento.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (evento.descricao.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(evento.descricao),
            ],
            if (evento.inicio.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              _campo('Início', evento.inicio),
            ],
            if (evento.duracao.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              _campo('Duração', evento.duracao),
            ],
            if (evento.efeito.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              _campo('Efeito', evento.efeito),
            ],
          ],
        ),
      ),
    );
  }

  Widget _campo(String titulo, String valor) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
        children: [
          TextSpan(
            text: '$titulo: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: valor),
        ],
      ),
    );
  }
}
