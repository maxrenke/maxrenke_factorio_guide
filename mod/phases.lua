local phases = {

  {
    id = "phase_1",
    name = "Phase 1: First Steps",
    short_desc = "Get your footing: mine resources, build your first furnace, smelt iron",
    tasks = {
      { id = "p1_mine_iron",   text = "Mine 50 iron ore",                  trigger = { type = "produced", name = "iron-ore",          count = 50  } },
      { id = "p1_mine_coal",   text = "Mine 20 coal",                      trigger = { type = "produced", name = "coal",               count = 20  } },
      { id = "p1_build_drill", text = "Place your first Burner Mining Drill", trigger = { type = "built",    name = "burner-mining-drill"               } },
      { id = "p1_build_furnace", text = "Place a Stone Furnace",           trigger = { type = "built",    name = "stone-furnace"                     } },
      { id = "p1_smelt_iron",  text = "Smelt 50 iron plates",              trigger = { type = "produced", name = "iron-plate",         count = 50  } },
      { id = "p1_craft_gear",  text = "Craft iron gear wheels",            trigger = { type = "produced", name = "iron-gear-wheel",    count = 1   } },
    },
  },

  {
    id = "phase_2",
    name = "Phase 2: First Power & Red Science",
    short_desc = "Get power running and research your first technology",
    tasks = {
      { id = "p2_build_boiler",  text = "Place a Boiler",                           trigger = { type = "built",     name = "boiler"                          } },
      { id = "p2_build_engine",  text = "Place a Steam Engine",                     trigger = { type = "built",     name = "steam-engine"                    } },
      { id = "p2_build_lab",     text = "Place a Research Lab",                     trigger = { type = "built",     name = "lab"                             } },
      { id = "p2_red_science",   text = "Craft 10 red (Automation) science packs",  trigger = { type = "produced",  name = "automation-science-pack", count = 10 } },
      { id = "p2_research_auto", text = "Research Automation",                      trigger = { type = "tech",      name = "automation"                      } },
    },
  },

  {
    id = "phase_3",
    name = "Phase 3: Automate Red + Green Science",
    short_desc = "Automate science production and unlock logistics",
    tasks = {
      { id = "p3_build_assembler",   text = "Place your first Assembling Machine",          trigger = { type = "built",    name = "assembling-machine-1"                     } },
      { id = "p3_automate_circuits", text = "Produce 100 green circuits automatically",     trigger = { type = "produced", name = "electronic-circuit",      count = 100 } },
      { id = "p3_red_flowing",       text = "Produce 50 red science packs",                trigger = { type = "produced", name = "automation-science-pack",  count = 50  } },
      { id = "p3_green_flowing",     text = "Produce 50 green science packs",              trigger = { type = "produced", name = "logistic-science-pack",    count = 50  } },
      { id = "p3_research_logistics", text = "Research Logistics (green science unlocked)", trigger = { type = "tech",     name = "logistics"                              } },
    },
  },

  {
    id = "phase_4",
    name = "Phase 4: Smelting Column & Bus Foundation",
    short_desc = "Scale up smelting and lay down your main bus",
    tasks = {
      { id = "p4_steel_research", text = "Research Steel Processing",    trigger = { type = "tech",     name = "steel-processing"              } },
      { id = "p4_smelt_steel",    text = "Produce 100 steel plates",     trigger = { type = "produced", name = "steel-plate",    count = 100 } },
      { id = "p4_stone_bricks",   text = "Produce 100 stone bricks",     trigger = { type = "produced", name = "stone-brick",    count = 100 } },
      { id = "p4_big_iron",       text = "Produce 500 iron plates",      trigger = { type = "produced", name = "iron-plate",     count = 500 } },
      { id = "p4_big_copper",     text = "Produce 500 copper plates",    trigger = { type = "produced", name = "copper-plate",   count = 500 } },
    },
  },

  {
    id = "phase_5",
    name = "Phase 5: Military Science & Defense",
    short_desc = "Build defenses and unlock military technology",
    tasks = {
      { id = "p5_build_turret",   text = "Place a Gun Turret",                    trigger = { type = "built",    name = "gun-turret"                         } },
      { id = "p5_build_wall",     text = "Place Stone Wall segments",             trigger = { type = "built",    name = "stone-wall"                         } },
      { id = "p5_military_flow",  text = "Produce 50 military science packs",     trigger = { type = "produced", name = "military-science-pack", count = 50  } },
      { id = "p5_research_mil",   text = "Research Military (any)",               trigger = { type = "tech",     name = "military"                           } },
    },
  },

  {
    id = "phase_6",
    name = "Phase 6: Oil & Blue Science",
    short_desc = "Set up oil refining and unlock chemical science packs",
    tasks = {
      { id = "p6_oil_research",     text = "Research Oil Processing",                  trigger = { type = "tech",     name = "oil-processing"                       } },
      { id = "p6_build_refinery",   text = "Place an Oil Refinery",                    trigger = { type = "built",    name = "oil-refinery"                         } },
      { id = "p6_build_chem_plant", text = "Place a Chemical Plant",                   trigger = { type = "built",    name = "chemical-plant"                       } },
      { id = "p6_produce_plastic",  text = "Produce 50 plastic bars",                  trigger = { type = "produced", name = "plastic-bar",          count = 50  } },
      { id = "p6_produce_sulfur",   text = "Produce 20 sulfur",                        trigger = { type = "produced", name = "sulfur",                count = 20  } },
      { id = "p6_produce_red_circ", text = "Produce 50 red (advanced) circuits",       trigger = { type = "produced", name = "advanced-circuit",      count = 50  } },
      { id = "p6_blue_flowing",     text = "Produce 50 blue science packs",            trigger = { type = "produced", name = "chemical-science-pack", count = 50  } },
    },
  },

  {
    id = "phase_7",
    name = "Phase 7: Construction Robots",
    short_desc = "Unlock robots and set up your first roboport network",
    tasks = {
      { id = "p7_research_robotics", text = "Research Construction Robotics", trigger = { type = "tech",     name = "construction-robotics"              } },
      { id = "p7_build_roboport",    text = "Place a Roboport",               trigger = { type = "built",    name = "roboport"                           } },
      { id = "p7_produce_bots",      text = "Produce 10 construction robots", trigger = { type = "produced", name = "construction-robot", count = 10  } },
      { id = "p7_logistic_bots",     text = "Produce 10 logistic robots",     trigger = { type = "produced", name = "logistic-robot",      count = 10  } },
    },
  },

  {
    id = "phase_8",
    name = "Phase 8: Solar Power",
    short_desc = "Build a solar array to supplement or replace steam power",
    tasks = {
      { id = "p8_research_solar",  text = "Research Solar Energy",       trigger = { type = "tech",     name = "solar-energy"              } },
      { id = "p8_produce_solar",   text = "Produce 25 solar panels",     trigger = { type = "produced", name = "solar-panel",  count = 25 } },
      { id = "p8_produce_accum",   text = "Produce 21 accumulators",     trigger = { type = "produced", name = "accumulator",  count = 21 } },
      { id = "p8_produce_batt",    text = "Produce 50 batteries",        trigger = { type = "produced", name = "battery",      count = 50 } },
    },
  },

  {
    id = "phase_9",
    name = "Phase 9: Yellow (Production) Science",
    short_desc = "Scale up to production science and red belts",
    tasks = {
      { id = "p9_upgrade_belts",    text = "Research Logistics 2 (red belts)",                trigger = { type = "tech",     name = "logistics-2"                           } },
      { id = "p9_blue_circuits",    text = "Produce 50 blue circuits (processing units)",     trigger = { type = "produced", name = "processing-unit",          count = 50  } },
      { id = "p9_produce_lds",      text = "Produce 50 low density structures",               trigger = { type = "produced", name = "low-density-structure",     count = 50  } },
      { id = "p9_yellow_flowing",   text = "Produce 50 yellow science packs",                 trigger = { type = "produced", name = "production-science-pack",   count = 50  } },
    },
  },

  {
    id = "phase_10",
    name = "Phase 10: Power Armor & Logistics Network",
    short_desc = "Kit out your character with endgame personal equipment",
    tasks = {
      { id = "p10_log_system",      text = "Research Logistics System",            trigger = { type = "tech", name = "logistic-system"            } },
      { id = "p10_power_armor",     text = "Research Power Armor Mk2",             trigger = { type = "tech", name = "power-armor-2"              } },
      { id = "p10_personal_rob",    text = "Research Personal Roboport Mk2",       trigger = { type = "tech", name = "personal-roboport-mk2"     } },
      { id = "p10_fusion",          text = "Research Fusion Reactor Equipment",    trigger = { type = "tech", name = "fusion-reactor-equipment"   } },
    },
  },

  {
    id = "phase_11",
    name = "Phase 11: Nuclear Power",
    short_desc = "Build a nuclear power plant to handle late-game energy demands",
    tasks = {
      { id = "p11_research_nuke",    text = "Research Nuclear Power",          trigger = { type = "tech",     name = "nuclear-power"              } },
      { id = "p11_research_uranium", text = "Research Uranium Processing",     trigger = { type = "tech",     name = "uranium-processing"         } },
      { id = "p11_build_reactor",    text = "Place a Nuclear Reactor",         trigger = { type = "built",    name = "nuclear-reactor"            } },
      { id = "p11_build_centrifuge", text = "Place a Centrifuge",              trigger = { type = "built",    name = "centrifuge"                 } },
      { id = "p11_produce_fuel",     text = "Produce nuclear fuel cells",      trigger = { type = "produced", name = "nuclear-fuel",   count = 1  } },
    },
  },

  {
    id = "phase_12",
    name = "Phase 12: Purple (Utility) Science",
    short_desc = "Unlock utility science and high-tier productivity modules",
    tasks = {
      { id = "p12_purple_flowing",   text = "Produce 50 utility science packs",              trigger = { type = "produced", name = "utility-science-pack",    count = 50 } },
      { id = "p12_research_beacons", text = "Research Effect Transmission (Beacons)",        trigger = { type = "tech",     name = "effect-transmission"               } },
      { id = "p12_research_prod3",   text = "Research Productivity Module 3",                trigger = { type = "tech",     name = "productivity-module-3"             } },
    },
  },

  {
    id = "phase_13",
    name = "Phase 13: Modules & Beacons",
    short_desc = "Soup up your production with speed and productivity modules",
    tasks = {
      { id = "p13_build_beacon",    text = "Place a Beacon",                              trigger = { type = "built",    name = "beacon"                              } },
      { id = "p13_speed3",          text = "Produce Speed Module 3",                      trigger = { type = "produced", name = "speed-module-3",         count = 1  } },
      { id = "p13_prod3",           text = "Produce Productivity Module 3",               trigger = { type = "produced", name = "productivity-module-3",  count = 1  } },
      { id = "p13_kovarex",         text = "Research Kovarex Enrichment (optional)",      trigger = { type = "tech",     name = "kovarex-enrichment-process"          } },
    },
  },

  {
    id = "phase_14",
    name = "Phase 14: Rocket Components",
    short_desc = "Produce all rocket parts and build the silo",
    tasks = {
      { id = "p14_research_silo",    text = "Research Rocket Silo",                             trigger = { type = "tech",     name = "rocket-silo"                           } },
      { id = "p14_build_silo",       text = "Place a Rocket Silo",                              trigger = { type = "built",    name = "rocket-silo"                           } },
      { id = "p14_rocket_fuel",      text = "Produce 100 rocket fuel",                          trigger = { type = "produced", name = "rocket-fuel",           count = 100 } },
      { id = "p14_rcu",              text = "Produce 100 rocket control units",                 trigger = { type = "produced", name = "rocket-control-unit",   count = 100 } },
      { id = "p14_lds_rocket",       text = "Produce 500 low density structures (for rocket)",  trigger = { type = "produced", name = "low-density-structure", count = 500 } },
      { id = "p14_satellite",        text = "Craft a Satellite",                                trigger = { type = "crafted",  name = "satellite",             count = 1   } },
    },
  },

  {
    id = "phase_15",
    name = "Phase 15: Launch the Rocket!",
    short_desc = "The final goal - send that rocket to space!",
    tasks = {
      { id = "p15_launch_rocket", text = "Launch the rocket!", trigger = { type = "rocket" } },
    },
  },

}

return phases
