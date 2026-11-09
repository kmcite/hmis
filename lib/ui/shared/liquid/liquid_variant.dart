/// Visual depth roles for liquid surfaces (gradient + specular edge, no blur).
enum LiquidVariant {
  /// Default panel on the canvas.
  surface,

  /// Floating cards and sheets.
  elevated,

  /// Tinted interactive / emphasis.
  accent,

  /// Recessed wells (chips, inputs).
  inset,

  /// Large hero blocks (primary CTA backgrounds).
  hero,
}
