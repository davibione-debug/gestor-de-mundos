import 'package:flutter/material.dart';

/// Paleta oficial do Criatura Tactics.
///
/// Nenhuma tela deve definir cores diretamente.
/// Sempre utilize PTColors.

class PTColors {
  PTColors._();

  // ============================================================
  // CORES BASE
  // ============================================================

  /// Fundo principal das telas.
  static const Color background = Color(0xFFF8F3E9);

  /// Fundo de cards, menus e superfícies.
  static const Color surface = Color(0xFFFFFFFF);

  /// Branco para elementos sobre fundos escuros.
  static const Color white = Color(0xFFFFFFFF);

  /// Preto para sombras e efeitos.
  static const Color black = Color(0xFF000000);

  /// Transparente.
  static const Color transparent = Color(0x00000000);

  /// Sombra padrão.
  static const Color shadow = Color(0x33000000);

  /// Sombra mais discreta.
  static const Color shadowLight = Color(0x1A000000);

  // ============================================================
  // IDENTIDADE
  // ============================================================

  /// Azul principal da identidade visual.
  static const Color primary = Color(0xFF173E73);

  /// Azul secundário para botões e destaques.
  static const Color secondary = Color(0xFF2F5EA8);

  /// Azul claro para fundos de destaque.
  static const Color lightBlue = Color(0xFFDCE8F7);

  // ============================================================
  // ESTRUTURA
  // ============================================================

  /// Linhas divisórias e bordas.
  static const Color border = Color(0xFFB8C7DD);

  /// Texto principal.
  static const Color text = Color(0xFF2C2A27);

  /// Texto secundário.
  static const Color subtitle = Color(0xFF5F6368);

  /// Texto desabilitado.
  static const Color disabled = Color(0xFF9AA0A6);

  // ============================================================
  // ESTADOS
  // ============================================================

  /// Operações concluídas com sucesso.
  static const Color success = Color(0xFF2E7D32);

  /// Avisos e atenção.
  static const Color warning = Color(0xFFF9A825);

  /// Erros, exclusões e ações destrutivas.
  static const Color danger = Color(0xFFC62828);

  // ============================================================
  // CORES DOS TIPOS DE CRIATURA
  // ============================================================

  static const Color fire = Color(0xFFE53935);

  static const Color water = Color(0xFF1E88E5);

  static const Color grass = Color(0xFF43A047);

  static const Color electric = Color(0xFFFDD835);

  static const Color psychic = Color(0xFF8E24AA);

  static const Color ice = Color(0xFF00ACC1);

  static const Color fighting = Color(0xFFF4511E);

  // ============================================================
  // FUNDOS SUAVES DOS TIPOS
  // ============================================================

  static const Color fireLight = Color(0xFFFFEBEE);

  static const Color waterLight = Color(0xFFE3F2FD);

  static const Color grassLight = Color(0xFFE8F5E9);

  static const Color electricLight = Color(0xFFFFFDE7);

  static const Color psychicLight = Color(0xFFF3E5F5);

  static const Color iceLight = Color(0xFFE0F7FA);

  static const Color fightingLight = Color(0xFFFBE9E7);

  // ============================================================
  // ELEMENTOS DE FICHA / DESTAQUE
  // ============================================================

  /// Fundo suave para informações de poder.
  static const Color powerBackground = Color(0xFFFFF8E7);

  /// Fundo neutro suave.
  static const Color softSurface = Color(0xFFFDFAF4);
}
