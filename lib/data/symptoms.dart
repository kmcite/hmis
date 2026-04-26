// diagnosis_status.dart

import 'package:hmis/data/diagnosis_confidence.dart';
import 'package:hmis/data/diseases.dart';

enum Symptoms {
  // General
  fever,
  bodyAches,
  headache,
  dizziness,
  weakness,
  chillsRigors,
  weightLoss,

  // Respiratory
  cough,
  sob,
  soreThroat,
  wheezing,

  // ENT
  earache,
  nasalCongestion,

  // GIT
  looseMotions,
  nauseaVomiting,
  abdominalPain,
  constipation,
  bloating,

  // Urinary
  burningMicturition,
  frequencyUrgency,
  polyuria,

  // Cardiac
  chestPain,
  palpitations,
  highBP,

  // Neurological
  facialDroop,
  limbWeakness,
  speechDifficulty,
  alteredConsciousness,

  // Skin
  skinRash,
  pallor,

  // Wound / Bite
  animalBite,
  woundBleeding,
  woundPain,
  swellingLump,

  // Trauma
  traumaImpact,
  headInjury,
  boneDeformity,
  traumaticPain,

  // Poisoning
  poisonIngestion,
  opExposure,
  excessiveSalivation
  ;

  String get name {
    switch (this) {
      case Symptoms.fever:
        return 'Fever';
      case Symptoms.bodyAches:
        return 'Body Aches';
      case Symptoms.headache:
        return 'Headache';
      case Symptoms.dizziness:
        return 'Dizziness';
      case Symptoms.weakness:
        return 'Generalized Weakness';
      case Symptoms.chillsRigors:
        return 'Chills / Rigors';
      case Symptoms.weightLoss:
        return 'Weight Loss';
      case Symptoms.cough:
        return 'Cough';
      case Symptoms.sob:
        return 'Shortness of Breath';
      case Symptoms.soreThroat:
        return 'Sore Throat';
      case Symptoms.wheezing:
        return 'Wheezing';
      case Symptoms.earache:
        return 'Earache';
      case Symptoms.nasalCongestion:
        return 'Nasal Congestion';
      case Symptoms.looseMotions:
        return 'Loose Motions';
      case Symptoms.nauseaVomiting:
        return 'Nausea / Vomiting';
      case Symptoms.abdominalPain:
        return 'Abdominal Pain';
      case Symptoms.constipation:
        return 'Constipation';
      case Symptoms.bloating:
        return 'Bloating';
      case Symptoms.burningMicturition:
        return 'Burning Micturition';
      case Symptoms.frequencyUrgency:
        return 'Frequency / Urgency';
      case Symptoms.polyuria:
        return 'Polyuria / Polydipsia';
      case Symptoms.chestPain:
        return 'Chest Pain';
      case Symptoms.palpitations:
        return 'Palpitations';
      case Symptoms.highBP:
        return 'High BP / Hypertensive Symptoms';
      case Symptoms.facialDroop:
        return 'Facial Droop';
      case Symptoms.limbWeakness:
        return 'Limb Weakness / Numbness';
      case Symptoms.speechDifficulty:
        return 'Speech Difficulty';
      case Symptoms.alteredConsciousness:
        return 'Altered Consciousness';
      case Symptoms.skinRash:
        return 'Skin Rash';
      case Symptoms.pallor:
        return 'Pallor / Pale';
      case Symptoms.animalBite:
        return 'Animal Bite';
      case Symptoms.woundBleeding:
        return 'Wound / Bleeding';
      case Symptoms.woundPain:
        return 'Wound Pain';
      case Symptoms.swellingLump:
        return 'Swelling / Lump';
      case Symptoms.traumaImpact:
        return 'Road Traffic Accident';
      case Symptoms.headInjury:
        return 'Head Injury';
      case Symptoms.boneDeformity:
        return 'Bone Deformity / Fracture';
      case Symptoms.traumaticPain:
        return 'Post-Traumatic Pain';
      case Symptoms.poisonIngestion:
        return 'Ingestion of Poison / Drug OD';
      case Symptoms.opExposure:
        return 'Organophosphate Exposure';
      case Symptoms.excessiveSalivation:
        return 'Excessive Salivation / Secretions';
    }
  }

