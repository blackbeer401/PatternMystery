extends Control

const PrototypeGameState = preload("res://scripts/game_state.gd")
const AnnexBackdrop = preload("res://scripts/annex_backdrop.gd")

# Backgrounds must share the normalized 16:9 composition documented in README.
@export var annex_before_background: Texture2D
@export var annex_revealed_background: Texture2D
# Same image-space crop in both states; hotspot anchors below use this close-up.
const ANNEX_CLOSEUP_REGION := Rect2(0.37, 0.08, 0.39, 0.68)
@export var debug_hotspots := false
var annex_canvas: Control
const INTRO := [
	["시설 담당자", "별관 쪽부터 보시면 됩니다. 벽을 뜯다가 문 같은 게 하나 나왔어요."],
	["주인공", "문이요?"],
	["시설 담당자", "지금 쓰는 도면에는 없는 건데요. 옛날 도면은 시설자료실에 있을 겁니다. 예전 학교 기록은 교무실 쪽에 있고요."],
	["주인공", "알겠습니다."]
]

var state := PrototypeGameState.new()
# Presentation only: observed parts of the close-up, not chapter progress.
var zoomed := false
var wall_stage := 0
var dialogue_lines: Array = []
var dialogue_index := 0
var selected_entry := {"kind": "", "id": ""}
var location_title: Label
var location_description: Label
var place_view: Control
var feedback: Label
var journal_button: Button
var journal_overlay: ColorRect
var material_list: VBoxContainer
var witness_list: VBoxContainer
var entry_title: Label
var entry_meta: Label
var entry_body: RichTextLabel
var dialogue_overlay: Control
var speaker: Label
var dialogue_text: Label
var next_line: Button


func _ready() -> void:
	_build_ui()
	_render_location()
	_start_dialogue(INTRO)


func _fill(node: Control, bounds: Rect2 = Rect2(0, 0, 1, 1)) -> void:
	node.anchor_left = bounds.position.x
	node.anchor_top = bounds.position.y
	node.anchor_right = bounds.end.x
	node.anchor_bottom = bounds.end.y


func _label(parent: Node, text: String, bounds: Rect2, font_size: int = 20) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	_fill(label, bounds)
	return label


func _button(parent: Node, text: String, bounds: Rect2, action: Callable, key: String, value: String) -> Button:
	var button := Button.new()
	button.text = text
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.set_meta(key, value)
	button.pressed.connect(action)
	parent.add_child(button)
	_fill(button, bounds)
	return button


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#141b23")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	_fill(background)
	location_title = _label(self, "", Rect2(0.035, 0.025, 0.65, 0.055), 28)
	journal_button = _button(self, "저널", Rect2(0.85, 0.025, 0.11, 0.055), _open_journal, "ui", "journal")
	place_view = Control.new()
	add_child(place_view)
	_fill(place_view, Rect2(0.035, 0.10, 0.93, 0.72))
	place_view.resized.connect(_layout_annex_canvas)
	location_description = _label(self, "", Rect2(0.04, 0.835, 0.92, 0.07), 17)
	feedback = _label(self, "공간을 클릭해 조사하거나 이동합니다.", Rect2(0.04, 0.925, 0.92, 0.06), 16)

	journal_overlay = ColorRect.new()
	journal_overlay.color = Color(0.02, 0.025, 0.03, 0.98)
	add_child(journal_overlay)
	_fill(journal_overlay)
	_label(journal_overlay, "개인 저널", Rect2(0.05, 0.04, 0.7, 0.06), 28)
	_button(journal_overlay, "닫기", Rect2(0.85, 0.04, 0.1, 0.06), _close_journal, "ui", "close_journal")
	var scroll := ScrollContainer.new()
	scroll.name = "JournalListScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	journal_overlay.add_child(scroll)
	_fill(scroll, Rect2(0.05, 0.14, 0.32, 0.77))
	var columns := VBoxContainer.new()
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(columns)
	var material_heading := Label.new()
	material_heading.text = "자료"
	columns.add_child(material_heading)
	material_list = VBoxContainer.new()
	columns.add_child(material_list)
	var witness_heading := Label.new()
	witness_heading.text = "목격"
	columns.add_child(witness_heading)
	witness_list = VBoxContainer.new()
	columns.add_child(witness_list)
	entry_title = _label(journal_overlay, "저널 항목을 선택하세요", Rect2(0.41, 0.14, 0.53, 0.11), 24)
	entry_meta = _label(journal_overlay, "", Rect2(0.41, 0.26, 0.53, 0.12), 17)
	entry_body = RichTextLabel.new()
	journal_overlay.add_child(entry_body)
	_fill(entry_body, Rect2(0.41, 0.40, 0.53, 0.51))
	journal_overlay.hide()

	dialogue_overlay = Control.new()
	add_child(dialogue_overlay)
	_fill(dialogue_overlay)
	var panel := ColorRect.new()
	panel.color = Color("#10151e")
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialogue_overlay.add_child(panel)
	_fill(panel, Rect2(0.02, 0.80, 0.96, 0.18))
	speaker = _label(dialogue_overlay, "", Rect2(0.05, 0.812, 0.7, 0.04), 20)
	dialogue_text = _label(dialogue_overlay, "", Rect2(0.05, 0.855, 0.75, 0.115), 20)
	next_line = _button(dialogue_overlay, "계속 ▶", Rect2(0.83, 0.89, 0.12, 0.065), _advance_dialogue, "ui", "next")
	# Clicking anywhere advances; the full-screen layer blocks world input.
	dialogue_overlay.gui_input.connect(_dialogue_input)
	dialogue_overlay.hide()


