// diagnosis_status.dart

enum DiagnosisConfidence {
  likely,
  unlikely
  ;

  String get emoji {
    switch (this) {
      case DiagnosisConfidence.likely:
        return '🎯';
      case DiagnosisConfidence.unlikely:
        return '❓';
    }
  }
}