  String get group {
    switch (this) {
      case Symptoms.fever:
      case Symptoms.bodyAches:
      case Symptoms.headache:
      case Symptoms.dizziness:
      case Symptoms.weakness:
      case Symptoms.chillsRigors:
      case Symptoms.weightLoss:
        return 'General';
      case Symptoms.cough:
      case Symptoms.sob:
      case Symptoms.soreThroat:
      case Symptoms.wheezing:
        return 'Respiratory';
      case Symptoms.earache:
      case Symptoms.nasalCongestion:
        return 'ENT';
      case Symptoms.looseMotions:
      case Symptoms.nauseaVomiting:
      case Symptoms.abdominalPain:
      case Symptoms.constipation:
      case Symptoms.bloating:
        return 'GIT';
      case Symptoms.burningMicturition:
      case Symptoms.frequencyUrgency:
      case Symptoms.polyuria:
        return 'Urinary';
      case Symptoms.chestPain:
      case Symptoms.palpitations:
      case Symptoms.highBP:
        return 'Cardiac';
      case Symptoms.facialDroop:
      case Symptoms.limbWeakness:
      case Symptoms.speechDifficulty:
      case Symptoms.alteredConsciousness:
        return 'Neurological';
      case Symptoms.skinRash:
      case Symptoms.pallor:
        return 'Skin';
      case Symptoms.animalBite:
      case Symptoms.woundBleeding:
      case Symptoms.woundPain:
      case Symptoms.swellingLump:
        return 'Wound';
      case Symptoms.traumaImpact:
      case Symptoms.headInjury:
      case Symptoms.boneDeformity:
      case Symptoms.traumaticPain:
        return 'Trauma';
      case Symptoms.poisonIngestion:
      case Symptoms.opExposure:
      case Symptoms.excessiveSalivation:
        return 'Poisoning';
    }
  }

  List<String> get typicalDurations {
    switch (this) {
      case Symptoms.fever:
        return ['1 day', '2 days', '3 days', '5 days', '1 week'];
      case Symptoms.bodyAches:
        return ['1 day', '2 days', '3 days', '5 days'];
      case Symptoms.headache:
        return ['1 day', '2 days', '3 days'];
      case Symptoms.dizziness:
        return ['1 day', '2 days', '3 days'];
      case Symptoms.weakness:
        return ['1 day', '2 days', '3 days', '1 week'];
      case Symptoms.chillsRigors:
        return ['1 day', '2 days', '3 days'];
      case Symptoms.weightLoss:
        return ['2 weeks', '1 month', 'Chronic'];
      case Symptoms.cough:
        return ['3 days', '5 days', '1 week', '2 weeks'];
      case Symptoms.sob:
        return ['1 day', '2 days', '3 days'];
      case Symptoms.soreThroat:
        return ['2 days', '3 days', '5 days'];
      case Symptoms.wheezing:
        return ['1 day', '2 days', '3 days'];
      case Symptoms.earache:
        return ['2 days', '3 days', '5 days'];
      case Symptoms.nasalCongestion:
        return ['2 days', '3 days', '5 days', '1 week'];
      case Symptoms.looseMotions:
        return ['1 day', '2 days', '3 days', '5 days'];
      case Symptoms.nauseaVomiting:
        return ['1 day', '2 days', '3 days'];
      case Symptoms.abdominalPain:
        return ['1 day', '2 days', '3 days'];
      case Symptoms.constipation:
        return ['2 days', '3 days', '5 days'];
      case Symptoms.bloating:
        return ['1 day', '2 days', '3 days'];
      case Symptoms.burningMicturition:
        return ['3 days', '5 days', '1 week'];
      case Symptoms.frequencyUrgency:
        return ['3 days', '5 days', '1 week'];
      case Symptoms.polyuria:
        return ['1 week', '2 weeks', 'Chronic'];
      case Symptoms.chestPain:
        return ['Sudden onset', '1 day', '2 days'];
      case Symptoms.palpitations:
        return ['Sudden onset', '1 day'];
      case Symptoms.highBP:
        return ['Chronic'];
      case Symptoms.facialDroop:
        return ['Sudden onset'];
      case Symptoms.limbWeakness:
        return ['Sudden onset', '1 day'];
      case Symptoms.speechDifficulty:
        return ['Sudden onset'];
      case Symptoms.alteredConsciousness:
        return ['Sudden onset', '1 day'];
      case Symptoms.skinRash:
        return ['3 days', '5 days', '1 week'];
      case Symptoms.pallor:
        return ['Chronic', '1 week', '2 weeks'];
      case Symptoms.animalBite:
        return ['Today', '1 day ago', '2 days ago', '3+ days ago'];
      case Symptoms.woundBleeding:
        return ['Today', '1 day ago', '2 days ago'];
      case Symptoms.woundPain:
        return ['Today', '1 day', '2 days', '3 days'];
      case Symptoms.swellingLump:
        return ['1 day', '2 days', '3 days', '5 days'];
      case Symptoms.traumaImpact:
        return ['Today', '1 day ago'];
      case Symptoms.headInjury:
        return ['Today', '1 day ago'];
      case Symptoms.boneDeformity:
        return ['Today', '1 day ago'];
      case Symptoms.traumaticPain:
        return ['Today', '1 day', '2 days', '3 days'];
      case Symptoms.poisonIngestion:
        return ['Minutes ago', '< 1 hour', '1–4 hours ago', '> 4 hours ago'];
      case Symptoms.opExposure:
        return ['Minutes ago', '< 1 hour', '1–4 hours ago'];
      case Symptoms.excessiveSalivation:
        return ['Minutes ago', '< 1 hour'];
    }
  }

