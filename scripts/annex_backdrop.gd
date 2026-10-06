extends Control

# Temporary geometry only. The sibling TextureRect replaces this drawing when
# an authored background is assigned. Coordinates share a 320 x 180 layout.
var closeup := false
var stage := 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, size / Vector2(320, 180))
	if closeup:
		_draw_closeup()
	else:
		_draw_site()


func _block(rect: Rect2, shade: String) -> void:
	draw_rect(rect, Color(shade))


func _draw_site() -> void:
	_block(Rect2(0, 0, 320, 180), "#292929")
	# Left passage, wall planes, and a floor converging on the rear wall.
	draw_colored_polygon(PackedVector2Array([Vector2(0, 0), Vector2(70, 20), Vector2(70, 130), Vector2(0, 180)]), Color("#393939"))
	_block(Rect2(70, 20, 250, 110), "#525252")
	draw_colored_polygon(PackedVector2Array([Vector2(0, 180), Vector2(70, 130), Vector2(320, 130), Vector2(320, 180)]), Color("#333333"))
	_block(Rect2(6, 26, 33, 114), "#161616")
	_block(Rect2(6, 26, 3, 114), "#646464")
	_block(Rect2(39, 24, 3, 118), "#474747")
	for x: int in range(85, 310, 30):
		draw_line(Vector2(x, 20), Vector2(x, 129), Color("#494949"), 1)
	for y: int in [48, 81, 109]:
		draw_line(Vector2(70, y), Vector2(320, y), Color("#494949"), 1)
	# Work sheet clipped to a small physical board, not a menu rectangle.
	_block(Rect2(72, 51, 24, 37), "#252525")
	_block(Rect2(75, 54, 18, 29), "#a1a19c")
	_block(Rect2(81, 52, 6, 3), "#666666")
	for y: int in [60, 64, 69, 74, 78]:
		_block(Rect2(78, y, 12 if y != 74 else 7, 1), "#666666")
	# Ragged removal edge; the structure is still mostly in shadow.
	draw_colored_polygon(PackedVector2Array([Vector2(126, 28), Vector2(212, 28), Vector2(212, 36), Vector2(222, 36), Vector2(222, 112), Vector2(214, 112), Vector2(214, 129), Vector2(119, 129), Vector2(119, 42), Vector2(126, 42)]), Color("#888884"))
	_block(Rect2(129, 36, 79, 93), "#161616")
	_block(Rect2(134, 40, 3, 87), "#3b3836")
	_block(Rect2(137, 40, 65, 3), "#373634")
	_block(Rect2(202, 42, 3, 85), "#353535")
	_block(Rect2(144, 49, 53, 80), "#0d0d0d")
	for rect: Rect2 in [Rect2(120, 133, 17, 3), Rect2(138, 139, 12, 3), Rect2(195, 133, 9, 4), Rect2(211, 141, 15, 3)]:
		_block(rect, "#73736f")
	# Stacked discarded panels, subdued wood, and a dust sheet.
	draw_colored_polygon(PackedVector2Array([Vector2(254, 125), Vector2(303, 125), Vector2(315, 153), Vector2(258, 153)]), Color("#4c4c4a"))
	_block(Rect2(243, 145, 65, 5), "#686660")
	_block(Rect2(250, 152, 60, 4), "#55534e")
	_block(Rect2(247, 158, 62, 4), "#706e68")
	_block(Rect2(257, 164, 48, 3), "#45443f")
	# Small neutral wayfinding arrows painted on the floor at the passage.
	_arrow(Vector2(18, 158), false)
	_arrow(Vector2(51, 123), true)


func _draw_closeup() -> void:
	_block(Rect2(0, 0, 320, 180), "#4e4e4c")
	for x: int in range(0, 320, 32):
		draw_line(Vector2(x, 0), Vector2(x, 180), Color("#464644"), 1)
	for y: int in range(15, 180, 30):
		draw_line(Vector2(0, y), Vector2(320, y), Color("#454543"), 1)
	# The front cladding and older frame occupy distinct layers.
	draw_colored_polygon(PackedVector2Array([Vector2(103, 10), Vector2(223, 10), Vector2(223, 24), Vector2(232, 24), Vector2(232, 145), Vector2(219, 145), Vector2(219, 161), Vector2(96, 161), Vector2(96, 35), Vector2(103, 35)]), Color("#898985"))
	_block(Rect2(110, 25, 107, 132), "#171717")
	var iron := "#514b47" if stage > 0 else "#252423"
	_block(Rect2(110, 25, 9, 132), iron)
	_block(Rect2(110, 25, 107, 8), iron)
	_block(Rect2(208, 25, 9, 132), iron)
	_block(Rect2(119, 33, 89, 123), "#0b0b0b")
	if stage > 0:
		for y: int in [35, 74, 119, 149]:
			_block(Rect2(112, y, 3, 3), "#797773")
		_block(Rect2(113, 51, 2, 14), "#62564e")
	if stage >= 2:
		# Partial partition, floor and back wall; no whole interior is shown.
		draw_colored_polygon(PackedVector2Array([Vector2(120, 144), Vector2(180, 106), Vector2(207, 116), Vector2(207, 156), Vector2(120, 156)]), Color("#292929"))
		_block(Rect2(181, 43, 26, 76), "#1b1b1b")
		_block(Rect2(179, 43, 3, 83), "#353535")
		draw_line(Vector2(121, 153), Vector2(179, 121), Color("#41413f"), 1)
		# An illegible worn plate, readable only through its existing reaction.
		_block(Rect2(139, 14, 42, 9), "#62625e")
		for x: int in [143, 151, 158, 168, 175]:
			_block(Rect2(x, 17, 3, 1), "#999991")
	# Broken edge of the newer wall and scattered plaster.
	_block(Rect2(232, 33, 6, 103), "#a0a09a")
	_block(Rect2(238, 43, 5, 90), "#353533")
	_block(Rect2(243, 49, 10, 75), "#73736e")
	for rect: Rect2 in [Rect2(90, 161, 16, 4), Rect2(107, 168, 11, 3), Rect2(231, 151, 21, 4), Rect2(249, 159, 13, 3)]:
		_block(rect, "#878780")
	_arrow(Vector2(19, 167), false)


func _arrow(origin: Vector2, upward: bool) -> void:
	var points := PackedVector2Array([Vector2(7, 0), Vector2(0, 5), Vector2(7, 10)])
	if upward:
		points = PackedVector2Array([Vector2(0, 7), Vector2(5, 0), Vector2(10, 7)])
	for index: int in range(points.size()):
		points[index] += origin
	draw_polyline(points, Color("#999994"), 2)
