import 'package:equatable/equatable.dart';
import 'package:hmis/data/actions.dart';
import 'package:hmis/data/diseases.dart';
import 'package:hmis/data/findings.dart';
import 'package:hmis/data/symptoms.dart';
import 'package:hmis/data/drugs/drugs.dart';
import 'package:hmis/data/preparations.dart';

export 'er_mark.dart';

class VitalFlag extends Equatable {
  final String name;
  final String vital;
  final int severity; // 1-3

  const VitalFlag({required this.name, required this.vital, this.severity = 1});

  @override
  List<Object?> get props => [name, vital, severity];
}

class Vitals extends Equatable {
  final int systolic;
  final int diastolic;
  final int pulse;
  final int spo2;
  final double temp;
  final int rr;

  const Vitals({
    this.systolic = 120,
    this.diastolic = 80,
    this.pulse = 80,
    this.spo2 = 98,
    this.temp = 98.6,
    this.rr = 16,
  });

  List<VitalFlag> get flags {
    final list = <VitalFlag>[];
    if (systolic > 160) {
      list.add(const VitalFlag(name: 'Hypertension', vital: 'BP', severity: 2));
    } else if (systolic < 90) {
      list.add(const VitalFlag(name: 'Hypotension', vital: 'BP', severity: 3));
    }

    if (pulse > 100) {
      list.add(
        const VitalFlag(name: 'Tachycardia', vital: 'Pulse', severity: 2),
      );
    } else if (pulse < 50) {
      list.add(
        const VitalFlag(name: 'Bradycardia', vital: 'Pulse', severity: 3),
      );
    }

    if (spo2 < 94) {
      list.add(
        const VitalFlag(name: 'Desaturation', vital: 'SpO2', severity: 3),
      );
    }

    if (temp > 100.4) {
      list.add(const VitalFlag(name: 'Fever', vital: 'Temp', severity: 1));
    }

    if (rr > 24) {
      list.add(const VitalFlag(name: 'Tachypnea', vital: 'RR', severity: 2));
    } else if (rr < 10) {
      list.add(const VitalFlag(name: 'Bradypnea', vital: 'RR', severity: 3));
    }
    return list;
  }

  @override
  List<Object?> get props => [systolic, diastolic, pulse, spo2, temp, rr];

  Vitals copyWith({
    int? systolic,
    int? diastolic,
    int? pulse,
    int? spo2,
    double? temp,
    int? rr,
  }) {
    return Vitals(
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      pulse: pulse ?? this.pulse,
      spo2: spo2 ?? this.spo2,
      temp: temp ?? this.temp,
      rr: rr ?? this.rr,
    );
  }
}

class ComplaintEntry extends Equatable {
  final Symptoms symptom;
  final String duration;

  const ComplaintEntry({required this.symptom, this.duration = '1 day'});

  @override
  List<Object?> get props => [symptom, duration];
}

class FindingEntry extends Equatable {
  final Findings finding;
  final String notes;

  const FindingEntry({required this.finding, this.notes = ''});

  @override
  List<Object?> get props => [finding, notes];
}

class RxEntry extends Equatable {
  final Drugs drug;
  final Preparations prep;
  final String dose;
  final Frequencies freq;
  final DrugDuration duration;

  const RxEntry({
    required this.drug,
    this.prep = Preparations.tablet,
    this.dose = '1',
    this.freq = Frequencies.sos,
    this.duration = DrugDuration.threeDays,
  });

  @override
  List<Object?> get props => [drug, prep, dose, freq, duration];

  RxEntry copyWith({
    Drugs? drug,
    Preparations? prep,
    String? dose,
    Frequencies? freq,
    DrugDuration? duration,
  }) {
    return RxEntry(
      drug: drug ?? this.drug,
      prep: prep ?? this.prep,
      dose: dose ?? this.dose,
      freq: freq ?? this.freq,
      duration: duration ?? this.duration,
    );
  }
}

class PatientChit extends Equatable {
  final String patientName;
  final int age;
  final bool isMale;
  final Vitals vitals;
  final List<ComplaintEntry> symptoms;
  final List<FindingEntry> findings;
  final List<Diseases> diseases;
  final List<RxEntry> prescriptions;
  final List<AllActions> actions;

  const PatientChit({
    this.patientName = '',
    this.age = 30,
    this.isMale = true,
    this.vitals = const Vitals(),
    this.symptoms = const [],
    this.findings = const [],
    this.diseases = const [],
    this.prescriptions = const [],
    this.actions = const [],
  });

  @override
  List<Object?> get props => [
    patientName,
    age,
    isMale,
    vitals,
    symptoms,
    findings,
    diseases,
    prescriptions,
    actions,
  ];

  PatientChit copyWith({
    String? patientName,
    int? age,
    bool? isMale,
    Vitals? vitals,
    List<ComplaintEntry>? symptoms,
    List<FindingEntry>? findings,
    List<Diseases>? diseases,
    List<RxEntry>? prescriptions,
    List<AllActions>? actions,
  }) {
    return PatientChit(
      patientName: patientName ?? this.patientName,
      age: age ?? this.age,
      isMale: isMale ?? this.isMale,
      vitals: vitals ?? this.vitals,
      symptoms: symptoms ?? this.symptoms,
      findings: findings ?? this.findings,
      diseases: diseases ?? this.diseases,
      prescriptions: prescriptions ?? this.prescriptions,
      actions: actions ?? this.actions,
    );
  }

  String toText() {
    final complaints = symptoms.isEmpty
        ? 'none'
        : symptoms.map((e) => '${e.symptom.name} (${e.duration})').join(', ');
    final findingsList = findings.isEmpty
        ? 'none'
        : findings.map((e) => e.finding.name).join(', ');
    final diagnoses = diseases.isEmpty
        ? 'none'
        : diseases.map((e) => e.code).join(', ');
    final prescriptionsList = prescriptions.isEmpty
        ? 'none'
        : prescriptions
              .map(
                (e) =>
                    '${e.drug.name} ${e.prep.name} ${e.dose} ${e.freq.toString().split('.').last}',
              )
              .join('; ');
    final actionsList = actions.isEmpty
        ? 'none'
        : actions.map((e) => e.name).join(', ');

    return "Name: $patientName | Age: $age | Sex: ${isMale ? 'M' : 'F'}\n"
        "Vitals: BP ${vitals.systolic}/${vitals.diastolic} | P: ${vitals.pulse} | SpO2: ${vitals.spo2}% | T: ${vitals.temp.toStringAsFixed(1)}°F | RR: ${vitals.rr}\n"
        "Complaints: $complaints\n"
        "Findings: $findingsList\n"
        "Diagnoses: $diagnoses\n"
        "Prescriptions: $prescriptionsList\n"
        "Actions: $actionsList";
  }
}
