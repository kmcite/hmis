// drugs.dart
import 'package:hmis/data/diseases.dart';

enum Drugs {
  // Antibiotics
  coamoxiclav,
  azithromycin,
  ceftriaxone,
  ciprofloxacin,
  metronidazole,
  cloxacillin,

  // Analgesics / Antipyretics
  paracetamol,
  ibuprofen,
  diclofenac,

  // Respiratory
  ventolin,
  clenil,

  // Cardiac
  aspirin,
  clopidogrel,
  atorvastatin,
  amlodipine,
  lisinopril,
  isoptin,
  gtnSpray,

  // GI / Antiemetics
  gravinate,
  risek,

  // Steroids
  decadron,

  // Diabetes
  metformin,
  glibenclamide,
  insulin,

  // Poisoning / Antidotes
  activatedCharcoal,
  atropine,
  pam,

  // Wound / Trauma
  tt,
  tig,
  arv,

  // Hematologic
  feso4,

  // Supportive
  ors
  ;

  String get route {
    switch (this) {
      case Drugs.ventolin:
      case Drugs.clenil:
        return 'Inhalation';
      case Drugs.gtnSpray:
        return 'Sublingual';
      case Drugs.insulin:
        return 'Subcutaneous';
      case Drugs.ceftriaxone:
      case Drugs.decadron:
      case Drugs.pam:
      case Drugs.tig:
      case Drugs.arv:
        return 'IM/IV';
      case Drugs.ors:
        return 'Oral';
      default:
        return 'Oral';
    }
  }

  /// Contraindications (simplified – can be expanded)
  Set<Diseases> get contraindications => switch (this) {
    Drugs.aspirin => {Diseases.age}, // Reye's syndrome risk in children
    _ => const {},
  };
}
