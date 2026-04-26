import 'package:hmis/data/drugs/drugs.dart';
import 'package:hmis/data/diseases.dart';
import 'package:hmis/data/diagnosis_confidence.dart';
import 'package:hmis/data/drugs/indications.dart';
import 'package:hmis/models/models.dart';

class DiagnosisResult {
  final Diseases disease;
  final int score;

  DiagnosisResult(this.disease, this.score);
}

class ChitRepository {
  static List<DiagnosisResult> computeDifferentialFromChit(PatientChit chit) {
    final Map<Diseases, int> scores = {};

    // 1. Process Symptoms
    for (final entry in chit.symptoms) {
      final symptom = entry.symptom;
      final diagnoses = symptom.diagnoses;
      for (final disease in diagnoses.keys) {
        final confidence = diagnoses[disease];
        final weight = confidence == DiagnosisConfidence.likely ? 2 : 1;
        scores[disease] = (scores[disease] ?? 0) + weight;
      }
    }

    // 2. Process Findings
    for (final entry in chit.findings) {
      final finding = entry.finding;
      final diagnoses = finding.diagnoses;
      for (final disease in diagnoses.keys) {
        final confidence = diagnoses[disease];
        final weight = confidence == DiagnosisConfidence.likely ? 2 : 1;
        scores[disease] = (scores[disease] ?? 0) + weight;
      }
    }

    // 3. Process Vitals
    final flags = chit.vitals.flags;
    for (final flag in flags) {
      // Basic mapping: abnormalities increase scores for relevant diseases
      if (flag.name == 'Hypertension') {
        scores[Diseases.htn] = (scores[Diseases.htn] ?? 0) + 3;
      }
      if (flag.name == 'Tachycardia') {
        scores[Diseases.svt] = (scores[Diseases.svt] ?? 0) + 2;
        scores[Diseases.mi] = (scores[Diseases.mi] ?? 0) + 1;
      }
      if (flag.name == 'Desaturation') {
        scores[Diseases.pneumonia] = (scores[Diseases.pneumonia] ?? 0) + 3;
        scores[Diseases.asthma] = (scores[Diseases.asthma] ?? 0) + 2;
      }
    }

    final results = scores.entries
        .map((e) => DiagnosisResult(e.key, e.value))
        .toList();

    // Sort by score descending
    results.sort((a, b) => b.score.compareTo(a.score));

    return results;
  }

  static List<Drugs> suggestDrugs(List<Diseases> diagnoses) {
    final Set<Drugs> suggested = {};
    for (final disease in diagnoses) {
      for (final drug in Drugs.values) {
        if (drug.indications.containsKey(disease) &&
            drug.indications[disease] == DiagnosisConfidence.likely) {
          suggested.add(drug);
        }
      }
    }
    return suggested.toList();
  }
}
