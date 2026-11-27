extends RefCounted
class_name Sim
## Game state and the daily step. No UI here, so tests/balance.gd can run it headless.

signal event(kind: String, data: Dictionary)

var L: Dictionary            # level definition (N.LEVELS[i])
var quarry := "near"
var haul := "sledge"
var lift := "stair"
var seed := 0
var rng := RandomNumberGenerator.new()

var day := 0                 # working days elapsed (0-based)
var total_days := 0
var stores := 0.0
var builders := 0
var adults := 0
var yokes := 0
var helpers: Array = []      # [{v, hands, days}]
var lent: Array = []         # [{v, hands, days}]
var neighbours: Array = []   # [{id, km, residents, hands, trust, backlog, helped_me, cooldown}]
var pending: Dictionary = {} # a neighbour's open request

var blocks_total := 0.0
var quarried := 0.0
var hauled := 0.0
var dressed := 0.0
var placed := 0.0
var c_q := 0.0
var c_d := 0.0
var c_b := 0.0
var c_h_men := 0.0
var c_h_yoke := 0.0
var ph_spent := {"quarry": 0.0, "haul": 0.0, "dress": 0.0, "build": 0.0}
var yoke_h_spent := 0.0
var food_eaten := 0.0
var hands_today := 0
var idle_reason := ""
var result := ""             # "", "win", "lose"
var timeline: Array = []
var asks := 0
var asks_yes := 0
var requests_in := 0
var requests_helped := 0


func setup(level_index: int, q: String, h: String, l: String, rng_seed: int = -1) -> void:
	L = N.LEVELS[level_index]
	quarry = q; haul = h; lift = l
	seed = rng_seed if rng_seed >= 0 else int(Time.get_unix_time_from_system()) % 1000000
	rng.seed = seed
	var tw: int = L.towers
	blocks_total = float(N.BLOCKS_PER_TOWER * tw)
	# per-block person-hours: the model's per-tower stage totals x towers / blocks (stage hours scale with TWR_N)
	c_q = N.PH_QUARRY[q] / N.BLOCKS_PER_TOWER
	c_d = N.PH_DRESS / N.BLOCKS_PER_TOWER
	c_b = (N.PH_BUILD_NO_LIFT + N.PH_LIFT[l]) / N.BLOCKS_PER_TOWER
	var d: float = N.HAUL_M[q]
	if h == "oxen":
		var trip := (d / N.OX_SPEED + d / N.OX_SPEED) / 3600.0 + N.LOAD_H
		c_h_yoke = N.OX_YOKES_PER_BLOCK * trip
		c_h_men = N.OX_YOKES_PER_BLOCK * N.OX_MEN_PER_YOKE * trip
	else:
		var trip2 := (d / N.DRAG_SPEED + d / N.RETURN_SPEED) / 3600.0 + N.LOAD_H
		var crew := N.CREW_SLEDGE if h == "sledge" else N.CREW_ROLLERS
		c_h_men = crew * trip2
		c_h_yoke = 0.0
	total_days = int(L.seasons) * N.SEASON_DAYS
	stores = L.stores
	adults = int(round(N.ADULT_SHARE * L.residents))
	builders = 0
	yokes = 0
	neighbours.clear()
	for nb in L.neighbours:
		neighbours.append({"id": nb.id, "km": nb.km, "residents": nb.residents,
			"hands": int(round(N.ADULT_SHARE * nb.residents)), "trust": N.TRUST0,
			"backlog": float(nb.backlog), "helped_me": false, "cooldown": 0})
	log_ev("choices", {"quarry": q, "haul": h, "lift": l})
	if l == "pulley":
		stores -= N.PULLEY_KG
		log_ev("pulley_frame", {"kg": N.PULLEY_KG})
	set_builders(int(L.start_builders))
	if h == "oxen":
		set_yokes(int(L.start_yokes))


func log_ev(kind: String, data: Dictionary) -> void:
	var e := {"day": day + 1, "event": kind}
	e.merge(data)
	timeline.append(e)


func person_hours_needed() -> float:
	return blocks_total * (c_q + c_d + c_b + c_h_men)


func progress() -> float:
	return clamp(placed / blocks_total, 0.0, 1.0)


func season() -> int:
	return min(day / N.SEASON_DAYS + 1, int(L.seasons))


func lent_hands() -> int:
	var s := 0
	for x in lent: s += int(x.hands)
	return s


func helper_hands() -> int:
	var s := 0
	for x in helpers: s += int(x.hands)
	return s


