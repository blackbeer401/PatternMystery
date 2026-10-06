extends SceneTree

const PrototypeGameState = preload("res://scripts/game_state.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var state := PrototypeGameState.new()
	assert(state.validate_content().is_empty())
	_test_invalid_content_validation(state)
	assert(state.location_id == "central_hall")
	assert(PrototypeGameState.ENTRIES.size() == 6)
	assert(PrototypeGameState.LOCATIONS.size() == 5)

	var invalid_move := state.move_to("missing_location")
	_assert_action_result(invalid_move)
	assert(not invalid_move["ok"])
	assert(state.location_id == "central_hall")
	var invalid_inspection := state.inspect("missing_object")
	_assert_action_result(invalid_inspection)
	assert(not invalid_inspection["ok"])
	assert(invalid_inspection["entry"].is_empty())
	assert(not state.inspect("case_file")["ok"])
	assert(state.get_journal_entry("material", "search_record").is_empty())
	assert(state.get_journal_entries("unknown").is_empty())

	# Every location is reachable before discovering any journal entry.
	_environment_inspection(state, "notice_board")
	_environment_inspection(state, "archive_guide")
	_move(state, "faculty_room")
	assert(not state.move_to("facility_archive")["ok"])
	assert(state.location_id == "faculty_room")
	_move(state, "central_hall")
	_move(state, "facility_archive")
	_move(state, "central_hall")
	_move(state, "annex_waiting_room")
	_environment_inspection(state, "work_log")
	_environment_inspection(state, "site_map")
	_move(state, "annex_wall")
	assert(state.discovery_order == 0)
	assert(state.get_journal_entries("material").is_empty())
	assert(state.get_journal_entries("witness").is_empty())

	var field_first := _discover_all(true)
	var records_first := _discover_all(false)
	for entry_id: String in PrototypeGameState.ENTRIES:
		var kind: String = PrototypeGameState.ENTRIES[entry_id]["kind"]
		var first := field_first.get_journal_entry(kind, entry_id)
		var second := records_first.get_journal_entry(kind, entry_id)
		assert(first["body"] == second["body"])
		assert(first["location_id"] == second["location_id"])
	assert(field_first.get_journal_entry("witness", "hidden_access")["discovered_order"] == 1)
	assert(records_first.get_journal_entry("material", "search_record")["discovered_order"] == 1)
	assert(PrototypeGameState.ENTRIES["search_record"]["body"].contains("별관 기계실 및 설비구역 확인 완료"))
	assert(PrototypeGameState.ENTRIES["closure_record"]["body"].contains("2003년 이전"))
	assert(PrototypeGameState.ENTRIES["missing_case"]["body"].contains("17세"))

	var ui_passed: Variant = await _test_ui()
	assert(ui_passed == true)
	print("BASIC_LOOP_TEST_OK")
	quit()


func _move(state: PrototypeGameState, target_id: String) -> void:
	var result := state.move_to(target_id)
	_assert_action_result(result)
	assert(result["ok"])
	assert(state.location_id == target_id)


func _environment_inspection(state: PrototypeGameState, object_id: String) -> void:
	var result := state.inspect(object_id)
	_assert_action_result(result)
	assert(result["ok"])
	assert(not result["new_entry"])
	assert(result["entry"].is_empty())


func _discover_all(field_first: bool) -> PrototypeGameState:
	var state := PrototypeGameState.new()
	var routes: Array[Dictionary] = [
		{"path": ["annex_waiting_room", "annex_wall"], "objects": ["access_frame", "space_view"]},
		{"path": ["faculty_room"], "objects": ["search_file", "case_file"]},
		{"path": ["facility_archive"], "objects": ["plan_drawer", "facility_register"]}
	]
	if not field_first:
		routes = [routes[1], routes[2], routes[0]]
	var originals := {}
	var feedbacks := {}
	for route: Dictionary in routes:
		for target_id: String in route["path"]:
			_move(state, target_id)
		for object_id: String in route["objects"]:
			var result := state.inspect(object_id)
			_assert_action_result(result)
			assert(result["ok"] and result["new_entry"])
			var entry: Dictionary = result["entry"]
			assert(entry["location_id"] == state.location_id)
			assert(entry["discovered_by"] == "Player 1")
			originals[entry["entry_id"]] = entry.duplicate(true)
			feedbacks[object_id] = result["feedback"]
		var return_path: Array = route["path"].duplicate()
		return_path.pop_back()
		return_path.reverse()
		for target_id: String in return_path:
			_move(state, target_id)
		_move(state, "central_hall")
	assert(state.discovery_order == 6)
	assert(state.get_journal_entries("material").size() == 4)
	assert(state.get_journal_entries("witness").size() == 2)
	# Reinspect after all other evidence: no rewriting or duplicate discovery.
	for route: Dictionary in routes:
		for target_id: String in route["path"]:
			_move(state, target_id)
		for object_id: String in route["objects"]:
			var result := state.inspect(object_id)
			assert(result["ok"] and not result["new_entry"])
			assert(result["entry"] == originals[result["entry"]["entry_id"]])
			assert(result["feedback"] == feedbacks[object_id])
		var return_path: Array = route["path"].duplicate()
		return_path.pop_back()
		return_path.reverse()
		for target_id: String in return_path:
			_move(state, target_id)
		_move(state, "central_hall")
	for kind: String in PrototypeGameState.JOURNAL_KINDS:
		var previous_order := 0
		for entry: Dictionary in state.get_journal_entries(kind):
			assert(entry["discovered_order"] > previous_order)
			previous_order = entry["discovered_order"]
			assert(entry == originals[entry["entry_id"]])
	assert(state.discovery_order == 6)
	return state


func _test_ui() -> bool:
	var main_scene: PackedScene = load("res://scenes/Main.tscn")
	var main := main_scene.instantiate()
	root.add_child(main)
	await process_frame
	assert(main.location_title.text == "중앙복도")
	assert(main.dialogue_overlay.visible)
	assert(not main.journal_overlay.visible)
	assert(main.journal_button.disabled)
	assert(main.speaker.text == "시설 담당자")
	assert(main.dialogue_text.text == main.INTRO[0][1])
	_click_spot(main, "faculty_room")
	assert(main.state.location_id == "central_hall")
	main.journal_button.pressed.emit()
	assert(not main.journal_overlay.visible)
	for index: int in range(4):
		assert(main.dialogue_text.text == main.INTRO[index][1])
		assert(main.speaker.text == main.INTRO[index][0])
		await _mouse_click(Vector2(600, 630) if index == 0 else main.next_line.get_global_rect().get_center())
	assert(not main.dialogue_overlay.visible)
	assert(not main.journal_button.disabled)
	assert(main.state.discovery_order == 0)

	# Existing records remain accessible, and no route is forced.
	for child in main.place_view.get_children():
		if child is Button and child.get_meta("spot", "") == "faculty_room":
			await _mouse_click(child.get_global_rect().get_center())
			break
	assert(main.state.location_id == "faculty_room")
	_click_spot(main, "search_file")
	assert(main.journal_overlay.visible)
	var original: Dictionary = main.state.get_journal_entry("material", "search_record")
	assert(main.entry_body.text == original["body"])
	_click_spot(main, "central_hall")
	assert(main.state.location_id == "faculty_room")
	_press_button(main.journal_overlay, "ui", "close_journal")
	_click_spot(main, "case_file")
	assert(main.journal_overlay.visible)
	_press_button(main.journal_overlay, "ui", "close_journal")
	_click_spot(main, "central_hall")
	assert(not main.dialogue_overlay.visible) # Intro is not replayed.
	_click_spot(main, "facility_archive")
	assert(main.location_title.text == "시설자료실")
	for object_id: String in ["plan_drawer", "facility_register"]:
		_click_spot(main, object_id)
		assert(main.journal_overlay.visible)
		_press_button(main.journal_overlay, "ui", "close_journal")
	_click_spot(main, "central_hall")
	_click_spot(main, "annex_direction")
	assert(main.state.location_id == "annex_wall")
	assert(main.state.get_journal_entries("material").size() == 4)
	assert(main.state.get_journal_entries("witness").is_empty())
	_click_spot(main, "work_board")
	assert(main.dialogue_text.text.contains("B-2"))
	main.next_line.pressed.emit()
	_click_spot(main, "materials")
	main.next_line.pressed.emit()
	assert(main.state.discovery_order == 4)

	_click_spot(main, "wall_zoom")
	assert(main.zoomed)
	assert(main.wall_stage == 0)
	assert(main.state.get_journal_entries("witness").is_empty())
	assert(not _has_spot(main, "space_view"))
	assert(not _has_spot(main, "iron_access"))
	_click_spot(main, "zoom_back")
	assert(not main.zoomed)
	_click_spot(main, "wall_zoom")
	_click_spot(main, "dark_space")
	assert(main.wall_stage == 1)
	assert(main.dialogue_text.text == "…뒤에 뭐가 있는데.")
	assert(main.state.get_journal_entries("witness").is_empty())
	_click_spot(main, "iron_access")
	assert(main.wall_stage == 1) # Dialogue blocks even emitted signals.
	main.next_line.pressed.emit()
	_click_spot(main, "iron_access")
	assert(main.wall_stage == 2)
	assert(main.dialogue_text.text == "…문?")
	assert(main.state.get_journal_entries("witness").size() == 1)
	assert(main.state.get_journal_entry("witness", "remaining_space").is_empty())
	var access: Dictionary = main.state.get_journal_entry("witness", "hidden_access")
	assert(access["location_id"] == "annex_wall")
	assert(access["discovered_order"] == 5)
	main.next_line.pressed.emit()
	for id: String in ["frame_detail", "wall_detail", "old_mark"]:
		_click_spot(main, id)
		assert(main.speaker.text == "주인공")
		main.next_line.pressed.emit()
	assert(main.state.discovery_order == 5)
	_click_spot(main, "space_view")
	assert(main.dialogue_text.text == "생각보다 깊은데.")
	main.next_line.pressed.emit()
	assert(main.state.discovery_order == 6)
	var space: Dictionary = main.state.get_journal_entry("witness", "remaining_space")
	_click_spot(main, "space_view")
	main.next_line.pressed.emit()
	assert(main.state.discovery_order == 6)
	assert(main.state.get_journal_entry("witness", "remaining_space") == space)
	assert(main.state.get_journal_entry("witness", "hidden_access") == access)

	main.journal_button.pressed.emit()
	assert(main.journal_overlay.visible)
	assert(main.witness_list.get_child_count() == 2)
	_press_button(main.material_list, "entry_id", "search_record")
	assert(main.entry_title.text == original["title"])
	assert(main.entry_body.text == original["body"])
	assert(main.entry_meta.text.contains("교무실"))
	assert(main.entry_meta.text.contains("발견 순서: 1"))
	_click_spot(main, "zoom_back")
	assert(main.zoomed) # Journal is modal.
	_press_button(main.journal_overlay, "ui", "close_journal")
	assert(not main.journal_overlay.visible)
	assert(main.zoomed)
	_click_spot(main, "zoom_back")
	assert(not main.zoomed)
	_click_spot(main, "annex_waiting_room")
	assert(main.state.location_id == "annex_waiting_room")
	_click_spot(main, "work_log")
	main.next_line.pressed.emit()
	_click_spot(main, "site_map")
	main.next_line.pressed.emit()
	assert(main.state.discovery_order == 6)
	_click_spot(main, "annex_wall")
	_click_spot(main, "wall_zoom")
	assert(main.wall_stage == 2) # Observed geometry survives returning.
	_click_spot(main, "zoom_back")
	_click_spot(main, "hall_return")
	assert(main.state.location_id == "central_hall")
	assert(not main.dialogue_overlay.visible)
	main.journal_button.pressed.emit()
	assert(main.entry_body.text == original["body"])
	assert(main.state.get_journal_entry("material", "search_record") == original)
	main.queue_free()
	await process_frame

	# Starting with the field requires no archived evidence.
	var fresh := main_scene.instantiate()
	root.add_child(fresh)
	await process_frame
	for index: int in range(4):
		fresh.next_line.pressed.emit()
	_click_spot(fresh, "annex_direction")
	assert(fresh.state.location_id == "annex_wall")
	assert(fresh.state.discovery_order == 0)
	assert(fresh.wall_stage == 0)
	fresh.queue_free()
	await process_frame
	return true


func _mouse_click(position: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = position
	root.push_input(motion, true)
	for pressed: bool in [true, false]:
		var click := InputEventMouseButton.new()
		click.position = position
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = pressed
		root.push_input(click, true)
	await process_frame


func _click_spot(main: Control, id: String) -> void:
	_press_button(main.place_view, "spot", id)


func _has_spot(main: Control, id: String) -> bool:
	for child in main.place_view.get_children():
		if child is Button and child.get_meta("spot", "") == id:
			return true
	return false

func _assert_action_result(result: Dictionary) -> void:
	for key: String in ["ok", "feedback", "new_entry", "entry"]:
		assert(result.has(key))


func _test_invalid_content_validation(state: PrototypeGameState) -> void:
	var locations := {
		"invalid": {"description": "테스트", "color": "not-a-color", "objects": "not-an-array", "exits": 7},
		"invalid_objects": {"title": "테스트", "description": "테스트", "color": "#000000", "objects": [7], "exits": []}
	}
	var errors := state._validate_content_data(locations, {"invalid_entry": 7}, "invalid")
	for expected: String in ["장소 title이 String이 아님", "장소 color가 유효한 HTML 색상이 아님", "장소 objects가 Array가 아님", "장소 exits가 Array가 아님", "조사 오브젝트가 Dictionary가 아님", "journal entry가 Dictionary가 아님"]:
		assert(_has_error(errors, expected))


func _has_error(errors: Array[String], expected: String) -> bool:
	for error: String in errors:
		if expected in error:
			return true
	return false


func _press_button(container: Node, meta_key: String, value: String) -> void:
	for child in container.get_children():
		if child is Button and child.get_meta(meta_key, "") == value:
			child.pressed.emit()
			return
	assert(false, "버튼을 찾을 수 없음: %s=%s" % [meta_key, value])