func _dialogue_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_advance_dialogue()
		get_viewport().set_input_as_handled()


func _start_dialogue(lines: Array) -> void:
	dialogue_lines = lines
	dialogue_index = 0
	dialogue_overlay.show()
	journal_button.disabled = true
	_update_dialogue()


func _update_dialogue() -> void:
	speaker.text = dialogue_lines[dialogue_index][0]
	dialogue_text.text = dialogue_lines[dialogue_index][1]


func _advance_dialogue() -> void:
	if not dialogue_overlay.visible:
		return
	dialogue_index += 1
	if dialogue_index >= dialogue_lines.size():
		dialogue_overlay.hide()
		journal_button.disabled = false
		# The first wall inspection has just finished. Reuse the observation stage;
		# no world flag or journal discovery is created by this visual transition.
		if state.location_id == "annex_wall" and zoomed and wall_stage == 0:
			wall_stage = 1
			_render_location()
	else:
		_update_dialogue()


func _blocked() -> bool:
	return dialogue_overlay.visible or journal_overlay.visible


func _decoration(text: String, bounds: Rect2, color: Color) -> void:
	var panel := ColorRect.new()
	panel.color = color
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place_view.add_child(panel)
	_fill(panel, bounds)
	_label(panel, text, Rect2(0.05, 0.05, 0.9, 0.9))


func _spot(text: String, bounds: Rect2, id: String) -> void:
	var button := _button(place_view, text, bounds, _on_spot.bind(id), "spot", id)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.20, 0.24, 0.45)
	style.border_color = Color("#81919c")
	style.set_border_width_all(1)
	button.add_theme_stylebox_override("normal", style)
	var hover := style.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.3, 0.39, 0.45, 0.7)
	button.add_theme_stylebox_override("hover", hover)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _render_location() -> void:
	_clear(place_view)
	annex_canvas = null
	var location := state.get_location()
	location_title.text = location["title"] + (" / 벽체 확대" if zoomed else "")
	location_description.text = location["description"]
	_decoration("", Rect2(0, 0, 1, 1), Color(location["color"]))
	if zoomed:
		_render_zoom()
	elif state.location_id == "central_hall":
		_decoration("복도 끝 / 별관 방향", Rect2(0.40, 0.05, 0.20, 0.62), Color("#0d1219"))
		_decoration("복도 바닥", Rect2(0.12, 0.69, 0.76, 0.28), Color("#313740"))
		_spot("교무실\n↖", Rect2(0.06, 0.19, 0.22, 0.45), "faculty_room")
		_spot("시설자료실\n↗", Rect2(0.72, 0.19, 0.22, 0.45), "facility_archive")
		_spot("별관으로 →", Rect2(0.42, 0.20, 0.16, 0.39), "annex_direction")
		_spot("현장 조사 안내문", Rect2(0.08, 0.76, 0.23, 0.14), "notice_board")
		_spot("자료 배치 안내", Rect2(0.69, 0.76, 0.23, 0.14), "archive_guide")
	elif state.location_id == "annex_wall":
		_render_annex_site()
	else:
		# Temporary legacy content access, only these two places are gameified.
		_label(place_view, "자료 열람 / 기존 조사 화면", Rect2(0.06, 0.06, 0.8, 0.08))
		var index := 0
		for object_definition: Dictionary in location["objects"]:
			_spot(object_definition["label"], Rect2(0.10, 0.23 + index * 0.20, 0.60, 0.14), object_definition["id"])
			index += 1
		index = 0
		for target_id: String in location["exits"]:
			_spot("→ " + state.get_location_title(target_id), Rect2(0.10 + index * 0.39, 0.80, 0.36, 0.13), target_id)
			index += 1


