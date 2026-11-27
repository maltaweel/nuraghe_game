extends Control
## Screens and touch UI. All visible text goes through tr() with keys from i18n/strings.csv.

const DAY_SEC := 0.45           # real seconds per working day at 1x
const BG := Color(0.93, 0.89, 0.80)
const INK := Color(0.18, 0.15, 0.12)
const ACCENT := Color(0.55, 0.30, 0.15)

var sim: Sim
var level_index := 0
var choice := {"quarry": "", "haul": "", "lift": ""}
var running := false
var speed := 1
var acc := 0.0
var screen: Control
var modal: Control
var hud := {}
var site: Control
var record_text := ""
var font_size := 30


func _ready() -> void:
	var loc := OS.get_locale_language()
	TranslationServer.set_locale("it" if loc == "it" else "en")
	theme = _make_theme()
	show_menu()
	if OS.has_feature("web") and str(JavaScriptBridge.eval("location.search")).contains("autotest"):
		_setup_autotest()


# ------------------------------------------------------------------ theme and helpers
func _make_theme() -> Theme:
	var th := Theme.new()
	th.default_font_size = font_size
	var sb := StyleBoxFlat.new()
	sb.bg_color = ACCENT; sb.set_corner_radius_all(18); sb.content_margin_left = 20; sb.content_margin_right = 20
	sb.content_margin_top = 14; sb.content_margin_bottom = 14
	var sbp := sb.duplicate(); sbp.bg_color = ACCENT.darkened(0.25)
	var sbd := sb.duplicate(); sbd.bg_color = Color(0.6, 0.56, 0.5)
	th.set_stylebox("normal", "Button", sb)
	th.set_stylebox("hover", "Button", sb)
	th.set_stylebox("pressed", "Button", sbp)
	th.set_stylebox("disabled", "Button", sbd)
	th.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	th.set_color("font_color", "Button", Color.WHITE)
	th.set_color("font_hover_color", "Button", Color.WHITE)
	th.set_color("font_pressed_color", "Button", Color.WHITE)
	th.set_color("font_disabled_color", "Button", Color(0.92, 0.9, 0.86))
	th.set_color("font_color", "Label", INK)
	th.set_color("default_color", "RichTextLabel", INK)
	var card := StyleBoxFlat.new()
	card.bg_color = Color(1, 0.98, 0.94); card.set_corner_radius_all(16); card.border_color = Color(0.75, 0.68, 0.55)
	card.set_border_width_all(2); card.content_margin_left = 18; card.content_margin_right = 18
	card.content_margin_top = 14; card.content_margin_bottom = 14
	th.set_stylebox("panel", "PanelContainer", card)
	var te := StyleBoxFlat.new(); te.bg_color = Color(1, 1, 1); te.set_corner_radius_all(8)
	te.content_margin_left = 10; te.content_margin_top = 10
	th.set_stylebox("normal", "TextEdit", te)
	th.set_stylebox("read_only", "TextEdit", te)
	th.set_color("font_readonly_color", "TextEdit", INK)
	th.set_color("font_color", "TextEdit", INK)
	return th


func _clear() -> void:
	running = false
	if modal: modal.queue_free(); modal = null
	if screen: screen.queue_free()
	screen = null
	site = null
	hud = {}


func _page(scroll := true) -> VBoxContainer:
	_clear()
	var bg := ColorRect.new(); bg.color = BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	screen = bg
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 28)
	bg.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if scroll:
		var sc := ScrollContainer.new()
		sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		margin.add_child(sc)
		sc.add_child(box)
	else:
		margin.add_child(box)
	return box


func _label(text: String, size := 0, color := INK, center := false) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if size > 0: l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if center: l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l


func _button(text: String, cb: Callable, h := 96, color := ACCENT) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, h)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if color != ACCENT:
		var sb: StyleBoxFlat = theme.get_stylebox("normal", "Button").duplicate()
		sb.bg_color = color
		b.add_theme_stylebox_override("normal", sb)
		b.add_theme_stylebox_override("hover", sb)
	b.pressed.connect(cb)
	return b


