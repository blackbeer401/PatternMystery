extends SceneTree

const PrototypeGameState = preload("res://scripts/game_state.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var state := PrototypeGameState.new()
	assert(state.validate_content().is_empty())
	assert(state.location_id == "central_hall")

	var invalid_move := state.move_to("missing_location")
	_assert_action_result(invalid_move)
	assert(not invalid_move["ok"])
	assert(state.location_id == "central_hall")

	var invalid_inspection := state.inspect("missing_object")
	_assert_action_result(invalid_inspection)
	assert(not invalid_inspection["ok"])
	assert(invalid_inspection["entry"].is_empty())

	var no_entry := state.inspect("classroom_door")
	_assert_action_result(no_entry)
	assert(no_entry["ok"])
	assert(not no_entry["new_entry"])
	assert(no_entry["entry"].is_empty())

	assert(state.move_to("faculty_room")["ok"])
	var document := state.inspect("desk")
	_assert_action_result(document)
	assert(document["ok"])
	assert(document["new_entry"])
	assert(state.get_journal_entries("material").size() == 1)
	assert(document["entry"]["location_id"] == "faculty_room")
	assert(document["entry"]["discovered_order"] == 1)
	assert(document["entry"]["discovered_by"] == "Player 1")

	var duplicate := state.inspect("desk")
	_assert_action_result(duplicate)
	assert(not duplicate["new_entry"])
	assert(state.get_journal_entries("material").size() == 1)

	assert(state.move_to("central_hall")["ok"])
	assert(state.move_to("annex_waiting_room")["ok"])
	var worker_note := state.inspect("worker_bag")
	var cold_receiver := state.inspect("interphone")
	assert(worker_note["new_entry"])
	assert(worker_note["entry"]["kind"] == "material")
	assert(cold_receiver["new_entry"])
	assert(cold_receiver["entry"]["kind"] == "witness")

	assert(state.move_to("central_hall")["ok"])
	assert(state.move_to("broadcast_room")["ok"])
	var witness := state.inspect("console")
	assert(witness["new_entry"])
	assert(state.get_journal_entries("witness").size() == 2)
	assert(witness["entry"]["discovered_order"] == 4)
	assert(not state.move_to("faculty_room")["ok"])

	var main_scene: PackedScene = load("res://scenes/Main.tscn")
	var main := main_scene.instantiate()
	root.add_child(main)
	await process_frame
	assert(main.location_title.text == "중앙복도")
	assert(main.entry_body is RichTextLabel)
	assert(main.get_node("Margin/Layout/Body/JournalPanel/JournalListScroll") is ScrollContainer)

	_press_button(main.object_list, "object_id", "notice_board")
	await process_frame
	assert(main.material_list.get_child_count() == 1)
	assert(main.entry_title.text == main.state.get_journal_entries("material")[0]["title"])

	_press_button(main.exit_list, "target_id", "broadcast_room")
	await process_frame
	assert(main.location_title.text == "방송실")
	_press_button(main.object_list, "object_id", "console")
	await process_frame
	assert(main.witness_list.get_child_count() == 1)
	_press_button(main.witness_list, "entry_id", "relay_pulse")
	await process_frame
	assert(main.entry_title.text == main.state.get_journal_entry("witness", "relay_pulse")["title"])

	print("BASIC_LOOP_TEST_OK")
	quit()


func _assert_action_result(result: Dictionary) -> void:
	for key: String in ["ok", "feedback", "new_entry", "entry"]:
		assert(result.has(key))


func _press_button(container: Node, meta_key: String, value: String) -> void:
	for child in container.get_children():
		if child is Button and child.get_meta(meta_key, "") == value:
			child.pressed.emit()
			return
	assert(false, "버튼을 찾을 수 없음: %s=%s" % [meta_key, value])
