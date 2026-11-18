import 'package:flutter/material.dart';

import 'app_colors.dart';

class PTSection extends StatelessWidget {
  final String titulo;
  final Widget child;

  const PTSection({
    super.key,
    required this.titulo,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              titulo,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                color: PTColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Divider(),

            const SizedBox(height: 8),

            child,
          ],
        ),
      ),
    );
  }
}