func _rich(bb: String, size := 26) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r.add_theme_font_size_override("normal_font_size", size)
	r.add_theme_font_size_override("bold_font_size", size)
	r.add_theme_color_override("default_color", INK)
	r.text = bb
	return r


func _tag(tag: String) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = N.TAG_COLOURS.get(tag, Color.GRAY)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 12; sb.content_margin_right = 12; sb.content_margin_top = 4; sb.content_margin_bottom = 4
	p.add_theme_stylebox_override("panel", sb)
	var l := _label(tr("TAG_" + tag.replace(" + ", "_").replace("-", "")), 22, Color.WHITE)
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	l.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	p.add_child(l)
	p.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	return p


func fmt(n: float) -> String:
	var s := str(int(round(n)))
	var neg := s.begins_with("-")
	if neg: s = s.substr(1)
	var out := ""
	while s.length() > 3:
		out = tr("THOUSANDS_SEP") + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return ("-" if neg else "") + s + out


# ------------------------------------------------------------------ modal
func show_modal(title: String, body: String, buttons: Array, extra: Control = null) -> void:
	if modal: modal.queue_free()
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.55)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)
	modal = shade
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(min(size.x - 40, 660), 0)
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	panel.add_child(box)
	if title != "":
		box.add_child(_label(title, 36, ACCENT))
	if body != "":
		box.add_child(_rich(body, 27))
	if extra:
		box.add_child(extra)
	for b in buttons:
		box.add_child(_button(b[0], b[1], 88, b[2] if b.size() > 2 else ACCENT))


func close_modal() -> void:
	if modal: modal.queue_free()
	modal = null


# ------------------------------------------------------------------ menu
func show_menu() -> void:
	var box := _page()
	box.add_child(_spacer(30))
	var icon := TextureRect.new()
	icon.texture = load("res://icons/icon_512.png")
	icon.custom_minimum_size = Vector2(220, 220)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	box.add_child(icon)
	box.add_child(_label(tr("TITLE"), 56, ACCENT, true))
	box.add_child(_label(tr("SUBTITLE"), 28, INK, true))
	box.add_child(_spacer(10))
	box.add_child(_button(tr("PLAY_L1"), func(): start_choices(0), 110))
	box.add_child(_button(tr("PLAY_L2"), func(): start_choices(1), 110))
	box.add_child(_button(tr("HOW_TO"), show_howto, 90, Color(0.35, 0.42, 0.30)))
	box.add_child(_button(tr("ABOUT"), show_about, 90, Color(0.35, 0.42, 0.30)))
	box.add_child(_button(tr("SOURCES"), show_sources, 90, Color(0.35, 0.42, 0.30)))
	box.add_child(_button(tr("LANG_SWITCH"), _switch_lang, 80, Color(0.4, 0.4, 0.45)))
	box.add_child(_label(tr("PROTOTYPE_NOTE") + "  v" + N.GAME_VERSION, 22, Color(0.4, 0.36, 0.3), true))


func _spacer(h: int) -> Control:
	var c := Control.new(); c.custom_minimum_size = Vector2(0, h); return c


func show_howto() -> void:
	var box := _page()
	box.add_child(_label(tr("HOW_TO"), 44, ACCENT))
	box.add_child(_rich(tr("HOWTO_BODY"), 28))
	box.add_child(_button(tr("BACK"), show_menu))


func show_about() -> void:
	var box := _page()
	box.add_child(_label(tr("ABOUT"), 44, ACCENT))
	box.add_child(_rich(tr("ABOUT_BODY"), 26))
	for tag in ["MODEL", "DEMONSTRATED", "HYPOTHESIS", "WHAT-IF"]:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		row.add_child(_tag(tag))
		row.add_child(_label(tr("TAGDESC_" + tag.replace("-", "")), 24))
		box.add_child(row)
	box.add_child(_rich(tr("ABOUT_BODY2"), 26))
	box.add_child(_button(tr("BACK"), show_menu))


func show_sources() -> void:
	var box := _page()
	box.add_child(_label(tr("SOURCES"), 44, ACCENT))
	box.add_child(_rich(tr("SOURCES_BODY"), 24))
	box.add_child(_button(tr("BACK"), show_menu))


