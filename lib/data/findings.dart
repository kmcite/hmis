// diagnosis_status.dart

import 'package:hmis/data/diagnosis_confidence.dart';
import 'package:hmis/data/diseases.dart';

enum Findings {
  // General
  febrile,
  afebrile,
  pale,
  activeAlert,
  alteredSensorium,

  // Hydration
  notDehydrated,
  someDehydration,
  severeDehydration,

  // Respiratory
  chestClear,
  bilateralCreps,
  wheezingFound,
  respiratoryDistress,
  reducedAirEntry,

  // ENT
  throatCongested,
  entBleed,
  tonsilsEnlarged,

  // Abdomen
  softNonTender,
  epigastricTenderness,
  generalizedTenderness,
  suprapubicTenderness,
  hepatomegaly,
  splenomegaly,

  // Cardiac
  elevatedBP,
  tachycardia,
  irregularPulse,
  bradycardia,

  // Neurological
  facialAsymmetry,
  focalDeficit,
  loc,

  // Wound / Trauma
  biteWound,
  laceration,
  abrasion,
  swellingDeformity,
  woundInfected,

  // Poisoning
  miosis,
  hypersalivation
  ;

  String get name {
    switch (this) {
      case Findings.febrile:
        return 'febrile';
      case Findings.afebrile:
        return 'afebrile';
      case Findings.pale:
        return 'pale';
      case Findings.activeAlert:
        return 'active / alert';
      case Findings.alteredSensorium:
        return 'altered sensorium';
      case Findings.notDehydrated:
        return 'not dehydrated';
      case Findings.someDehydration:
        return 'some dehydration';
      case Findings.severeDehydration:
        return 'severe dehydration';
      case Findings.chestClear:
        return 'chest clear';
      case Findings.bilateralCreps:
        return 'bilateral creps';
      case Findings.wheezingFound:
        return 'wheezing';
      case Findings.respiratoryDistress:
        return 'respiratory distress';
      case Findings.reducedAirEntry:
        return 'reduced air entry';
      case Findings.throatCongested:
        return 'throat congested';
      case Findings.entBleed:
        return 'ENT bleed';
      case Findings.tonsilsEnlarged:
        return 'tonsils enlarged';
      case Findings.softNonTender:
        return 'soft / non-tender';
      case Findings.epigastricTenderness:
        return 'epigastric tenderness';
      case Findings.generalizedTenderness:
        return 'generalized tenderness';
      case Findings.suprapubicTenderness:
        return 'suprapubic tenderness';
      case Findings.hepatomegaly:
        return 'hepatomegaly';
      case Findings.splenomegaly:
        return 'splenomegaly';
      case Findings.elevatedBP:
        return 'BP elevated';
      case Findings.tachycardia:
        return 'tachycardia';
      case Findings.irregularPulse:
        return 'irregular pulse';
      case Findings.bradycardia:
        return 'bradycardia';
      case Findings.facialAsymmetry:
        return 'facial asymmetry';
      case Findings.focalDeficit:
        return 'focal neurological deficit';
      case Findings.loc:
        return 'loss of consciousness';
      case Findings.biteWound:
        return 'bite wound present';
      case Findings.laceration:
        return 'laceration';
      case Findings.abrasion:
        return 'abrasion / graze';
      case Findings.swellingDeformity:
        return 'swelling / deformity';
      case Findings.woundInfected:
        return 'wound infected / pus';
      case Findings.miosis:
        return 'miosis (pin-point pupils)';
      case Findings.hypersalivation:
        return 'hypersalivation / secretions';
    }
  }

