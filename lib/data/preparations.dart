enum Preparations {
  tablet,
  capsule,
  injection,
  syrup,
  ointment,
  cream,
  drops,
  inhaler,
  patch,
  suppository,
  other,
}

const doses = [
  '8mg',
  '10mg',
  '25mg',
  '40mg',
  '50mg',
  '80mg',
  '100mg',
  '125mg',
  '200mg',
  '250mg',
  '300mg',
  '400mg',
  '500mg',
  '600mg',
  '800mg',
  '1g',
  '2g',
  '4.5g',
];

enum Units {
  mg,
  g,
  ml,
  drop,
  tsf,
}

enum Frequencies {
  stat,
  od,
  bd,
  tds,
  qid,
  sos,
}

enum Routes {
  orally,
  intravenously,
  intramuscularly,
  subcutaneously,
  sublingually,
  pernasally,
  rectally,
  vaginally,
}

enum DrugDuration {
  threeDays,
  fiveDays,
  sevenDays,
  tenDays,
  fourteenDays,
  twentyOneDays,
  oneMonth,
  twoMonths,
  threeMonths,
  sixMonths,
  oneYear,
}
