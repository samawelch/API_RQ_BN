county_WWT_scenarios <- Norway_County_General_2020 |> 
    select(County_Name, none, primary, secondary, tertiary, exemplar) |>
    filter(exemplar) |> 
    crossing(wwt_scenario = factor(c("baseline", "partial_upgrade", "advanced_upgrade"),
                                   levels = c("baseline", "partial_upgrade", "advanced_upgrade"))) |> 
    mutate(none = case_when(wwt_scenario == "baseline" ~ none,
                            TRUE ~ 0),
           primary = case_when(wwt_scenario == "baseline" ~ primary,
                               TRUE ~ 0),
           secondary = case_when(wwt_scenario == "baseline" ~ secondary,
                                 wwt_scenario == "partial_upgrade" ~ 1 - tertiary,
                                 TRUE ~ 0),
           tertiary = case_when(wwt_scenario == "baseline" ~ tertiary,
                                wwt_scenario == "partial_upgrade" ~ tertiary,
                                 TRUE ~ 1)) |> 
    select(-exemplar)

county_WWT_scenario_removal <- county_WWT_scenarios |> 
    mutate(primary_removal = API_removal_rates_simple$max_med_removal[1] / 100,
           secondary_removal = API_removal_rates_simple$max_med_removal[2] / 100,
           tertiary_removal = API_removal_rates_simple$max_med_removal[3] / 100,
           total_removal = ((primary * primary_removal) + (secondary * secondary_removal) + (tertiary * tertiary_removal)))