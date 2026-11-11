/// Visual depth roles for liquid surfaces (flat tint + border + shadow).
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
