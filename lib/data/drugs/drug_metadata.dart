import 'drugs.dart';

extension DrugMetadata on Drugs {
  String get brandNames {
    switch (this) {
      case Drugs.coamoxiclav:
        return 'Co-Amoxiclav';
      case Drugs.azithromycin:
        return 'Azithromycin';
      case Drugs.ceftriaxone:
        return 'Ceftriaxone';
      case Drugs.ciprofloxacin:
        return 'Ciprofloxacin';
      case Drugs.metronidazole:
        return 'Metronidazole';
      case Drugs.cloxacillin:
        return 'Cloxacillin';
      case Drugs.paracetamol:
        return 'Paracetamol';
      case Drugs.ibuprofen:
        return 'Ibuprofen';
      case Drugs.diclofenac:
        return 'Diclofenac';
      case Drugs.ventolin:
        return 'Salbutamol (Ventolin)';
      case Drugs.clenil:
        return 'Beclomethasone (Clenil)';
      case Drugs.aspirin:
        return 'Aspirin';
      case Drugs.clopidogrel:
        return 'Clopidogrel';
      case Drugs.atorvastatin:
        return 'Atorvastatin';
      case Drugs.amlodipine:
        return 'Amlodipine';
      case Drugs.lisinopril:
        return 'Lisinopril';
      case Drugs.isoptin:
        return 'Verapamil (Isoptin)';
      case Drugs.gtnSpray:
        return 'GTN Spray';
      case Drugs.gravinate:
        return 'Dimenhydrinate (Gravinate)';
      case Drugs.risek:
        return 'Omeprazole (Risek)';
      case Drugs.decadron:
        return 'Dexamethasone (Decadron)';
      case Drugs.metformin:
        return 'Metformin';
      case Drugs.glibenclamide:
        return 'Glibenclamide';
      case Drugs.insulin:
        return 'Insulin';
      case Drugs.activatedCharcoal:
        return 'Activated Charcoal';
      case Drugs.atropine:
        return 'Atropine';
      case Drugs.pam:
        return 'Pralidoxime (PAM)';
      case Drugs.tt:
        return 'Tetanus Toxoid';
      case Drugs.tig:
        return 'Tetanus Immunoglobulin';
      case Drugs.arv:
        return 'Anti-Rabies Vaccine';
      case Drugs.feso4:
        return 'Ferrous Sulfate';
      case Drugs.ors:
        return 'Oral Rehydration Salts';
    }
  }

  String get category {
    switch (this) {
      case Drugs.coamoxiclav:
      case Drugs.azithromycin:
      case Drugs.ceftriaxone:
      case Drugs.ciprofloxacin:
      case Drugs.metronidazole:
      case Drugs.cloxacillin:
        return 'Antibiotic';
      case Drugs.paracetamol:
      case Drugs.ibuprofen:
      case Drugs.diclofenac:
        return 'Analgesic / Antipyretic';
      case Drugs.ventolin:
      case Drugs.clenil:
        return 'Respiratory';
      case Drugs.aspirin:
      case Drugs.clopidogrel:
      case Drugs.atorvastatin:
      case Drugs.amlodipine:
      case Drugs.lisinopril:
      case Drugs.isoptin:
      case Drugs.gtnSpray:
        return 'Cardiovascular';
      case Drugs.gravinate:
        return 'Antiemetic';
      case Drugs.risek:
        return 'Proton Pump Inhibitor';
      case Drugs.decadron:
        return 'Corticosteroid';
      case Drugs.metformin:
      case Drugs.glibenclamide:
      case Drugs.insulin:
        return 'Antidiabetic';
      case Drugs.activatedCharcoal:
      case Drugs.atropine:
      case Drugs.pam:
        return 'Antidote';
      case Drugs.tt:
      case Drugs.tig:
      case Drugs.arv:
        return 'Vaccine / Immunoglobulin';
      case Drugs.feso4:
        return 'Hematologic';
      case Drugs.ors:
        return 'Supportive';
    }
  }
}
