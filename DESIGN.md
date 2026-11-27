# Build a Nuraghe: design, rules and the source of every number

Prototype v0.1.0, Godot 4.7.2. Local only: nothing is published or hosted.

## The brief (Mark's words, kept)
- "you have to get a team of oxen or builders together, you chose how to build the nuraghe, you have to finish the
  nuraghe say in 2-3 years (90 day years) otherwise you lose"
- "build a nuraghe from a local or nearby quarry"
- "you start 1 tower, advance to multi tower, you can ask for help but maybe people say no"
- "yeah mimic the model, basically lets set the groundwork so we can produce something that allows us in the future
  to crowdsource ideas for building nuraghe for real to test in our sim models"

## How a game goes
1. **Level**: 1 = one tower, 2 seasons (180 working days). 2 = a central tower plus two lateral towers (TWR_N = 3),
   3 seasons (270 days).
2. **Three choices**, each with its evidence tag and a source card (one line + citation):
   - quarry: near bedrock (200 m) or far boulder field (1 km);
   - hauling: sledge with a human crew, ropes and log rollers, or oxen;
   - lifting: levers course by course, stair inside the wall, earth ramp, or a timber frame with a pulley.
3. **Play**: a day ticks every 0.45 s (x1/x2/x4, pause). Each day your builders work 8 hours. Work flows through
   the model's four stages, quarry -> haul -> dress -> set (SCOPE rule 2), with the block model's task priority
   set > haul > dress > quarry. The tower rises course by course (16 courses of 0.9 m on 14 m).
   - **Builders**: recruit from your village (+/-). Each costs 5 kg of food to join and eats 1 kg a day.
   - **Ox teams** (oxen haul only): each eats 2 kg of fodder a day; each block needs 2 teams.
   - **Ask for help**: each village shows its distance, its helpers, its trust in you, how busy it is and the
     chance of yes. In-game line: "A village says yes more often if it trusts you, is not busy with its own tower
     and lives close."
   - **Neighbours ask you**: send a quarter of your builders for 10 days (trust +0.1) or refuse (trust -0.2 if that
     village helped you before; no change otherwise).
   - A day without enough food: nobody works and a quarter of the builders go home.
   - Between seasons the harvest refills the stores.
