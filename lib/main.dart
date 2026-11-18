import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/home/home_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/batalhas_minimizadas.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: GestorDeMundosApp(),
    ),
  );
}

class GestorDeMundosApp extends StatelessWidget {
  const GestorDeMundosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Mundo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      navigatorKey: appNavigatorKey,
      home: const HomeScreen(),
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const BatalhasMinimizadas(),
          ],
        );
      },
    );
  }
}