func _annex_scene(closeup: bool) -> void:
	annex_canvas = Control.new()
	annex_canvas.name = "AnnexCanvas"
	annex_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place_view.add_child(annex_canvas)
	var backdrop := TextureRect.new()
	backdrop.name = "BackgroundTexture"
	var source := annex_before_background if wall_stage == 0 else annex_revealed_background
	backdrop.texture = source
	if closeup and source != null:
		var crop := AtlasTexture.new()
		crop.atlas = source
		crop.region = Rect2(ANNEX_CLOSEUP_REGION.position * source.get_size(), ANNEX_CLOSEUP_REGION.size * source.get_size())
		backdrop.texture = crop
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_SCALE
	backdrop.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	annex_canvas.add_child(backdrop)
	_fill(backdrop)
	if backdrop.texture == null:
		var placeholder := AnnexBackdrop.new()
		placeholder.name = "TemporaryGeometry"
		placeholder.closeup = closeup
		placeholder.stage = wall_stage
		annex_canvas.add_child(placeholder)
		_fill(placeholder)
	_layout_annex_canvas()


func _layout_annex_canvas() -> void:
	if not is_instance_valid(annex_canvas):
		return
	var width := minf(place_view.size.x, place_view.size.y * 16.0 / 9.0)
	var height := width * 9.0 / 16.0
	_fill(annex_canvas, Rect2(0.5, 0.5, 0, 0))
	annex_canvas.offset_left = -width / 2.0
	annex_canvas.offset_right = width / 2.0
	annex_canvas.offset_top = -height / 2.0
	annex_canvas.offset_bottom = height / 2.0