4. **End**: win ("The nuraghe stands!") when the last block is set; lose ("The season ended — the walls stand
   unfinished") at the deadline. The end screen shows work done, asks, the evidence tags of your methods and
   **Your strategy** (JSON; copy / save as file; see STRATEGY_SCHEMA.md).

The constraint that makes it a game: with the model's labour, a village of 40 people (16 builders) cannot finish one
tower alone in two seasons with any choice (tests/balance.gd: 0 wins out of 30 for every combination). You need
help, and help depends on trust, how busy the neighbours are and distance, as in the model.

## Game variable -> model parameter
Config = `protocol_paper/zeynep_branch_stage/config/config_full_audited.yaml`; code = `.../code/` (read-only).
`tools/derive_numbers.py` imports the model's own `lit.py` functions and prints the derived values
(`tools/derived_numbers.json`).

| game variable | model parameter (config key / code) | value in game |
|---|---|---|
| hours per working day | `hours_per_day` | 8 |
| season length | `alliance.season_days` (NUR 185; one season = one year) | 90 days |
| deadline | none (the model runs until done; `max_seasons` is a safety stop) | game rule: 2 / 3 seasons |
| towers per level | site `TWR_N` (`site_fields.towers`) | 1 / 3 |
| stone per tower | `stone.tonnes_per_tower`; multi-tower = x TWR_N (`lit.target_kg`) | 1,350 t; 4,050 t |
| blocks | `stone.block_median_kg` 450 (game uses the median for every block; the model draws lognormal sigma 0.6) | 3,000 / 9,000 |
| quarry: near bedrock | `lit_scenarios.list.S1b_joints_low` -> `quarry_ph_m3.joints_low` 11.1 x 565.8 m3 (density `webster_density_kg_m3` 2,386) | 6,280 ph/tower |
| quarry: far boulders | `S1a_scree` -> `quarry_ph_m3.scree` 2.0 x 565.8 m3 | 1,132 ph/tower |
| quarry distance | haul_m (per site, from `cache/sites_haul.csv`); near = `verify.webster_target_haul_m` 200; far = `quarry.near_site_fixed_face_m` 1,000 | 200 m / 1,000 m |
| dressing | `webster_md_per_tower.dress` 1,300 x `v11.webster_day_hours.dress` 8 | 10,400 ph/tower |
| walling without lift | `webster_md_per_tower.build` 700 x 8 x (1 - `lift_share_of_build` 0.5) | 2,800 ph/tower |
| lift: levers | `S4a_lever` -> `lit.stage_hours` lift = blocks x sum(course weight x course index) x `lever_ph_per_block_course` 0.37 | 6,537 ph/tower |
| lift: stair | `S4c_internal_stair` -> blocks x (1 - w0) x 0.37 x `stair_lever_last_m` 1.0 / course 0.9 | 1,111 ph/tower |
| lift: earth ramp | `S4b_ramp` -> `lit.ramp_ph_per_tower` (slope 0.2, width 3 m, dig/compact/carry, build + remove) | 19,141 ph/tower |
| lift: pulley | no model equivalent (WHAT-IF) | game rule: 1,400 ph/tower + 150 kg stores |
| haul: sledge, human crew | `S3c_dry_ground` (mu 0.38); crew = ceil(450 / (`f_person_kgf` 30 / 0.38)) | 6 people per block |
| haul speeds | `transport.drag_speed_ms` 0.27, `return_walk_ms` 1.39, `load_unload_h` 0.25 | per trip |
| haul: rollers | no model equivalent (DEMONSTRATED, no measurements) | game rule: 4 people per block |
| haul: oxen | `S3e_oxen` -> `lit_scenarios.oxen`: `pull_N_per_ox` 515, `yoke_efficiency` [0.95, 0.80, 0.63], `speed_ms`/`return_speed_ms` 0.75, `men_per_team` 2, mu 0.3; yokes per block = `lit.oxen_yokes(450 kg)` | 2 teams + 4 people per block |
| ox teams available | none | game rule: 6 / 12 |
| fodder | none | game rule: 2 kg per team per day |
| village size | `mr_work_party.residents_by_towers` (TWR 1: 5-40; TWR 3: 110-185) | 40 / 110 (40 = top of range, Webster 1991: 853; 110 = bottom) |
| builders available | `mr_work_party.adult_share` 0.4 x residents | 16 / 44 |
| builders you recruit | the model uses all of them (`builders_rule`); in the game you choose how many | player choice |
| food per person | `MOST_REALISTIC_S12_central.food_cap.ration_kg` 1.0 (S12 caps hands by surplus; the game turns this into a store) | 1 kg/day |
| food stores, harvest | S12 derives surplus from catchment land; no direct equivalent | game rule: 1,600 / 3,600 kg per season |
| recruiting cost | none | game rule: 5 kg per builder |
| ask a village | `alliance.request()`: P(yes) = sigmoid(`beta0` 0 + `beta1` 2.0 x T(j,i) - `beta2` 0.05 x backlog_days(j) - `beta3` 0.2 x km) | same formula |
| trust start | `alliance.trust0` | 0.5 |
| you help a village that asked | `alliance.delta_up`: asker's trust in the helper + 0.1 | +0.1 |
| you refuse a village that helped you | `alliance.delta_down` (only when the refuser had received help from the asker) | -0.2 |
| you refuse a village that never helped you | model: no trust change | no change |
| neighbour busy days | `backlog_days(j)` = remaining task hours / capacity; helping adds to it | game rule: start 15 / 0 / 30 (L2: 20 / 0 / 40), -1 per day, +10 when they help |
| neighbour distance | straight-line km, within `alliance.R_m` 10 km | game rule: 2, 5, 8 km |
| neighbour size and helpers | their residents x `adult_share`; help joins the stage (`help_mode: join`) | game rule: 20/30/50 people (L2 40/60/110) |
| help duration | the model's help lasts one stage task | game rule: 10 days |
| helpers' food | none (help is charged to the helper's man-hours) | game rule: helpers bring their own food; lent builders eat at the host |
| ask again | `alliance.max_asks` 3 candidates per task | game rule: 10 days per village |
| neighbour asks you | none (in the model requests come from the scheduler, per task) | game rule: 4% per day, a quarter of your builders, 10 days |
| hunger | none | game rule: no work and a quarter of builders leave |
| working front | block model: one setting crew per 3 m of wall | not in the game (crews here are small) |

