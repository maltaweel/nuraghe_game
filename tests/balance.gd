extends SceneTree
## Headless balance check: godot --headless -s tests/balance.gd
## Plays every choice combination with simple bots over many seeds and prints win rates.

func play(level: int, q: String, h: String, l: String, s: int, bot: String) -> Sim:
	var sim := Sim.new()
	sim.setup(level, q, h, l, s)
	sim.set_builders(sim.adults if bot != "small" else int(sim.adults / 2))
	if h == "oxen":
		sim.set_yokes(int(sim.L.max_yokes))
	var guard := 0
	while sim.result == "" and guard < 2000:
		guard += 1
		if not sim.pending.is_empty():
			sim.answer_request(bot == "social")
			continue
		if sim.builders < sim.adults and sim.stores > 300 and bot != "small":
			sim.set_builders(sim.adults)
		if bot == "social" or bot == "asker":
			for i in sim.neighbours.size():
				var nb: Dictionary = sim.neighbours[i]
				if nb.cooldown == 0 and sim.helper_hands() < 30:
					sim.ask(i)
		if h == "oxen" and sim.quarried + sim.placed + sim.dressed + sim.hauled >= sim.blocks_total - 0.5 and sim.quarried < 0.5:
			sim.set_yokes(0)
		sim.step_day()
	return sim


func _init() -> void:
	var seeds := 30
	for level in [0, 1]:
		print("=== level ", level + 1)
		for q in N.QUARRY:
			for h in N.HAUL:
				for l in N.LIFT:
					var line := "%-5s %-8s %-7s ph=%6d" % [q, h, l, 0]
					var first := true
					for bot in ["alone", "asker", "social"]:
						var wins := 0
						var days := 0.0
						var share := 0.0
						for s in seeds:
							var sim := play(level, q, h, l, 1000 + s, bot)
							if first:
								line = "%-5s %-8s %-7s ph=%6d" % [q, h, l, int(sim.person_hours_needed())]
								first = false
							if sim.result == "win": wins += 1
							days += sim.day
							share += sim.progress()
						line += "  %s win %2d/%d d=%3d built=%3d%%" % [bot, wins, seeds, int(days / seeds), int(100 * share / seeds)]
					print(line)
	quit()
