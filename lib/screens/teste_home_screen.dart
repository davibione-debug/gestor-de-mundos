import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/context_selector.dart';

import 'bestiario/bestiario_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escudo do Mestre'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: ContextSelector(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          const Icon(
            Icons.pets,
            size: 70,
            color: PTColors.primary,
          ),
          const SizedBox(height: 10),
          Text(
            'Painel do Mestre',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Escolha uma ferramenta',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PTColors.subtitle,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PokedexScreen(),
                ),
              );
            },
            child: const Text('Pok�dex'),
          ),
        ],
      ),
    );
  }
}
