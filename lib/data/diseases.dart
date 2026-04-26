// diagnosis_status.dart

import 'package:hmis/data/findings.dart';

enum Diseases {
  // Respiratory
  urti,
  pneumonia,
  asthma,

  // GIT
  age,

  // Urinary
  uti,

  // Infectious
  malaria,
  typhoid,

  // Cardiac
  mi,
  htn,
  svt,

  // Neurological
  stroke,

  // Endocrine
  dm,

  // Hematological
  anemia,

  // Wound / Bite
  dogBite,
  woundInfection,

  // Trauma
  rta,

  // Poisoning
  poisoning,
  opPoisoning,

  // Others
  ectopicPregnancy,
  feverDx,
  heartBlock,
  hypothyroidism,
  headInjury,
  pe,
  pph,
  preeclampsia,
  sepsis,
  shock,
  urinaryTractStones,
  miscarriage,
  croup
  ;

  String get code {
    switch (this) {
      case Diseases.urti:
        return 'URTI';
      case Diseases.pneumonia:
        return 'Pneumonia';
      case Diseases.asthma:
        return 'Asthma';
      case Diseases.age:
        return 'AGE';
      case Diseases.uti:
        return 'UTI';
      case Diseases.malaria:
        return 'Malaria';
      case Diseases.typhoid:
        return 'Typhoid';
      case Diseases.mi:
        return 'MI';
      case Diseases.htn:
        return 'HTN';
      case Diseases.svt:
        return 'SVT';
      case Diseases.stroke:
        return 'Stroke';
      case Diseases.dm:
        return 'DM';
      case Diseases.anemia:
        return 'Anemia';
      case Diseases.dogBite:
        return 'DogBite';
      case Diseases.woundInfection:
        return 'WoundInfection';
      case Diseases.rta:
        return 'RTA';
      case Diseases.poisoning:
        return 'Poisoning';
      case Diseases.opPoisoning:
        return 'OPPoisoning';
      case Diseases.ectopicPregnancy:
        return 'Ectopic Pregnancy';
      case Diseases.feverDx:
        return 'Fever';
      case Diseases.heartBlock:
        return 'HeartBlock';
      case Diseases.hypothyroidism:
        return 'Hypothyroidism';
      case Diseases.headInjury:
        return 'HeadInjury';
      case Diseases.pe:
        return 'PE';
      case Diseases.pph:
        return 'PPH';
      case Diseases.preeclampsia:
        return 'Preeclampsia';
      case Diseases.sepsis:
        return 'Sepsis';
      case Diseases.shock:
        return 'Shock';
      case Diseases.urinaryTractStones:
        return 'Urinary Tract Stones';
      case Diseases.miscarriage:
        return 'Miscarriage';
      case Diseases.croup:
        throw UnimplementedError();
    }
  }

  String get label {
    switch (this) {
      case Diseases.urti:
        return 'Upper Respiratory Tract Infection';
      case Diseases.pneumonia:
        return 'Pneumonia';
      case Diseases.asthma:
        return 'Asthma / COPD';
      case Diseases.age:
        return 'Acute Gastroenteritis';
      case Diseases.uti:
        return 'Urinary Tract Infection';
      case Diseases.malaria:
        return 'Malaria';
      case Diseases.typhoid:
        return 'Typhoid Fever';
      case Diseases.mi:
        return 'Acute MI';
      case Diseases.htn:
        return 'Hypertension';
      case Diseases.svt:
        return 'Supraventricular Tachycardia';
      case Diseases.stroke:
        return 'Stroke / TIA';
      case Diseases.dm:
        return 'Diabetes Mellitus';
      case Diseases.anemia:
        return 'Anemia';
      case Diseases.dogBite:
        return 'Dog / Animal Bite';
      case Diseases.woundInfection:
        return 'Wound Infection';
      case Diseases.rta:
        return 'Road Traffic Accident';
      case Diseases.poisoning:
        return 'Poisoning / Drug Overdose';
      case Diseases.opPoisoning:
        return 'Organophosphate Poisoning';
      default:
        return code;
    }
  }