func set_builders(n: int) -> void:
	n = clampi(n, 0, adults)
	if n > builders:
		var cost := (n - builders) * N.RECRUIT_KG
		if cost > stores:
			n = builders + int(stores / N.RECRUIT_KG)
			cost = (n - builders) * N.RECRUIT_KG
		stores -= cost
	if n < lent_hands():
		n = lent_hands()
	if n != builders:
		log_ev("builders", {"n": n})
	builders = n


func set_yokes(n: int) -> void:
	n = clampi(n, 0, int(L.max_yokes))
	if n != yokes:
		log_ev("ox_yokes", {"n": n})
	yokes = n


func accept_chance(nb: Dictionary) -> float:
	# the model's acceptance logit (alliance.request): beta0 + beta1 trust - beta2 backlog_days - beta3 distance_km
	var x: float = N.BETA0 + N.BETA1 * nb.trust - N.BETA2 * nb.backlog - N.BETA3 * nb.km
	return 1.0 / (1.0 + exp(-x))


func ask(i: int) -> bool:
	var nb: Dictionary = neighbours[i]
	if nb.cooldown > 0 or result != "":
		return false
	var p := accept_chance(nb)
	var ok := rng.randf() < p
	asks += 1
	nb.cooldown = N.ASK_COOLDOWN
	if ok:
		asks_yes += 1
		nb.helped_me = true
		helpers.append({"v": nb.id, "hands": nb.hands, "days": N.HELP_DAYS})
		nb.backlog += N.HELP_DAYS   # helping you adds to their own backlog (the model's backlog_days)
	log_ev("ask", {"village": nb.id, "p": snappedf(p, 0.001), "yes": ok, "hands": nb.hands if ok else 0})
	return ok


func answer_request(yes: bool) -> void:
	if pending.is_empty():
		return
	var nb: Dictionary = neighbours[pending.i]
	var hands: int = pending.hands
	if yes and builders >= lent_hands() + hands:
		lent.append({"v": nb.id, "hands": hands, "days": N.HELP_DAYS})
		nb.trust = min(1.0, nb.trust + N.DELTA_UP)
		requests_helped += 1
	else:
		yes = false
		if nb.helped_me:   # you refuse a village that helped you: its trust in you drops (model delta_down)
			nb.trust = max(0.0, nb.trust - N.DELTA_DOWN)
	log_ev("request_answer", {"village": nb.id, "hands": hands, "yes": yes, "trust_after": snappedf(nb.trust, 0.01)})
	pending = {}


func step_day() -> void:
	if result != "" or not pending.is_empty():
		return
	var own := builders - lent_hands()
	var hands := own + helper_hands()
	# your own builders and oxen eat from your stores; helpers bring their own food, lent builders eat at the host
	var need := float(own) * N.RATION_KG + yokes * N.FODDER_KG_PER_YOKE
	idle_reason = ""
	if need > stores + 0.001:
		# not enough food: nobody works today and some builders go home
		stores = 0.0
		var leave := int(ceil(builders * N.HUNGER_LEAVE))
		builders = max(lent_hands(), builders - leave)
		hands_today = 0
		idle_reason = "hunger"
		log_ev("hunger", {"builders_left": builders})
		event.emit("hunger", {"left": leave})
	else:
		stores -= need
		food_eaten += need
		hands_today = hands
		_work(hands * N.HOURS_PER_DAY, yokes * N.HOURS_PER_DAY)
	# timers
	for arr in [helpers, lent]:
		for x in arr: x.days -= 1
	helpers = helpers.filter(func(x): return x.days > 0)
	lent = lent.filter(func(x): return x.days > 0)
	for nb in neighbours:
		nb.backlog = max(0.0, nb.backlog - 1.0)
		nb.cooldown = max(0, nb.cooldown - 1)
	day += 1
	if placed >= blocks_total - 0.01:
		placed = blocks_total
		result = "win"
		log_ev("finished", {})
		event.emit("win", {})
		return
	if day >= total_days:
		result = "lose"
		log_ev("deadline", {})
		event.emit("lose", {})
		return
	if day % N.SEASON_DAYS == 0:
		stores += L.harvest
		log_ev("season_start", {"season": season(), "harvest": L.harvest})
		event.emit("season", {"season": season()})
		return
	# a neighbour may ask you for hands
	if day > 4 and rng.randf() < N.REQUEST_CHANCE:
		var i := rng.randi_range(0, neighbours.size() - 1)
		var want := maxi(2, int(round(builders * 0.25)))
		if builders - lent_hands() >= want:
			pending = {"i": i, "hands": want}
			requests_in += 1
			log_ev("request", {"village": neighbours[i].id, "hands": want})
			event.emit("request", pending)