# ------------------------------------------------------------------ choices
func start_choices(li: int) -> void:
	level_index = li
	choice = {"quarry": "", "haul": "", "lift": ""}
	var L: Dictionary = N.LEVELS[li]
	var box := _page()
	box.add_child(_label(tr("LEVEL_%d" % L.id), 44, ACCENT))
	box.add_child(_rich(tr("LEVEL_%d_INTRO" % L.id) % [L.seasons, L.seasons * N.SEASON_DAYS,
		int(round(N.ADULT_SHARE * L.residents)), L.residents], 28))
	box.add_child(_rich("[i]" + tr("MODEL_NOTE") + "[/i]", 24))
	box.add_child(_button(tr("NEXT"), func(): show_choice("quarry")))
	box.add_child(_button(tr("BACK"), show_menu, 80, Color(0.4, 0.4, 0.45)))


func show_choice(kind: String) -> void:
	var opts: Array = {"quarry": N.QUARRY, "haul": N.HAUL, "lift": N.LIFT}[kind]
	var pre: String = {"quarry": "q_", "haul": "h_", "lift": "l_"}[kind]
	var box := _page()
	box.add_child(_label(tr("CHOOSE_" + kind.to_upper()), 42, ACCENT))
	box.add_child(_label(tr("CHOOSE_HINT"), 24))
	for o in opts:
		var key: String = pre + o
		var card := PanelContainer.new()
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 10)
		card.add_child(v)
		v.add_child(_label(tr("OPT_" + key), 32, INK))
		v.add_child(_tag(N.TAGS[key]))
		v.add_child(_label(tr("EFF_" + key), 25))
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		row.add_child(_button(tr("SOURCE"), func(): show_source_card(key), 80, Color(0.35, 0.42, 0.30)))
		row.add_child(_button(tr("CHOOSE"), func(): _picked(kind, o), 80))
		v.add_child(row)
		box.add_child(card)
	box.add_child(_button(tr("BACK"), _choice_back.bind(kind), 80, Color(0.4, 0.4, 0.45)))


func show_source_card(key: String) -> void:
	var tag: String = N.TAGS[key]
	var extra := HBoxContainer.new()
	extra.add_child(_tag(tag))
	show_modal(tr("OPT_" + key), "[b]" + tr("SRCLINE_" + key) + "[/b]\n\n" + tr("SRC_" + key) +
		"\n\n[i]" + tr("TAGDESC_" + tag.split(" ")[0].replace("-", "")) + "[/i]", [[tr("CLOSE"), close_modal]], extra)


func _picked(kind: String, o: String) -> void:
	choice[kind] = o
	if kind == "quarry": show_choice("haul")
	elif kind == "haul": show_choice("lift")
	else: start_game()