  Map<Diseases, DiagnosisConfidence> get diagnoses => switch (this) {
    Findings.febrile => {
      Diseases.urti: DiagnosisConfidence.likely,
      Diseases.pneumonia: DiagnosisConfidence.likely,
      Diseases.malaria: DiagnosisConfidence.likely,
      Diseases.age: DiagnosisConfidence.likely,
      Diseases.uti: DiagnosisConfidence.likely,
      Diseases.typhoid: DiagnosisConfidence.likely,
    },
    Findings.pale => {
      Diseases.anemia: DiagnosisConfidence.likely,
      Diseases.malaria: DiagnosisConfidence.likely,
    },
    Findings.alteredSensorium => {
      Diseases.stroke: DiagnosisConfidence.likely,
      Diseases.malaria: DiagnosisConfidence.likely,
      Diseases.dm: DiagnosisConfidence.likely,
    },
    Findings.someDehydration => {
      Diseases.age: DiagnosisConfidence.likely,
      Diseases.malaria: DiagnosisConfidence.likely,
    },
    Findings.severeDehydration => {
      Diseases.age: DiagnosisConfidence.likely,
    },
    Findings.chestClear => {
      Diseases.urti: DiagnosisConfidence.likely,
    },
    Findings.bilateralCreps => {
      Diseases.pneumonia: DiagnosisConfidence.likely,
      Diseases.asthma: DiagnosisConfidence.likely,
    },
    Findings.wheezingFound => {
      Diseases.asthma: DiagnosisConfidence.likely,
      Diseases.pneumonia: DiagnosisConfidence.likely,
    },
    Findings.respiratoryDistress => {
      Diseases.asthma: DiagnosisConfidence.likely,
      Diseases.pneumonia: DiagnosisConfidence.likely,
      Diseases.mi: DiagnosisConfidence.likely,
      Diseases.svt: DiagnosisConfidence.likely,
    },
    Findings.reducedAirEntry => {
      Diseases.pneumonia: DiagnosisConfidence.likely,
      Diseases.asthma: DiagnosisConfidence.likely,
    },
    Findings.throatCongested => {
      Diseases.urti: DiagnosisConfidence.likely,
    },
    Findings.tonsilsEnlarged => {
      Diseases.urti: DiagnosisConfidence.likely,
    },
    Findings.epigastricTenderness => {
      Diseases.age: DiagnosisConfidence.likely,
    },
    Findings.generalizedTenderness => {
      Diseases.age: DiagnosisConfidence.likely,
      Diseases.typhoid: DiagnosisConfidence.likely,
    },
    Findings.suprapubicTenderness => {
      Diseases.uti: DiagnosisConfidence.likely,
    },
    Findings.hepatomegaly => {
      Diseases.malaria: DiagnosisConfidence.likely,
      Diseases.typhoid: DiagnosisConfidence.likely,
    },
    Findings.splenomegaly => {
      Diseases.typhoid: DiagnosisConfidence.likely,
    },
    Findings.elevatedBP => {
      Diseases.htn: DiagnosisConfidence.likely,
      Diseases.stroke: DiagnosisConfidence.likely,
      Diseases.mi: DiagnosisConfidence.likely,
      Diseases.svt: DiagnosisConfidence.likely,
    },
    Findings.tachycardia => {
      Diseases.mi: DiagnosisConfidence.likely,
      Diseases.anemia: DiagnosisConfidence.likely,
      Diseases.malaria: DiagnosisConfidence.likely,
      Diseases.svt: DiagnosisConfidence.likely,
    },
    Findings.irregularPulse => {
      Diseases.mi: DiagnosisConfidence.likely,
      Diseases.svt: DiagnosisConfidence.likely,
    },
    Findings.bradycardia => {
      Diseases.opPoisoning: DiagnosisConfidence.likely,
    },
    Findings.facialAsymmetry => {
      Diseases.stroke: DiagnosisConfidence.likely,
    },
    Findings.focalDeficit => {
      Diseases.stroke: DiagnosisConfidence.likely,
    },
    Findings.loc => {
      Diseases.stroke: DiagnosisConfidence.likely,
      Diseases.malaria: DiagnosisConfidence.likely,
      Diseases.dm: DiagnosisConfidence.likely,
      Diseases.mi: DiagnosisConfidence.likely,
      Diseases.svt: DiagnosisConfidence.likely,
    },
    Findings.biteWound => {
      Diseases.dogBite: DiagnosisConfidence.likely,
      Diseases.woundInfection: DiagnosisConfidence.likely,
    },
    Findings.laceration => {
      Diseases.rta: DiagnosisConfidence.likely,
      Diseases.woundInfection: DiagnosisConfidence.likely,
    },
    Findings.abrasion => {
      Diseases.rta: DiagnosisConfidence.likely,
      Diseases.dogBite: DiagnosisConfidence.likely,
    },
    Findings.swellingDeformity => {
      Diseases.rta: DiagnosisConfidence.likely,
      Diseases.woundInfection: DiagnosisConfidence.likely,
    },
    Findings.woundInfected => {
      Diseases.woundInfection: DiagnosisConfidence.likely,
      Diseases.dogBite: DiagnosisConfidence.likely,
    },
    Findings.miosis => {
      Diseases.opPoisoning: DiagnosisConfidence.likely,
    },
    Findings.hypersalivation => {
      Diseases.opPoisoning: DiagnosisConfidence.likely,
      Diseases.poisoning: DiagnosisConfidence.likely,
    },
    _ => const {},
  };
}
