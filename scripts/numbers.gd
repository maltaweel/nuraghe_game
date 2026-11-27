extends RefCounted
class_name N
## Every number the game uses. MODEL = copied or derived from the simulation's audited config
## (protocol_paper/zeynep_branch_stage/config/config_full_audited.yaml, via tools/derive_numbers.py).
## GAME = a game rule, not from the model. DESIGN.md lists each one with its source.

const GAME_VERSION := "0.1.0"

# --- time (MODEL)
const HOURS_PER_DAY := 8.0          # hours_per_day
const SEASON_DAYS := 90             # alliance.season_days (NUR 185: 90 communal days a year)

# --- one tower (MODEL)
const TONNES_PER_TOWER := 1350.0    # stone.tonnes_per_tower (Webster 1991)
const BLOCK_KG := 450.0             # stone.block_median_kg (Webster 1991)
const BLOCKS_PER_TOWER := 3000      # 1,350 t / 450 kg (Webster 1991: ~3,000 blocks)
const COURSES_PER_TOWER := 16       # geometry 14 m / 0.9 m courses (lit_scenarios.geometry), rounded up

# person-hours per tower by stage (MODEL; derived by tools/derive_numbers.py)
const PH_QUARRY := {"near": 6280.4, "far": 1131.6}   # S1b joints_low 11.1 ph/m3 and S1a scree 2.0 ph/m3 x 565.8 m3
const PH_DRESS := 10400.0                            # Webster 1991 Table 1: 1,300 man-days x 8 h
const PH_BUILD_NO_LIFT := 2800.0                     # Webster 700 man-days x 8 h x (1 - lift_share_of_build 0.5)
const PH_LIFT := {
	"lever": 6536.9,    # S4a: 0.37 ph per block per course climbed, cone course weights
	"stair": 1110.8,    # S4c: Laner's internal stair, only the last 1 m of each course levered
	"ramp": 19140.6,    # S4b: earth ramp built and removed (slope 0.2, 3 m wide)
	"pulley": 1400.0,   # GAME: WHAT-IF, no model value (set to half of Webster's lift share)
}

# --- quarry distance in metres
const HAUL_M := {"near": 200.0, "far": 1000.0}   # near: verify.webster_target_haul_m (Webster, Borore); far: quarry.near_site_fixed_face_m

# --- hauling (MODEL unless marked)
const DRAG_SPEED := 0.27        # transport.drag_speed_ms
const RETURN_SPEED := 1.39      # transport.return_walk_ms
const LOAD_H := 0.25            # transport.load_unload_h
const CREW_SLEDGE := 6          # ceil(450 kg / (30 kgf / mu 0.38)) = S3c sledge on dry ground
const CREW_ROLLERS := 4         # GAME: rollers are not in the model (no measurements)
const OX_YOKES_PER_BLOCK := 2   # lit.oxen_yokes(450 kg): 515 N per ox, yoke efficiency 0.95/0.80
const OX_MEN_PER_YOKE := 2      # lit_scenarios.oxen.men_per_team
const OX_SPEED := 0.75          # lit_scenarios.oxen.speed_ms and return_speed_ms

# --- people (MODEL)
const ADULT_SHARE := 0.4        # mr_work_party.adult_share (builders = 0.4 x residents)

# --- help between villages (MODEL: alliance block)
const TRUST0 := 0.5
const DELTA_UP := 0.1
const DELTA_DOWN := 0.2
const BETA0 := 0.0
const BETA1 := 2.0
const BETA2 := 0.05
const BETA3 := 0.2

# --- food (MODEL ration; the rest GAME)
const RATION_KG := 1.0          # MOST_REALISTIC_S12_central food_cap.ration_kg
const FODDER_KG_PER_YOKE := 2.0 # GAME
const RECRUIT_KG := 5.0         # GAME: a welcome meal per new builder
const PULLEY_KG := 150.0        # GAME: timber and rope for the frame (paid once)
const HELP_DAYS := 10           # GAME: helpers stay this many working days
const ASK_COOLDOWN := 10        # GAME: days before you can ask the same village again
const REQUEST_CHANCE := 0.04    # GAME: chance per day that a neighbour asks you for hands
const HUNGER_LEAVE := 0.25      # GAME: share of builders who go home on a day without food

# --- levels. residents: MODEL range (mr_work_party.residents_by_towers); stores, neighbours: GAME
const LEVELS := [
	{
		"id": 1, "towers": 1, "seasons": 2, "residents": 40, "stores": 1600.0, "harvest": 1600.0, "max_yokes": 6,
		"start_builders": 10, "start_yokes": 2,
		"neighbours": [
			{"id": "hill", "km": 2.0, "residents": 20, "backlog": 15},
			{"id": "river", "km": 5.0, "residents": 30, "backlog": 0},
			{"id": "plain", "km": 8.0, "residents": 50, "backlog": 30},
		],
	},
	{
		"id": 2, "towers": 3, "seasons": 3, "residents": 110, "stores": 3600.0, "harvest": 3600.0, "max_yokes": 12,
		"start_builders": 30, "start_yokes": 4,
		"neighbours": [
			{"id": "hill", "km": 2.0, "residents": 40, "backlog": 20},
			{"id": "river", "km": 5.0, "residents": 60, "backlog": 0},
			{"id": "plain", "km": 8.0, "residents": 110, "backlog": 40},
		],
	},
]

# --- the choices, their tags and the model switch they map to
const QUARRY := ["near", "far"]
const HAUL := ["sledge", "rollers", "oxen"]
const LIFT := ["lever", "stair", "ramp", "pulley"]
const TAGS := {
	"q_near": "MODEL", "q_far": "MODEL",
	"h_sledge": "MODEL", "h_rollers": "DEMONSTRATED", "h_oxen": "HYPOTHESIS",
	"l_lever": "MODEL + DEMONSTRATED", "l_stair": "MODEL", "l_ramp": "HYPOTHESIS", "l_pulley": "WHAT-IF",
}
const TAG_COLOURS := {
	"MODEL": Color(0.16, 0.45, 0.30), "DEMONSTRATED": Color(0.15, 0.36, 0.62),
	"HYPOTHESIS": Color(0.72, 0.45, 0.06), "WHAT-IF": Color(0.62, 0.18, 0.40),
	"MODEL + DEMONSTRATED": Color(0.16, 0.45, 0.30),
}