# ------------------------------------------------------------------ play
func start_game() -> void:
	sim = Sim.new()
	sim.event.connect(_on_sim_event)
	sim.setup(level_index, choice.quarry, choice.haul, choice.lift)
	var box := _page(false)
	box.add_theme_constant_override("separation", 10)
	# HUD
	var top := HBoxContainer.new()
	hud.day = _label("", 27, INK)
	hud.stores = _label("", 27, INK)
	hud.stores.size_flags_horizontal = Control.SIZE_SHRINK_END
	hud.stores.autowrap_mode = TextServer.AUTOWRAP_OFF
	hud.stores.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top.add_child(hud.day); top.add_child(hud.stores)
	box.add_child(top)
	hud.season_bar = ProgressBar.new()
	hud.season_bar.custom_minimum_size = Vector2(0, 22)
	hud.season_bar.show_percentage = false
	hud.season_bar.max_value = sim.total_days
	box.add_child(hud.season_bar)
	site = preload("res://scripts/site_view.gd").new()
	site.sim = sim
	site.size_flags_vertical = Control.SIZE_EXPAND_FILL
	site.clip_contents = true
	box.add_child(site)
	hud.progress = _label("", 28, INK)
	box.add_child(hud.progress)
	hud.info = _label("", 24, Color(0.35, 0.3, 0.25))
	box.add_child(hud.info)
	hud.alert = _label("", 26, Color(0.7, 0.15, 0.1))
	box.add_child(hud.alert)
	# controls
	box.add_child(_stepper("builders", tr("BUILDERS")))
	if sim.haul == "oxen":
		box.add_child(_stepper("yokes", tr("OX_TEAMS")))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	hud.ask = _button(tr("ASK_HELP"), show_ask, 96, Color(0.20, 0.40, 0.55))
	row.add_child(hud.ask)
	hud.pause = _button(tr("PAUSE"), _toggle_pause, 96, Color(0.4, 0.4, 0.45))
	hud.pause.custom_minimum_size.x = 150
	hud.pause.size_flags_horizontal = Control.SIZE_SHRINK_END
	row.add_child(hud.pause)
	hud.speed = _button("x1", _toggle_speed, 96, Color(0.4, 0.4, 0.45))
	hud.speed.custom_minimum_size.x = 110
	hud.speed.size_flags_horizontal = Control.SIZE_SHRINK_END
	row.add_child(hud.speed)
	box.add_child(row)
	_refresh()
	show_modal(tr("START_TITLE"), tr("START_BODY") % [fmt(sim.person_hours_needed()), sim.builders, sim.adults], [[tr("GO"), _go]])


func _stepper(what: String, title: String) -> HBoxContainer:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", 12)
	var l := _label(title, 28)
	r.add_child(l)
	var minus := _button("−5", func(): _change(what, -5), 84, Color(0.45, 0.35, 0.3))
	var minus1 := _button("−1", func(): _change(what, -1), 84, Color(0.45, 0.35, 0.3))
	var plus1 := _button("+1", func(): _change(what, 1), 84)
	var plus := _button("+5", func(): _change(what, 5), 84)
	for b in [minus, minus1, plus1, plus]:
		b.custom_minimum_size.x = 96
		b.size_flags_horizontal = Control.SIZE_SHRINK_END
		r.add_child(b)
	if what == "yokes":
		minus.visible = false; plus.visible = false
	hud["lbl_" + what] = l
	return r


func _change(what: String, d: int) -> void:
	if sim.result != "": return
	if what == "builders":
		sim.set_builders(sim.builders + d)
	else:
		sim.set_yokes(sim.yokes + d)
	_refresh()


func _toggle_pause() -> void:
	running = not running
	_refresh()


func _toggle_speed() -> void:
	speed = {1: 2, 2: 4, 4: 1}[speed]
	_refresh()


func _process(delta: float) -> void:
	if sim == null or not running or modal != null or sim.result != "" or site == null:
		return
	acc += delta * speed
	while acc >= DAY_SEC and running and modal == null and sim.result == "":
		acc -= DAY_SEC
		sim.step_day()
	_refresh()


func _refresh() -> void:
	if hud.is_empty() or sim == null: return
	hud.day.text = tr("HUD_DAY") % [sim.day + 1 if sim.result == "" else sim.day, sim.total_days, sim.season(), sim.L.seasons]
	hud.stores.text = tr("HUD_STORES") % fmt(sim.stores)
	hud.season_bar.value = sim.day
	var course := int(sim.progress() * N.COURSES_PER_TOWER * int(sim.L.towers))
	hud.progress.text = tr("HUD_PROGRESS") % [int(sim.progress() * 100), fmt(sim.placed), fmt(sim.blocks_total)]
	var food_days := int(sim.stores / max(1.0, (sim.builders - sim.lent_hands()) * N.RATION_KG + sim.yokes * N.FODDER_KG_PER_YOKE))
	hud.info.text = tr("HUD_INFO") % [sim.helper_hands(), sim.lent_hands(), food_days, fmt(sim.quarried), fmt(sim.hauled + sim.dressed)]
	hud.lbl_builders.text = tr("BUILDERS") + " %d/%d" % [sim.builders, sim.adults]
	if hud.has("lbl_yokes"):
		hud.lbl_yokes.text = tr("OX_TEAMS") + " %d/%d" % [sim.yokes, sim.L.max_yokes]
	var alert := ""
	if sim.idle_reason == "hunger": alert = tr("ALERT_HUNGER")
	elif sim.idle_reason == "no_oxen": alert = tr("ALERT_NO_OXEN")
	elif food_days < 10 and sim.result == "": alert = tr("ALERT_FOOD_LOW")
	hud.alert.text = alert
	hud.pause.text = tr("PAUSE") if running else tr("PLAY")
	hud.speed.text = "x%d" % speed


