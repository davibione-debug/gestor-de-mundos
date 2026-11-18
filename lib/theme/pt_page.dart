import 'package:flutter/material.dart';

class PTPage extends StatelessWidget {
  final String titulo;
  final Widget child;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;

  const PTPage({
    super.key,
    required this.titulo,
    required this.child,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        centerTitle: true,
        actions: actions,
      ),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}