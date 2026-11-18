import 'package:flutter/material.dart';

import 'app_colors.dart';

class PTStatRow extends StatelessWidget {
  final String titulo;
  final String valor;

  const PTStatRow({
    super.key,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [

          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 16,
                color: PTColors.subtitle,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Container(
            width: 50,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: PTColors.lightBlue,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: PTColors.border,
              ),
            ),
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: PTColors.primary,
              ),
            ),
          ),

        ],
      ),
    );
  }
}