func show_ask() -> void:
	if sim.result != "": return
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 12)
	for i in sim.neighbours.size():
		var nb: Dictionary = sim.neighbours[i]
		var card := PanelContainer.new()
		var v := VBoxContainer.new()
		card.add_child(v)
		v.add_child(_label(tr("VILLAGE_" + nb.id), 30, ACCENT))
		v.add_child(_label(tr("VILLAGE_LINE") % [nb.km, nb.hands, nb.trust, int(nb.backlog), int(round(sim.accept_chance(nb) * 100))], 24))
		var b: Button
		if nb.cooldown > 0:
			b = _button(tr("ASK_WAIT") % nb.cooldown, func(): pass, 76, Color(0.6, 0.56, 0.5))
			b.disabled = true
		else:
			b = _button(tr("ASK"), func(): _do_ask(i), 76, Color(0.20, 0.40, 0.55))
		v.add_child(b)
		list.add_child(card)
	show_modal(tr("ASK_HELP"), tr("ASK_EXPLAIN"), [[tr("CLOSE"), close_modal, Color(0.4, 0.4, 0.45)]], list)


func _do_ask(i: int) -> void:
	var nb: Dictionary = sim.neighbours[i]
	var ok := sim.ask(i)
	var name := tr("VILLAGE_" + nb.id)
	if ok:
		show_modal(tr("ASK_YES_T"), tr("ASK_YES") % [name, nb.hands, N.HELP_DAYS], [[tr("OK"), close_modal]])
	else:
		show_modal(tr("ASK_NO_T"), tr("ASK_NO") % name, [[tr("OK"), close_modal]])
	_refresh()


func _on_sim_event(kind: String, data: Dictionary) -> void:
	match kind:
		"request":
			var nb: Dictionary = sim.neighbours[data.i]
			var name := tr("VILLAGE_" + nb.id)
			var note := tr("REQ_NOTE_OWE") if nb.helped_me else tr("REQ_NOTE_FREE")
			show_modal(tr("REQ_T"), tr("REQ_BODY") % [name, data.hands, N.HELP_DAYS] + "\n\n[i]" + note + "[/i]",
				[[tr("REQ_YES"), _answer.bind(true)], [tr("REQ_NO"), _answer.bind(false), Color(0.45, 0.35, 0.3)]])
		"season":
			show_modal(tr("SEASON_T") % (data.season - 1), tr("SEASON_BODY") % [fmt(sim.L.harvest), int(sim.progress() * 100), data.season, sim.L.seasons],
				[[tr("GO"), close_modal]])
		"win", "lose":
			running = false
			call_deferred("show_end")