  Map<Diseases, DiagnosisConfidence> get diagnoses => switch (this) {
    Symptoms.fever => {
      Diseases.urti: DiagnosisConfidence.likely,
      Diseases.pneumonia: DiagnosisConfidence.likely,
      Diseases.malaria: DiagnosisConfidence.likely,
      Diseases.age: DiagnosisConfidence.likely,
      Diseases.uti: DiagnosisConfidence.likely,
      Diseases.typhoid: DiagnosisConfidence.likely,
    },
    Symptoms.bodyAches => {
      Diseases.urti: DiagnosisConfidence.likely,
      Diseases.malaria: DiagnosisConfidence.likely,
      Diseases.typhoid: DiagnosisConfidence.likely,
    },
    Symptoms.headache => {
      Diseases.urti: DiagnosisConfidence.likely,
      Diseases.malaria: DiagnosisConfidence.likely,
      Diseases.htn: DiagnosisConfidence.likely,
      Diseases.stroke: DiagnosisConfidence.likely,
      Diseases.typhoid: DiagnosisConfidence.likely,
    },
    Symptoms.dizziness => {
      Diseases.htn: DiagnosisConfidence.likely,
      Diseases.stroke: DiagnosisConfidence.likely,
      Diseases.malaria: DiagnosisConfidence.likely,
      Diseases.dm: DiagnosisConfidence.likely,
      Diseases.svt: DiagnosisConfidence.likely,
    },
    Symptoms.weakness => {
      Diseases.malaria: DiagnosisConfidence.likely,
      Diseases.typhoid: DiagnosisConfidence.likely,
      Diseases.dm: DiagnosisConfidence.likely,
      Diseases.anemia: DiagnosisConfidence.likely,
    },
    Symptoms.chillsRigors => {
      Diseases.malaria: DiagnosisConfidence.likely,
      Diseases.pneumonia: DiagnosisConfidence.likely,
      Diseases.typhoid: DiagnosisConfidence.likely,
      Diseases.uti: DiagnosisConfidence.likely,
    },
    Symptoms.weightLoss => {
      Diseases.dm: DiagnosisConfidence.likely,
      Diseases.typhoid: DiagnosisConfidence.likely,
    },
    Symptoms.cough => {
      Diseases.urti: DiagnosisConfidence.likely,
      Diseases.pneumonia: DiagnosisConfidence.likely,
      Diseases.asthma: DiagnosisConfidence.likely,
    },
    Symptoms.sob => {
      Diseases.asthma: DiagnosisConfidence.likely,
      Diseases.pneumonia: DiagnosisConfidence.likely,
      Diseases.mi: DiagnosisConfidence.likely,
      Diseases.anemia: DiagnosisConfidence.likely,
      Diseases.svt: DiagnosisConfidence.likely,
    },
    Symptoms.soreThroat => {
      Diseases.urti: DiagnosisConfidence.likely,
    },
    Symptoms.wheezing => {
      Diseases.asthma: DiagnosisConfidence.likely,
      Diseases.pneumonia: DiagnosisConfidence.likely,
    },
    Symptoms.earache => {
      Diseases.urti: DiagnosisConfidence.likely,
    },
    Symptoms.nasalCongestion => {
      Diseases.urti: DiagnosisConfidence.likely,
    },
    Symptoms.looseMotions => {
      Diseases.age: DiagnosisConfidence.likely,
      Diseases.typhoid: DiagnosisConfidence.likely,
    },
    Symptoms.nauseaVomiting => {
      Diseases.age: DiagnosisConfidence.likely,
      Diseases.mi: DiagnosisConfidence.likely,
      Diseases.typhoid: DiagnosisConfidence.likely,
      Diseases.malaria: DiagnosisConfidence.likely,
    },
    Symptoms.abdominalPain => {
      Diseases.age: DiagnosisConfidence.likely,
      Diseases.uti: DiagnosisConfidence.likely,
      Diseases.typhoid: DiagnosisConfidence.likely,
    },
    Symptoms.constipation => {
      Diseases.typhoid: DiagnosisConfidence.likely,
    },
    Symptoms.bloating => {
      Diseases.age: DiagnosisConfidence.likely,
    },
    Symptoms.burningMicturition => {
      Diseases.uti: DiagnosisConfidence.likely,
    },
    Symptoms.frequencyUrgency => {
      Diseases.uti: DiagnosisConfidence.likely,
      Diseases.dm: DiagnosisConfidence.likely,
    },
    Symptoms.polyuria => {
      Diseases.dm: DiagnosisConfidence.likely,
    },
    Symptoms.chestPain => {
      Diseases.mi: DiagnosisConfidence.likely,
      Diseases.asthma: DiagnosisConfidence.likely,
      Diseases.svt: DiagnosisConfidence.likely,
    },
    Symptoms.palpitations => {
      Diseases.mi: DiagnosisConfidence.likely,
      Diseases.htn: DiagnosisConfidence.likely,
      Diseases.anemia: DiagnosisConfidence.likely,
      Diseases.svt: DiagnosisConfidence.likely,
    },
    Symptoms.highBP => {
      Diseases.htn: DiagnosisConfidence.likely,
      Diseases.stroke: DiagnosisConfidence.likely,
    },
    Symptoms.facialDroop => {
      Diseases.stroke: DiagnosisConfidence.likely,
    },
    Symptoms.limbWeakness => {
      Diseases.stroke: DiagnosisConfidence.likely,
    },
    Symptoms.speechDifficulty => {
      Diseases.stroke: DiagnosisConfidence.likely,
    },
    Symptoms.alteredConsciousness => {
      Diseases.stroke: DiagnosisConfidence.likely,
      Diseases.malaria: DiagnosisConfidence.likely,
      Diseases.dm: DiagnosisConfidence.likely,
    },
    Symptoms.skinRash => {
      Diseases.urti: DiagnosisConfidence.likely,
      Diseases.typhoid: DiagnosisConfidence.likely,
    },
    Symptoms.pallor => {
      Diseases.anemia: DiagnosisConfidence.likely,
      Diseases.malaria: DiagnosisConfidence.likely,
    },
    Symptoms.animalBite => {
      Diseases.dogBite: DiagnosisConfidence.likely,
      Diseases.woundInfection: DiagnosisConfidence.likely,
    },
    Symptoms.woundBleeding => {
      Diseases.dogBite: DiagnosisConfidence.likely,
      Diseases.rta: DiagnosisConfidence.likely,
      Diseases.woundInfection: DiagnosisConfidence.likely,
    },
    Symptoms.woundPain => {
      Diseases.dogBite: DiagnosisConfidence.likely,
      Diseases.rta: DiagnosisConfidence.likely,
      Diseases.woundInfection: DiagnosisConfidence.likely,
    },
    Symptoms.swellingLump => {
      Diseases.woundInfection: DiagnosisConfidence.likely,
      Diseases.rta: DiagnosisConfidence.likely,
    },
    Symptoms.traumaImpact => {
      Diseases.rta: DiagnosisConfidence.likely,
    },
    Symptoms.headInjury => {
      Diseases.rta: DiagnosisConfidence.likely,
    },
    Symptoms.boneDeformity => {
      Diseases.rta: DiagnosisConfidence.likely,
    },
    Symptoms.traumaticPain => {
      Diseases.rta: DiagnosisConfidence.likely,
    },
    Symptoms.poisonIngestion => {
      Diseases.poisoning: DiagnosisConfidence.likely,
      Diseases.opPoisoning: DiagnosisConfidence.likely,
    },
    Symptoms.opExposure => {
      Diseases.opPoisoning: DiagnosisConfidence.likely,
    },
    Symptoms.excessiveSalivation => {
      Diseases.opPoisoning: DiagnosisConfidence.likely,
    },
  };
}
