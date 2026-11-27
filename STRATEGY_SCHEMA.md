# Strategy record schema (`nuraghe-game-strategy/0.1`)

Every finished or failed game makes one JSON record (`Sim.strategy_record()` in `scripts/sim.gd`). It is shown on
the end screen under "Your strategy", with **Copy** (clipboard) and **Save as file** (a browser download on the web;
a file in the app's user folder on Android).

**Privacy and scope.** The record holds no personal data, no device identifiers and no timestamps of real time. It
is never uploaded: the game has no network code and no submission path. Crowdsourcing strategies would need ethics
clearance and player consent first; a future version could add a voluntary export to the research team, which
would then map the record onto a model scenario (below).

## Top level
| field | type | meaning |
|---|---|---|
| `schema` | string | `"nuraghe-game-strategy/0.1"` |
| `game_version` | string | game version (`N.GAME_VERSION`) |
| `engine` | string | Godot version string |
| `level` | int | 1 (one tower) or 2 (central tower + 2 laterals) |
| `rng_seed` | int | seed of the game's random draws (acceptances, neighbour requests); with the timeline it replays the game |
| `site` | object | `TWR_N`, `tonnes`, `blocks` |
| `scenario_override` | object | the choices written as model settings, see below |
| `not_in_model` | array | choices with no model equivalent: `{choice, tag, note}` (rollers, pulley) |
| `game_rules` | object | the game-rule values in force (stores, harvest, fodder, recruit cost, help days, ask cooldown, request chance) |
| `neighbours` | array | `{village, distance_km, residents, trust_in_you_end, helped_you}` |
| `timeline` | array | events in order, see below |
| `outcome` | object | result and totals, see below |

## `scenario_override` (close to a model scenario override)
Keys follow `config_full_audited.yaml`. `null` = no model value for this choice (see `not_in_model`).

| key | values | model meaning |
|---|---|---|
| `lit_scenarios.quarry` | `"joints_low"` (near bedrock) / `"scree"` (far boulders) | S1b / S1a, `lit_scenarios.quarry_ph_m3` |
| `lit_scenarios.lift` | `"lever"` / `"stair"` / `"ramp"` / `null` (pulley) | S4a / S4c / S4b |
| `lit_scenarios.oxen` | bool | S3e_oxen |
| `lit_scenarios.mu` | 0.38 (sledge) / 0.3 (oxen) / `null` (rollers) | sledge friction |
| `lit_scenarios.haul` | `"mu0.38"` / `"base"` / `null` | haul table key (`lit.haul_csv`) |
| `haul_m` | 200 / 1000 | haul distance in metres; for a real site this comes from the haul table instead |
| `builders_rule` | `{residents, adult_share}` | `mr_work_party`-style rule with residents fixed (as `..._POPFROZEN`) |
| `alliance` | `{requests: true, trust: true, season_days, trust0, delta_up, delta_down, beta}` | alliance block; `beta` = [beta0, beta1, beta2, beta3] |
| `food_cap` | `{ration_kg}` | S12 ration |
| `hours_per_day` | 8 | `hours_per_day` |

To run a record in the model, one would build a scenario = MOST_REALISTIC-style base + these keys, pick a real site
with `TWR_N` = `site.TWR_N`, and compare the model's working days with `outcome.working_days`. Two things have no
direct model input yet: the player's day-by-day workforce (`builders` events) and the player's choices of whom to
ask and whether to answer requests (the model decides these by its own rules). A future model hook could replay
the timeline as an exogenous schedule.

## `timeline` events
Each event has `day` (working day, 1-based) and `event`, plus:

| event | fields | meaning |
|---|---|---|
| `choices` | `quarry`, `haul`, `lift` | game values: near/far; sledge/rollers/oxen; lever/stair/ramp/pulley |
| `pulley_frame` | `kg` | stores paid for the timber frame |
| `builders` | `n` | your builders from this day (recruits and dismissals; hunger losses appear as `hunger`) |
| `ox_yokes` | `n` | ox teams from this day |
| `ask` | `village`, `p`, `yes`, `hands` | you asked; `p` = model acceptance probability at that moment |
| `request` | `village`, `hands` | a neighbour asked you |
| `request_answer` | `village`, `hands`, `yes`, `trust_after` | your answer and its trust in you afterwards |
| `hunger` | `builders_left` | a day without enough food |
| `season_start` | `season`, `harvest` | a new season and the harvest added |
| `finished` / `deadline` | | end of game |

## `outcome`
`result` ("win"/"lose"), `working_days`, `deadline_days`, `seasons_used`, `share_built` (0-1), `person_hours`
by stage (`quarry`, `haul`, `dress`, `build_and_lift`), `ox_yoke_hours`, `food_eaten_kg`, `stores_left_kg`, `asks`,
`asks_yes`, `requests_received`, `requests_helped`.

Example records from the browser tests: `tests/out_win/strategy_win.json`, `tests/out_lose/strategy_lose.json`.