func show_end() -> void:
	var rec := sim.strategy_record()
	record_text = JSON.stringify(rec, "  ", false)
	var box := _page()
	var win := sim.result == "win"
	box.add_child(_label(tr("WIN_T") if win else tr("LOSE_T"), 46, ACCENT if win else Color(0.5, 0.2, 0.15), true))
	var view := preload("res://scripts/site_view.gd").new()
	view.sim = sim
	view.custom_minimum_size = Vector2(0, 520)
	box.add_child(view)
	var body := (tr("WIN_BODY") % [sim.day, sim.total_days]) if win else (tr("LOSE_BODY") % [int(sim.progress() * 100), fmt(sim.blocks_total - sim.placed)])
	body += "\n\n" + tr("END_STATS") % [fmt(sim.ph_spent.quarry + sim.ph_spent.haul + sim.ph_spent.dress + sim.ph_spent.build),
		sim.asks, sim.asks_yes, sim.requests_in, sim.requests_helped]
	var tags := []
	for k in ["q_" + sim.quarry, "h_" + sim.haul, "l_" + sim.lift]:
		tags.append("%s: %s" % [tr("OPT_" + k), tr("TAG_" + N.TAGS[k].replace(" + ", "_").replace("-", ""))])
	body += "\n\n" + tr("END_METHODS") + "\n• " + "\n• ".join(tags)
	if sim.lift == "pulley" or sim.haul == "rollers":
		body += "\n\n[i]" + tr("END_NOT_MODEL") + "[/i]"
	box.add_child(_rich(body, 26))
	box.add_child(_label(tr("STRATEGY_T"), 34, ACCENT))
	box.add_child(_rich(tr("STRATEGY_BODY"), 23))
	var te := TextEdit.new()
	te.text = record_text
	te.editable = false
	te.custom_minimum_size = Vector2(0, 360)
	te.add_theme_font_size_override("font_size", 18)
	box.add_child(te)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.add_child(_button(tr("COPY"), _copy, 84, Color(0.35, 0.42, 0.30)))
	row.add_child(_button(tr("DOWNLOAD"), _download, 84, Color(0.35, 0.42, 0.30)))
	box.add_child(row)
	box.add_child(_button(tr("PLAY_AGAIN"), func(): start_choices(level_index)))
	if level_index == 0 and win:
		box.add_child(_button(tr("PLAY_L2"), func(): start_choices(1)))
	box.add_child(_button(tr("MENU"), show_menu, 84, Color(0.4, 0.4, 0.45)))


func _download() -> void:
	var fname := "nuraghe_strategy_L%d_%d.json" % [int(sim.L.id), sim.seed]
	if OS.has_feature("web"):
		# a local download made in the browser; nothing is sent anywhere
		JavaScriptBridge.download_buffer(record_text.to_utf8_buffer(), fname, "application/json")
	else:
		var path := OS.get_user_data_dir().path_join(fname)
		var f := FileAccess.open(path, FileAccess.WRITE)
		if f:
			f.store_string(record_text); f.close()
			show_modal("", tr("SAVED_AT") % path, [[tr("OK"), close_modal]])


func _switch_lang() -> void:
	TranslationServer.set_locale("en" if TranslationServer.get_locale().begins_with("it") else "it")
	show_menu()


func _choice_back(kind: String) -> void:
	if kind == "quarry": start_choices(level_index)
	elif kind == "haul": show_choice("quarry")
	else: show_choice("haul")


func _go() -> void:
	close_modal()
	running = true
	_refresh()


func _copy() -> void:
	DisplayServer.clipboard_set(record_text)
	show_modal("", tr("COPIED"), [[tr("OK"), close_modal]])


func _answer(yes: bool) -> void:
	sim.answer_request(yes)
	close_modal()
	_refresh()


# ------------------------------------------------------------------ automated test hook (only with ?autotest in the URL)
var _js_cbs := []


func _setup_autotest() -> void:
	var win = JavaScriptBridge.get_interface("window")
	var cb := JavaScriptBridge.create_callback(_js_probe)
	_js_cbs.append(cb)
	win.nuraghe_probe = cb


func _js_probe(_args) -> void:
	var out := {"buttons": [], "state": {}}
	var xf := get_viewport().get_screen_transform() * get_viewport().get_canvas_transform()
	for b in _all_buttons(modal if modal else self):
		if b.is_visible_in_tree() and not b.disabled:
			var r: Rect2 = xf * b.get_global_rect()
			out.buttons.append({"text": b.text, "x": r.get_center().x, "y": r.get_center().y})
	if sim:
		out.state = {"day": sim.day, "result": sim.result, "progress": sim.progress(), "stores": sim.stores,
			"builders": sim.builders, "pending": not sim.pending.is_empty(), "modal": modal != null}
	out.record = record_text
	JavaScriptBridge.get_interface("window").nuraghe_out = JSON.stringify(out)


func _all_buttons(n: Node) -> Array:
	var a := []
	for c in n.get_children():
		if c is Button: a.append(c)
		a.append_array(_all_buttons(c))
	return a
