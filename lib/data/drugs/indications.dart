import 'package:hmis/data/diagnosis_confidence.dart';
import 'package:hmis/data/diseases.dart';
import 'package:hmis/data/drugs/drugs.dart';

/// Indications: which diagnoses this drug is used for, with level of evidence/priority

extension flutter_bloc on Drugs {
  Map<Diseases, DiagnosisConfidence> get indications => switch (this) {
    .coamoxiclav => {
      .urti: .likely,
      .pneumonia: .likely,
      .uti: .likely,
      .woundInfection: .likely,
      .dogBite: .likely,
    },
    .azithromycin => {
      .urti: .likely,
      .pneumonia: .likely,
      .typhoid: .likely,
    },
    .ceftriaxone => {
      .pneumonia: .likely,
      .typhoid: .likely,
      .sepsis: .likely,
    },
    .ciprofloxacin => {
      .typhoid: .likely,
      .uti: .likely,
      .age: .likely,
    },
    .metronidazole => {
      .age: .likely,
    },
    .cloxacillin => {
      .woundInfection: .likely,
    },
    .paracetamol => {
      .feverDx: .likely,
      .urti: .likely,
      .malaria: .likely,
      .typhoid: .likely,
      .mi: .unlikely,
    },
    .ibuprofen => {
      .urti: .unlikely,
      .malaria: .unlikely,
      .rta: .unlikely,
    },
    .diclofenac => {
      .rta: .likely,
    },
    .ventolin => {
      .asthma: .likely,
    },
    .clenil => {
      .asthma: .likely,
    },
    .aspirin => {
      .mi: .likely,
      .stroke: .likely,
    },
    .clopidogrel => {
      .mi: .likely,
      .stroke: .likely,
    },
    .atorvastatin => {
      .mi: .likely,
      .stroke: .likely,
      .htn: .unlikely,
    },
    .amlodipine => {
      .htn: .likely,
    },
    .lisinopril => {
      .htn: .likely,
    },
    .isoptin => {
      .svt: .likely,
    },
    .gtnSpray => {
      .mi: .likely,
    },
    .gravinate => {
      .age: .likely,
      .malaria: .unlikely,
      .typhoid: .unlikely,
    },
    .risek => {
      .age: .unlikely,
    },
    .decadron => {
      .asthma: .likely,
      .croup: .likely,
    },
    .metformin => {
      .dm: .likely,
    },
    .glibenclamide => {
      .dm: .likely,
    },
    .insulin => {
      .dm: .likely,
    },
    .activatedCharcoal => {
      .poisoning: .likely,
      .opPoisoning: .likely,
    },
    .atropine => {
      .opPoisoning: .likely,
    },
    .pam => {
      .opPoisoning: .likely,
    },
    .tt => {
      .rta: .likely,
      .dogBite: .likely,
      .woundInfection: .likely,
    },
    .tig => {
      .rta: .unlikely,
      .dogBite: .likely,
    },
    .arv => {
      .dogBite: .likely,
    },
    .feso4 => {
      .anemia: .likely,
    },
    .ors => {
      .age: .likely,
      .malaria: .unlikely,
    },
  };
}
