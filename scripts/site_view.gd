extends Control
## Draws the building site: quarry, haul path, piles, sledges and the tower(s) rising course by course.
## Plain 2D drawing, no textures, so it stays light on phones.

var sim: Sim
var t := 0.0
const STONE := Color(0.84, 0.80, 0.70)
const STONE_D := Color(0.72, 0.67, 0.57)
const MORTAR := Color(0.45, 0.40, 0.33)
const GROUND := Color(0.63, 0.64, 0.42)
const GROUND_D := Color(0.52, 0.54, 0.34)
const SKY_TOP := Color(0.56, 0.74, 0.88)
const SKY_LOW := Color(0.93, 0.89, 0.80)


func _process(delta: float) -> void:
	t += delta
	queue_redraw()


func _draw() -> void:
	var W := size.x
	var H := size.y
	# sky gradient (two rects) and hills
	for i in 8:
		draw_rect(Rect2(0, H * 0.62 * i / 8.0, W, H * 0.62 / 8.0 + 1), SKY_TOP.lerp(SKY_LOW, i / 8.0))
	var hills := PackedVector2Array([Vector2(0, H * 0.55), Vector2(W * 0.18, H * 0.44), Vector2(W * 0.4, H * 0.52),
		Vector2(W * 0.65, H * 0.42), Vector2(W, H * 0.5), Vector2(W, H * 0.62), Vector2(0, H * 0.62)])
	draw_colored_polygon(hills, Color(0.62, 0.66, 0.50))
	draw_rect(Rect2(0, H * 0.6, W, H * 0.4), GROUND)
	draw_rect(Rect2(0, H * 0.86, W, H * 0.14), GROUND_D)
	if sim == null:
		return
	var ground_y := H * 0.80
	var far: bool = sim.quarry == "far"
	# quarry: a rocky outcrop on the left (smaller and higher when it is far away)
	var qx := W * (0.06 if far else 0.16)
	var qy := ground_y - (H * 0.17 if far else H * 0.02)
	var qs := 0.55 if far else 1.0
	_draw_quarry(Vector2(qx, qy), qs)
	# haul path
	var tower_x := W * 0.66
	var path_a := Vector2(qx + 60 * qs, qy + 10 * qs)
	var path_b := Vector2(tower_x - 120, ground_y + 20)
	var pts := PackedVector2Array()
	for i in 21:
		var f := i / 20.0
		var p := path_a.lerp(path_b, f)
		p.y += sin(f * PI) * 30.0
		pts.append(p)
	draw_polyline(pts, Color(0.75, 0.68, 0.50), 14.0)
	var label := "200 m" if not far else "1 km"
	draw_string(get_theme_default_font(), pts[6] + Vector2(-30, 44), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(0.3, 0.26, 0.2))
	# stone piles: quarried (at the quarry) and hauled + dressed (in the yard)
	_pile(Vector2(qx + 70 * qs, qy + 34 * qs), sim.quarried, qs)
	_pile(Vector2(tower_x - 150, ground_y + 60), sim.hauled + sim.dressed, 1.0)
	# sledges moving on the path
	var hauling := sim.hands_today > 0 and sim.quarried > 0.5 and sim.result == ""
	if hauling:
		var n := clampi(int(sim.hands_today / 8.0) + 1, 1, 5)
		for k in n:
			var f := fmod(t * (0.06 if far else 0.16) + k / float(n), 1.0)
			var idx := f * 20.0
			var a := pts[int(idx)]
			var b := pts[min(int(idx) + 1, 20)]
			var p := a.lerp(b, idx - int(idx))
			_sledge(p, (b - a).normalized())
	# tower(s)
	var prog := sim.progress()
	if int(sim.L.towers) == 1:
		_tower(Vector2(tower_x, ground_y + 40), 230.0, 150.0, 440.0, prog)
	else:
		var keep := clampf(prog * 3.0, 0.0, 1.0)
		var lat := clampf((prog - 1.0 / 3.0) * 1.5, 0.0, 1.0)
		_tower(Vector2(tower_x, ground_y + 10), 190.0, 124.0, 380.0, keep)
		_tower(Vector2(tower_x - 150, ground_y + 70), 130.0, 90.0, 240.0, lat)
		_tower(Vector2(tower_x + 150, ground_y + 70), 130.0, 90.0, 240.0, lat)
	# people at the top of the wall when building
	if sim.hands_today > 0 and sim.result == "" and prog > 0.0:
		var one := int(sim.L.towers) == 1
		var keep_done := prog * 3.0 >= 1.0
		var top_y: float
		var cx := tower_x
		if one:
			top_y = ground_y + 40 - 440.0 * _height_frac(prog)
		elif not keep_done:
			top_y = ground_y + 10 - 380.0 * _height_frac(prog * 3.0)
		else:
			top_y = ground_y + 70 - 240.0 * _height_frac(clampf((prog - 1.0 / 3.0) * 1.5, 0.0, 1.0))
			cx = tower_x + 150 if int(t) % 2 == 0 else tower_x - 150
		for k in 3:
			var x := cx - 30 + k * 30 + sin(t * 2.0 + k) * 6
			_person(Vector2(x, top_y - 4))


