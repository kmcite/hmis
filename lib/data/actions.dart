enum AllActions {
  o2Inhalation("O2 Inhalation"),
  iVLine16G("IV Line (16G)"),
  iVLine18G("IV Line (18G)"),
  iVLine20G("IV Line (20G)"),
  iVLine22G("IV Line (22G)"),
  iVLine24G("IV Line (24G)"),
  iVFluidsNSS500ml("IV Fluid (N/S 500ml)"),
  iVFluidsRL500ml("IV Fluid (R/L 500ml)"),
  iVFluidsDextrose5500ml("IV Fluid (Dextrose 5% 500ml)"),
  monitorVitals1hourly("Monitor Vitals 1 hourly"),
  monitorVitals4hourly("Monitor Vitals 4 hourly"),
  woundIrrigationDressing("Wound Irrigation & Dressing"),
  woundStitching("Wound Stitching"),
  abscessDrainageASD("Abscess Drainage (ASD)"),
  splintingPOP("Splinting / POP"),
  nGTubeInsertion("N/G Tube Insertion"),
  urinaryCatheterization("Urinary Catheterization"),
  gastricLavage("Gastric Lavage"),
  activatedCharcoal("Activated Charcoal (via N/G or PO)"),
  admitToWard("Admit to Ward"),
  referToTertiaryCare("Refer to Tertiary Care"),
  stableForDischarge("Stable for Discharge"),
  keepNPO("Keep NPO"),
  reviewIn3Days("Review in 3 days"),
  reviewIfNoImprovement("Review if no improvement")
  ;

  final String name;
  const AllActions(this.name);
}