func _work(H: float, Y: float) -> void:
	# stage priority set > haul > dress > quarry (the block model's task priority); blocks flow
	# quarry -> haul -> dress -> set (SCOPE rule 2)
	var n: float
	n = min(dressed, H / c_b)
	dressed -= n; placed += n; H -= n * c_b; ph_spent.build += n * c_b
	var avail := quarried
	n = min(avail, H / c_h_men)
	if c_h_yoke > 0.0:
		n = min(n, Y / c_h_yoke)
	quarried -= n; hauled += n; H -= n * c_h_men; ph_spent.haul += n * c_h_men; yoke_h_spent += n * c_h_yoke
	n = min(hauled, H / c_d)
	hauled -= n; dressed += n; H -= n * c_d; ph_spent.dress += n * c_d
	var left := blocks_total - (quarried + hauled + dressed + placed)
	n = min(left, H / c_q)
	quarried += n; H -= n * c_q; ph_spent.quarry += n * c_q
	if H > 1.0 and hands_today > 0:
		idle_reason = "waiting"
	if c_h_yoke > 0.0 and Y <= 0.0 and quarried > 1.0:
		idle_reason = "no_oxen"


## The strategy record: choices, timeline and outcome, keyed to the model's scenario switches.
func strategy_record() -> Dictionary:
	var tw: int = L.towers
	var lit_map := {"quarry": "joints_low" if quarry == "near" else "scree",
		"lift": lift if lift != "pulley" else null,
		"oxen": haul == "oxen", "mu": 0.3 if haul == "oxen" else (0.38 if haul == "sledge" else null),
		"haul": "base" if haul == "oxen" else ("mu0.38" if haul == "sledge" else null)}
	var not_in_model := []
	if haul == "rollers": not_in_model.append({"choice": "haul=rollers", "tag": "DEMONSTRATED", "note": "no model equivalent (game rule crew 4)"})
	if lift == "pulley": not_in_model.append({"choice": "lift=pulley", "tag": "WHAT-IF", "note": "no model equivalent (game rule 1,400 ph)"})
	var nb_out := []
	for nb in neighbours:
		nb_out.append({"village": nb.id, "distance_km": nb.km, "residents": nb.residents,
			"trust_in_you_end": snappedf(nb.trust, 0.01), "helped_you": nb.helped_me})
	return {
		"schema": "nuraghe-game-strategy/0.1",
		"game_version": N.GAME_VERSION,
		"engine": "Godot " + Engine.get_version_info().string,
		"level": int(L.id),
		"rng_seed": seed,
		"site": {"TWR_N": tw, "tonnes": N.TONNES_PER_TOWER * tw, "blocks": int(blocks_total)},
		"scenario_override": {
			"lit_scenarios": lit_map,
			"haul_m": N.HAUL_M[quarry],
			"builders_rule": {"residents": L.residents, "adult_share": N.ADULT_SHARE},
			"alliance": {"requests": true, "trust": true, "season_days": N.SEASON_DAYS, "trust0": N.TRUST0,
				"delta_up": N.DELTA_UP, "delta_down": N.DELTA_DOWN,
				"beta": [N.BETA0, N.BETA1, N.BETA2, N.BETA3]},
			"food_cap": {"ration_kg": N.RATION_KG},
			"hours_per_day": N.HOURS_PER_DAY,
		},
		"not_in_model": not_in_model,
		"game_rules": {"stores_start_kg": L.stores, "harvest_kg_per_season": L.harvest,
			"fodder_kg_per_yoke_day": N.FODDER_KG_PER_YOKE, "recruit_kg": N.RECRUIT_KG,
			"help_days": N.HELP_DAYS, "ask_cooldown_days": N.ASK_COOLDOWN, "request_chance_per_day": N.REQUEST_CHANCE},
		"neighbours": nb_out,
		"timeline": timeline,
		"outcome": {
			"result": result, "working_days": day, "deadline_days": total_days,
			"seasons_used": int(ceil(day / float(N.SEASON_DAYS))),
			"share_built": snappedf(progress(), 0.001),
			"person_hours": {"quarry": roundi(ph_spent.quarry), "haul": roundi(ph_spent.haul),
				"dress": roundi(ph_spent.dress), "build_and_lift": roundi(ph_spent.build)},
			"ox_yoke_hours": roundi(yoke_h_spent),
			"food_eaten_kg": roundi(food_eaten), "stores_left_kg": roundi(stores),
			"asks": asks, "asks_yes": asks_yes, "requests_received": requests_in, "requests_helped": requests_helped,
		},
	}