## Every number and its source
MODEL = in the simulation's audited config/code. Derived = computed from model values by `tools/derive_numbers.py`.

| number | value | source |
|---|---|---|
| working day | 8 h | MODEL `hours_per_day` |
| season | 90 working days = 1 year | MODEL `alliance.season_days` (NUR 185; Renfrew 1973 via Webster 1991) |
| deadline L1 / L2 | 2 / 3 seasons | game rule (Mark's brief: 2-3 years) |
| stone per tower | 1,350 t | MODEL `stone.tonnes_per_tower` (Webster 1991) |
| block | 450 kg | MODEL `stone.block_median_kg` (Webster 1991) |
| blocks per tower | 3,000 | derived 1,350 t / 450 kg (Webster 1991: ~3,000) |
| stone volume | 565.8 m³ | derived 1,350 t / 2,386 kg/m³ (NUR 155) |
| courses | 16 | derived: 14 m / 0.9 m (`lit_scenarios.geometry`, FREE in the model) |
| quarry near | 11.1 ph/m³ -> 6,280 ph | MODEL `quarry_ph_m3.joints_low` (Boswinkel 2021, Table 7.2) |
| quarry far | 2.0 ph/m³ -> 1,132 ph | MODEL `quarry_ph_m3.scree` (Boswinkel 2021, Table 7.2) |
| dressing | 10,400 ph | MODEL Webster 1991: 852, Table 1, 1,300 man-days x 8 h (Abrams 1984) |
| walling (no lift) | 2,800 ph | MODEL 700 man-days x 8 h x (1 - 0.5); `lift_share_of_build` 0.5 is FREE in the model |
| lever | 0.37 ph/block/course -> 6,537 ph | MODEL `lever_ph_per_block_course` (Hodges 1989 / de Haan 2009 via Boswinkel 2021: 116, 124) |
| stair | 1,111 ph | MODEL S4c (Laner 1999; `stair_lever_last_m` 1.0 is FREE in the model) |
| ramp | 19,141 ph | MODEL S4b (slope 0.2, Boswinkel 2021; dig 4.2 ph/m³ Turner 2018; compaction Lacquement 2009; width 3 m, earth 1,600 kg/m³, carry 50 m FREE in the model) |
| pulley | 1,400 ph + 150 kg | game rule (WHAT-IF) |
| haul near / far | 200 m / 1,000 m | MODEL `verify.webster_target_haul_m` (Borore, Webster) / `quarry.near_site_fixed_face_m` |
| sledge friction | 0.38 | MODEL S3c (Boswinkel 2021: 124) |
| pull per person | 30 kgf | MODEL `f_person_kgf` (Cotterell & Kamminga 1990 and de Haan 2009 via Boswinkel 2021) |
| sledge crew | 6 per block | derived ceil(450 / 78.9) |
| drag / return speed | 0.27 / 1.39 m/s | MODEL `transport.drag_speed_ms`, `return_walk_ms` (ASSUMPTION in the model; Harris 2016) |
| load + unload | 0.25 h | MODEL `transport.load_unload_h` |
| rollers crew | 4 per block | game rule (NurTime trial: no measurements) |
| ox pull | 515 N per ox; yoke efficiency 0.95 / 0.80 | MODEL `lit_scenarios.oxen` (Boswinkel 2021: 52 n. 37; Barwell & Ayre 1982) |
| ox teams per block | 2 | derived `lit.oxen_yokes(450 kg)` |
| ox speed | 0.75 m/s both ways | MODEL `oxen.speed_ms` (GEN 69, 203); return speed FREE in the model |
| drovers | 2 per team | MODEL `oxen.men_per_team` (DeLaine, GEN 69) |
| ox teams available | 6 / 12 | game rule |
| fodder | 2 kg per team per day | game rule |
| village | 40 / 110 people | MODEL ranges `mr_work_party.residents_by_towers` (Webster 1991: 853); the value in the range is a game choice |
| adult share | 0.4 | MODEL `mr_work_party.adult_share` (Webster 1991: 854, Table 2 n. 4) |
| starting builders | 10 / 30 | game rule |
| ration | 1 kg/person/day | MODEL `food_cap.ration_kg` (S12_central) |
| stores and harvest | 1,600 / 3,600 kg per season | game rule |
| recruiting | 5 kg per builder | game rule |
| acceptance | sigmoid(0 + 2.0 T - 0.05 backlog - 0.2 km) | MODEL `alliance.beta0..beta3` (FREE in the model) |
| trust | 0.5 start, +0.1, -0.2 | MODEL `trust0`, `delta_up`, `delta_down` (FREE in the model) |
| neighbour distances | 2, 5, 8 km | game rule (inside MODEL `R_m` 10 km) |
| neighbour sizes | 20/30/50; 40/60/110 people | game rule |
| neighbour busy days | 15/0/30; 20/0/40; +10 per help | game rule (the mechanism is MODEL `backlog_days`) |
| help duration | 10 days | game rule |
| ask cooldown | 10 days | game rule |
| neighbour request | 4% per day; 1/4 of builders (min 2); 10 days | game rule |
| hunger | 1/4 of builders leave | game rule |
| day length on screen | 0.45 s | game rule |
| reference only | 50 builders, one tower, 64 working days | block-level model (viz3d_prototype/README.md, webster row) |

**Note on haul speed.** The viz3d block model (README "What is sourced") uses 0.6 m/s loaded (SCOPE rule 5) and
100 kg per person; that is where "50 builders, 64 days" comes from. The game follows the audited island config
(0.27 m/s; sledge on dry ground 30 kgf / 0.38), because strategy records are meant to be run there. With the
README rates the haul would be about half as costly.

## Balance (tests/balance.gd, 30 seeds per cell)
Three bots: *alone* (all builders, never asks, refuses requests), *asker* (asks whenever possible, refuses requests),
*social* (asks and helps back). Level 1, selected rows (win rate):

| quarry / haul / lift | ph needed | alone | asker | social |
|---|---|---|---|---|
| near / sledge / stair | 29,514 | 0/30 | 30/30 | 30/30 |
| near / sledge / lever | 34,940 | 0/30 | 30/30 | 30/30 |
| near / rollers / stair | 26,539 | 0/30 | 30/30 | 30/30 |
| near / oxen / stair | 25,368 | 0/30 | 19/30 | 26/30 |
| near / sledge / ramp | 47,544 | 0/30 | 4/30 | 19/30 |
| far / sledge / stair | 42,058 | 0/30 | 18/30 | 28/30 |
| far / oxen / any | 27-45k | 0/30 | 0/30 | 0/30 |
| far / sledge / ramp | 60,087 | 0/30 | 0/30 | 0/30 |

Level 2 is similar with longer games; only near / rollers / stair (a game-rule method) can be won alone.
The bots ask every village the moment they can; a human asks less, so real games are harder (the scripted
browser test lost the "good" combination at 97% because it recruited late and asked every 3 days).
Far + oxen always loses: hauling 1 km needs ~6,000 ox-team hours per tower and fodder for 6 teams empties the
stores. This is a game-rule outcome (fodder and team count are game rules), see the open questions.

## What is simplified
- Every block weighs the median 450 kg (the model draws lognormal blocks, 60-2,400 kg, and crews scale with mass).
- Lever cost is spread evenly over blocks (in the model it grows with course height).
- The multi-tower level builds the central tower first, then the two laterals together (as the block model's
  keep-first rule); laterals are drawn smaller but cost the same per block, as in the island model (x TWR_N).
- No working-front limit, learning, stone density/hardness, rails, sea transport or relays.

## Browser test results (390x844, DPR 2, touch, headless Chromium 154 + SwiftShader)
- Win: near / rollers / stair, all 16 builders, asks almost daily, helps back: finished on day 173 of 180
  (17 asks, 11 yes; 7 requests, all helped). Screenshots and records in `tests/out_win/`.
- Lose: far / sledge / ramp, 10 builders, never asks, refuses: 23% built at day 180 (`tests/out_lose/`).
- Level 2 smoke run (near / rollers / stair) to day 150: 47% built, central tower done, laterals rising
  (`tests/out_it/30_level2_day150.png`). Italian menu and About: `tests/out_it/20_menu_it.png`, `21_about_it.png`.
- Network: only the game's own files; the only other request is the local `blob:` of the strategy download.
  Storage: no cookies, no localStorage; Cache Storage (PWA) and an empty IndexedDB `/userfs` (Godot runtime).