func _height_frac(p: float) -> float:
	return float(int(p * N.COURSES_PER_TOWER)) / N.COURSES_PER_TOWER + fmod(p * N.COURSES_PER_TOWER, 1.0) / N.COURSES_PER_TOWER


func _draw_quarry(c: Vector2, s: float) -> void:
	var rock := PackedVector2Array([c + Vector2(-70, 40) * s, c + Vector2(-50, -40) * s, c + Vector2(0, -70) * s,
		c + Vector2(60, -50) * s, c + Vector2(90, 40) * s])
	draw_colored_polygon(rock, STONE_D)
	draw_polyline(rock, MORTAR, 3.0)
	for i in 4:
		draw_line(c + Vector2(-40 + i * 30, -40 + i * 6) * s, c + Vector2(-30 + i * 30, 30) * s, MORTAR, 2.0)


func _pile(base: Vector2, n_blocks: float, s: float) -> void:
	var n := clampi(int(ceil(n_blocks / 15.0)), 0, 24)
	var bw := 26.0 * s
	var bh := 16.0 * s
	for i in n:
		var row := 0
		var cap := 6
		var j := i
		while j >= cap and cap > 1:
			j -= cap; row += 1; cap -= 1
		var x := base.x + (j - cap / 2.0) * bw + row * bw * 0.5
		var y := base.y - row * bh
		draw_rect(Rect2(x, y - bh, bw - 2, bh - 2), STONE)
		draw_rect(Rect2(x, y - bh, bw - 2, bh - 2), MORTAR, false, 1.5)


func _sledge(p: Vector2, dir: Vector2) -> void:
	draw_rect(Rect2(p.x - 18, p.y - 14, 36, 14), STONE)
	draw_rect(Rect2(p.x - 18, p.y - 14, 36, 14), MORTAR, false, 1.5)
	draw_line(p + Vector2(-22, 2), p + Vector2(22, 2), Color(0.42, 0.28, 0.15), 4.0)
	if sim.haul == "oxen":
		var o := p + dir * 46
		draw_rect(Rect2(o.x - 16, o.y - 18, 32, 16), Color(0.45, 0.30, 0.18))
		draw_line(p + dir * 22, o, Color(0.3, 0.2, 0.1), 2.0)
		_person(o + dir * 24 + Vector2(0, -2))
	else:
		for k in 3:
			var q := p + dir * (34 + k * 16) + Vector2(0, (k % 2) * 6)
			draw_line(p + dir * 20, q, Color(0.4, 0.3, 0.2), 1.0)
			_person(q)


func _person(p: Vector2) -> void:
	draw_line(p, p + Vector2(0, -16), Color(0.35, 0.25, 0.18), 4.0)
	draw_circle(p + Vector2(0, -21), 5.0, Color(0.55, 0.38, 0.26))


func _tower(base: Vector2, w0: float, w1: float, h: float, p: float) -> void:
	# outline of the finished tower (faint), then the built courses
	var nC := N.COURSES_PER_TOWER
	var ch := h / nC
	var ghost := PackedVector2Array([base + Vector2(-w0 / 2, 0), base + Vector2(-w1 / 2, -h), base + Vector2(w1 / 2, -h), base + Vector2(w0 / 2, 0)])
	draw_polyline(ghost + PackedVector2Array([ghost[0]]), Color(0.4, 0.35, 0.3, 0.35), 2.0)
	var full := int(p * nC)
	var part := p * nC - full
	for i in range(min(full + 1, nC)):
		var f0 := float(i) / nC
		var f1 := float(i + 1) / nC
		var wa := lerpf(w0, w1, f0)
		var wb := lerpf(w0, w1, f1)
		var y0 := base.y - i * ch
		var y1 := y0 - ch
		var frac := 1.0 if i < full else part
		if frac <= 0.0:
			break
		var tone := STONE if i % 2 == 0 else STONE.darkened(0.06)
		# blocks of this course, filled left to right
		var nb := 6 if i % 2 == 0 else 5
		var shown := int(ceil(nb * frac))
		for k in shown:
			var u0 := (k + (0.5 if i % 2 else 0.0)) / (nb + (0.5 if i % 2 else 0.0))
			var u1 := (k + 1 + (0.5 if i % 2 else 0.0)) / (nb + (0.5 if i % 2 else 0.0))
			if i % 2 == 1 and k == 0:
				u0 = 0.0
			u1 = min(u1, 1.0)
			var poly := PackedVector2Array([
				Vector2(base.x - wa / 2 + wa * u0, y0), Vector2(base.x - wb / 2 + wb * u0, y1),
				Vector2(base.x - wb / 2 + wb * u1, y1), Vector2(base.x - wa / 2 + wa * u1, y0)])
			draw_colored_polygon(poly, tone)
			draw_polyline(poly + PackedVector2Array([poly[0]]), MORTAR, 1.5)
	# doorway
	if full >= 3:
		draw_rect(Rect2(base.x - 14, base.y - ch * 3, 28, ch * 3), Color(0.25, 0.2, 0.16))
