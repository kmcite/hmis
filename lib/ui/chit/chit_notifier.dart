import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/data/actions.dart';
import 'package:hmis/data/symptoms.dart';
import 'package:hmis/data/findings.dart';
import 'package:hmis/data/diseases.dart';
import 'package:hmis/main.dart';
import 'package:objectbox/objectbox.dart';

class ChitNotifier extends Cubit<PatientChit> {
  final Store store;

  ChitNotifier(this.store) : super(const PatientChit());

  // ─── DEMOGRAPHICS ──────────────────────────────────────────

  void updateName(String name) {
    emit(state.copyWith(patientName: name));
  }

  void updateAge(int age) {
    emit(state.copyWith(age: age));
  }

  void toggleGender() {
    emit(state.copyWith(isMale: !state.isMale));
  }

  // ─── VITALS ────────────────────────────────────────────────

  void updateVitals(Vitals updated) {
    emit(state.copyWith(vitals: updated));
  }

  void updateSystolic(int delta) {
    emit(
      state.copyWith(
        vitals: state.vitals.copyWith(
          systolic: (state.vitals.systolic + delta).clamp(60, 250),
        ),
      ),
    );
  }

  void updateDiastolic(int delta) {
    emit(
      state.copyWith(
        vitals: state.vitals.copyWith(
          diastolic: (state.vitals.diastolic + delta).clamp(40, 150),
        ),
      ),
    );
  }

  void updatePulse(int delta) {
    emit(
      state.copyWith(
        vitals: state.vitals.copyWith(
          pulse: (state.vitals.pulse + delta).clamp(30, 220),
        ),
      ),
    );
  }

  void updateSpO2(int delta) {
    emit(
      state.copyWith(
        vitals: state.vitals.copyWith(
          spo2: (state.vitals.spo2 + delta).clamp(50, 100),
        ),
      ),
    );
  }

  void updateTemp(double delta) {
    emit(
      state.copyWith(
        vitals: state.vitals.copyWith(
          temp: (state.vitals.temp + delta).clamp(94.0, 108.0),
        ),
      ),
    );
  }

  void updateRR(int delta) {
    emit(
      state.copyWith(
        vitals: state.vitals.copyWith(
          rr: (state.vitals.rr + delta).clamp(8, 60),
        ),
      ),
    );
  }

  // ─── COMPLAINTS ──────────────────────────────────────────

  void addComplaint(Symptoms symptom, String duration) {
    final list = List<ComplaintEntry>.from(state.symptoms);
    list.removeWhere((e) => e.symptom == symptom);
    list.add(ComplaintEntry(symptom: symptom, duration: duration));
    emit(state.copyWith(symptoms: list));
  }

  void toggleComplaint(Symptoms symptom) {
    final list = List<ComplaintEntry>.from(state.symptoms);
    final exists = list.any((e) => e.symptom == symptom);
    if (exists) {
      list.removeWhere((e) => e.symptom == symptom);
    } else {
      list.add(ComplaintEntry(symptom: symptom));
    }
    emit(state.copyWith(symptoms: list));
  }

  void updateComplaintDuration(int index, String duration) {
    final list = List<ComplaintEntry>.from(state.symptoms);
    list[index] = ComplaintEntry(
      symptom: list[index].symptom,
      duration: duration,
    );
    emit(state.copyWith(symptoms: list));
  }

  void removeComplaint(int index) {
    final list = List<ComplaintEntry>.from(state.symptoms)..removeAt(index);
    emit(state.copyWith(symptoms: list));
  }

  // ─── FINDINGS ────────────────────────────────────────────

  void toggleFinding(Findings finding) {
    final list = List<FindingEntry>.from(state.findings);
    final exists = list.any((e) => e.finding == finding);
    if (exists) {
      list.removeWhere((e) => e.finding == finding);
    } else {
      list.add(FindingEntry(finding: finding));
    }
    emit(state.copyWith(findings: list));
  }

  // ─── DIAGNOSES ───────────────────────────────────────────

  void toggleDiagnosis(Diseases disease) {
    final list = List<Diseases>.from(state.diseases);
    if (list.contains(disease)) {
      list.remove(disease);
    } else {
      list.add(disease);
    }
    emit(state.copyWith(diseases: list));
  }

  bool isDiagnosisSelected(Diseases disease) {
    return state.diseases.contains(disease);
  }

  // ─── PRESCRIPTIONS ───────────────────────────────────────

  void addRx(RxEntry entry) {
    final list = List<RxEntry>.from(state.prescriptions)..add(entry);
    emit(state.copyWith(prescriptions: list));
  }

  void removeRx(int index) {
    final list = List<RxEntry>.from(state.prescriptions)..removeAt(index);
    emit(state.copyWith(prescriptions: list));
  }

  void updateRx(int index, RxEntry updated) {
    final list = List<RxEntry>.from(state.prescriptions);
    list[index] = updated;
    emit(state.copyWith(prescriptions: list));
  }

  // ─── ACTIONS ─────────────────────────────────────────────

  void toggleAction(AllActions action) {
    final list = List<AllActions>.from(state.actions);
    if (list.contains(action)) {
      list.remove(action);
    } else {
      list.add(action);
    }
    emit(state.copyWith(actions: list));
  }

  // ─── PERSISTENCE ─────────────────────────────────────────

  void saveToErMark({required int shift, required int caseType}) {
    final mark = ErMark(
      patientName: state.patientName,
      ageYears: state.age,
      isMale: state.isMale,
      remarks: state.toText(),
    );
    mark.shift = shift;
    mark.caseType = caseType;

    store.put(mark);
    reset();
  }

  // ─── RESET ───────────────────────────────────────────────

  void reset() {
    emit(const PatientChit());
  }
}