  String get category {
    switch (this) {
      case Diseases.urti:
      case Diseases.pneumonia:
      case Diseases.asthma:
      case Diseases.pe:
        return 'Respiratory';
      case Diseases.age:
        return 'GIT';
      case Diseases.uti:
      case Diseases.urinaryTractStones:
        return 'Urinary';
      case Diseases.malaria:
      case Diseases.typhoid:
      case Diseases.sepsis:
        return 'Infectious';
      case Diseases.mi:
      case Diseases.htn:
      case Diseases.svt:
      case Diseases.heartBlock:
      case Diseases.shock:
        return 'Cardiac';
      case Diseases.stroke:
        return 'Neurological';
      case Diseases.dm:
      case Diseases.hypothyroidism:
        return 'Endocrine';
      case Diseases.anemia:
        return 'Hematological';
      case Diseases.dogBite:
      case Diseases.woundInfection:
        return 'Wound';
      case Diseases.rta:
      case Diseases.headInjury:
        return 'Trauma';
      case Diseases.poisoning:
      case Diseases.opPoisoning:
        return 'Poisoning';
      case Diseases.ectopicPregnancy:
      case Diseases.pph:
      case Diseases.preeclampsia:
      case Diseases.miscarriage:
        return 'Obs/Gyn';
      default:
        return 'General';
    }
  }

  List<Findings> get keyFindings => switch (this) {
    Diseases.urti => [
      Findings.febrile,
      Findings.throatCongested,
      Findings.chestClear,
      Findings.tonsilsEnlarged,
    ],
    Diseases.pneumonia => [
      Findings.febrile,
      Findings.bilateralCreps,
      Findings.respiratoryDistress,
      Findings.reducedAirEntry,
    ],
    Diseases.asthma => [
      Findings.wheezingFound,
      Findings.respiratoryDistress,
      Findings.reducedAirEntry,
      Findings.chestClear,
    ],
    Diseases.age => [
      Findings.febrile,
      Findings.someDehydration,
      Findings.severeDehydration,
      Findings.epigastricTenderness,
      Findings.generalizedTenderness,
    ],
    Diseases.uti => [
      Findings.febrile,
      Findings.suprapubicTenderness,
    ],
    Diseases.malaria => [
      Findings.febrile,
      Findings.pale,
      Findings.someDehydration,
      Findings.hepatomegaly,
      Findings.splenomegaly,
    ],
    Diseases.typhoid => [
      Findings.febrile,
      Findings.generalizedTenderness,
      Findings.hepatomegaly,
      Findings.splenomegaly,
    ],
    Diseases.mi => [
      Findings.tachycardia,
      Findings.irregularPulse,
      Findings.respiratoryDistress,
      Findings.elevatedBP,
      Findings.loc,
    ],
    Diseases.htn => [
      Findings.elevatedBP,
    ],
    Diseases.svt => [
      Findings.tachycardia,
      Findings.irregularPulse,
      Findings.respiratoryDistress,
      Findings.elevatedBP,
      Findings.loc,
    ],
    Diseases.stroke => [
      Findings.facialAsymmetry,
      Findings.focalDeficit,
      Findings.loc,
      Findings.elevatedBP,
    ],
    Diseases.dm => [
      Findings.alteredSensorium,
    ],
    Diseases.anemia => [
      Findings.pale,
      Findings.tachycardia,
    ],
    Diseases.dogBite => [
      Findings.biteWound,
      Findings.abrasion,
      Findings.woundInfected,
    ],
    Diseases.woundInfection => [
      Findings.woundInfected,
      Findings.swellingDeformity,
      Findings.febrile,
    ],
    Diseases.rta => [
      Findings.laceration,
      Findings.abrasion,
      Findings.swellingDeformity,
      Findings.alteredSensorium,
    ],
    Diseases.poisoning => [
      Findings.alteredSensorium,
      Findings.hypersalivation,
    ],
    Diseases.opPoisoning => [
      Findings.miosis,
      Findings.hypersalivation,
      Findings.bradycardia,
      Findings.alteredSensorium,
    ],
    _ => [],
  };

  List<Findings> get differentialFindings => switch (this) {
    Diseases.urti => [
      Findings.afebrile,
      Findings.notDehydrated,
    ],
    _ => [],
  };
}