func _hotspot(bounds: Rect2, id: String) -> void:
	var button := _button(annex_canvas, "", bounds, _on_spot.bind(id), "spot", id)
	button.name = id
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.tooltip_text = ""
	# No target names or outlines during normal play, including keyboard focus.
	var empty := StyleBoxEmpty.new()
	for style_name: String in ["normal", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(style_name, empty)
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(1, 1, 1, 0.035)
	button.add_theme_stylebox_override("hover", hover)
	if debug_hotspots:
		var debug_style := StyleBoxFlat.new()
		debug_style.bg_color = Color(1, 1, 1, 0.04)
		debug_style.border_color = Color(1, 1, 1, 0.45)
		debug_style.set_border_width_all(1)
		button.add_theme_stylebox_override("normal", debug_style)


func set_debug_hotspots(enabled: bool) -> void:
	debug_hotspots = enabled
	if state.location_id == "annex_wall":
		_render_location()


func _render_annex_site() -> void:
	location_description.text = "벽 마감 일부가 걷힌 작업 현장입니다."
	_annex_scene(false)
	# Both images share the work sheet, passage, material and wall positions.
	_hotspot(Rect2(0.38, 0.08, 0.37, 0.68), "wall_zoom")
	_hotspot(Rect2(0.275, 0.22, 0.095, 0.265), "work_board")
	_hotspot(Rect2(0.76, 0.62, 0.24, 0.29), "materials")
	_hotspot(Rect2(0.075, 0.08, 0.115, 0.73), "hall_return")
	# Keep the legacy waiting-room route on the foreground floor, off the doorway.
	_hotspot(Rect2(0.20, 0.80, 0.14, 0.12), "annex_waiting_room")


func _render_zoom() -> void:
	location_description.text = "철거된 벽체를 가까이 살펴봅니다."
	_annex_scene(true)
	if wall_stage == 1:
		_hotspot(Rect2(0.27, 0.18, 0.45, 0.24), "dark_space")
		_hotspot(Rect2(0.13, 0.13, 0.07, 0.74), "iron_access")
	elif wall_stage == 2:
		_hotspot(Rect2(0.13, 0.13, 0.07, 0.74), "frame_detail")
		_hotspot(Rect2(0.86, 0.14, 0.12, 0.60), "wall_detail")
		_hotspot(Rect2(0.52, 0.47, 0.12, 0.075), "old_mark")
		_hotspot(Rect2(0.27, 0.18, 0.45, 0.24), "space_view")
	_label(annex_canvas, "‹", Rect2(0.035, 0.88, 0.05, 0.09), 26)
	_hotspot(Rect2(0.02, 0.87, 0.12, 0.12), "zoom_back")

func _on_spot(id: String) -> void:
	if _blocked() or not _active_spot(place_view, id):
		return
	if id == "annex_direction" and state.location_id == "central_hall":
		# Traverse existing connections rather than changing the world graph.
		if state.move_to("annex_waiting_room")["ok"]:
			_on_move("annex_wall")
	elif id == "hall_return" and state.location_id == "annex_wall" and not zoomed:
		if state.move_to("annex_waiting_room")["ok"]:
			_on_move("central_hall")
	elif id == "wall_zoom" and state.location_id == "annex_wall":
		zoomed = true
		_render_location()
		if wall_stage == 0:
			_start_dialogue([["주인공", "…뒤에 뭐가 있는데."]])
	elif id == "zoom_back" and zoomed:
		zoomed = false
		_render_location()
	elif zoomed:
		_on_zoom_spot(id)
	elif id == "work_board" and state.location_id == "annex_wall":
		_start_dialogue([["주인공", "B-2 작업구역. 벽체 철거 작업표다."]])
	elif id == "materials" and state.location_id == "annex_wall":
		_start_dialogue([["주인공", "걷어낸 마감재가 한쪽에 쌓여 있어."]])
	elif id in state.get_location()["exits"]:
		_on_move(id)
	else:
		_on_inspect(id)


func _on_zoom_spot(id: String) -> void:
	if state.location_id != "annex_wall":
		return
	match id:
		"dark_space", "iron_access":
			if wall_stage != 1:
				return
			wall_stage = 2
			_record_observation("access_frame", "…문?")
		"frame_detail":
			if wall_stage == 2:
				_start_dialogue([["주인공", "벽보다 훨씬 오래됐어."]])
		"wall_detail":
			if wall_stage == 2:
				_start_dialogue([["주인공", "문을 없앤 게 아니라… 앞을 막은 건가."]])
		"old_mark":
			if wall_stage == 2:
				_start_dialogue([["주인공", "…기계실?"]])
		"space_view":
			if wall_stage == 2:
				_record_observation("space_view", "생각보다 깊은데.")
	_render_location()


func _record_observation(object_id: String, reaction: String) -> void:
	var result := state.inspect(object_id)
	if result["ok"]:
		feedback.text = "저널에 기록했습니다." if result["new_entry"] else "이미 기록한 관찰입니다."
		_start_dialogue([["주인공", reaction]])


func _on_move(target_id: String) -> void:
	if _blocked():
		return
	var result := state.move_to(target_id)
	feedback.text = result["feedback"]
	if result["ok"]:
		zoomed = false
		_render_location()


func _on_inspect(object_id: String) -> void:
	if _blocked():
		return
	var result := state.inspect(object_id)
	feedback.text = result["feedback"]
	if result["ok"]:
		var entry: Dictionary = result["entry"]
		if not entry.is_empty():
			selected_entry = {"kind": entry["kind"], "id": entry["entry_id"]}
			_open_journal()
		else:
			_start_dialogue([["주인공", result["feedback"]]])


func _open_journal() -> void:
	if dialogue_overlay.visible:
		return
	_render_journal_list("material", material_list)
	_render_journal_list("witness", witness_list)
	_show_entry(selected_entry["kind"], selected_entry["id"])
	journal_overlay.show()


func _close_journal() -> void:
	journal_overlay.hide()


func _render_journal_list(kind: String, container: VBoxContainer) -> void:
	_clear(container)
	var entries := state.get_journal_entries(kind)
	if entries.is_empty():
		var empty_label := Label.new()
		empty_label.text = "아직 없음"
		container.add_child(empty_label)
	for entry: Dictionary in entries:
		var button := Button.new()
		button.text = "%d. %s" % [entry["discovered_order"], entry["title"]]
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size.y = 56
		button.set_meta("entry_id", entry["entry_id"])
		button.pressed.connect(_show_entry.bind(kind, entry["entry_id"]))
		container.add_child(button)


func _show_entry(kind: String, entry_id: String) -> void:
	var entry := state.get_journal_entry(kind, entry_id)
	if entry.is_empty():
		return
	selected_entry = {"kind": kind, "id": entry_id}
	entry_title.text = entry["title"]
	entry_meta.text = "%s · 발견 장소: %s · 발견 순서: %d · 발견자: %s" % ["자료" if kind == "material" else "목격", entry["location_title"], entry["discovered_order"], entry["discovered_by"]]
	entry_body.text = entry["body"]


func _clear(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()


func _active_spot(parent: Node, id: String) -> bool:
	for child in parent.get_children():
		if child is Button and child.get_meta("spot", "") == id:
			return true
		if _active_spot(child, id):
			return true
	return false
