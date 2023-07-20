# How do we get the maximum and minimum possible (or at least 95% possible) values for each node

# First, get the highest & lowest 95 CI for g per capita
test <- LM_Predictions |> group_by(weight_class) |> reframe(g_per_capita_CI_95_lower = min(CI_95_lower),
                                                    g_per_capita_CI_95_upper = max(CI_95_upper)) |>
    # Estimate bounds for total kg sold
    mutate(weight_class = factor(weight_class, c("light", "medium", "heavy")),
           Min_Pop = 0.1,
           Max_Pop = 1.7,
           # Technically this is inadequate for negative estradiol sales, but I don't think we care
           # about that level of precision below 0
           kg_total_CI_95_lower = (g_per_capita_CI_95_lower * 1e-3) * (Min_Pop * 1e6),
           kg_total_CI_95_upper = (g_per_capita_CI_95_upper * 1e-3) * (Max_Pop * 1e6)) |> 
    arrange(weight_class) |> 
    # Estimate bounds for PEC_influent (ug)
    mutate(Max_Wastewater = 80,
           Min_Wastewater = 10,
           # To get minimum values, minimise mass & maximise dilution
           PEC_inf_ugL_CI_95_lower = (kg_total_CI_95_lower * 1e9) / (Max_Wastewater * 1e9),
           # and vice verse
           PEC_inf_ugL_CI_95_upper = (kg_total_CI_95_upper * 1e9) / (Min_Wastewater * 1e9)) |> 
    # Estimate bounds for PEC_effluent (ug)
    mutate(Max_Removal = 0.85,
           Min_Removal = 0.15,
           PEC_eff_ugL_CI_95_lower = PEC_inf_ugL_CI_95_lower * (1 - Max_Removal),
           PEC_eff_ugL_CI_95_upper = PEC_inf_ugL_CI_95_upper * (1 - Min_Removal)) |> 
    # Estimate bounds for PEC_SW (ug)
    mutate(PEC_sw_ugL_CI_95_lower = PEC_eff_ugL_CI_95_lower / 10,
           PEC_sw_ugL_CI_95_upper = PEC_eff_ugL_CI_95_upper / 10) |> 
    # Add PNECs
    mutate(PNEC_API_E2_diclo_ibu = c(1.8e-04, 4.0e-02, 1.4e-01),
           PNEC_API_EE2_cipro_para = c(3.2e-06, 1.0e-01, 1.0e+01)) |> 
    # Estimate bounds for RQ
    mutate(RQ_CI_95_lower = PEC_sw_ugL_CI_95_lower / pmax(PNEC_API_E2_diclo_ibu, PNEC_API_EE2_cipro_para),
           RQ_CI_95_upper = PEC_sw_ugL_CI_95_upper / pmin(PNEC_API_E2_diclo_ibu, PNEC_API_EE2_cipro_para))
    

