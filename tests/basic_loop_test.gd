extends SceneTree

const PrototypeGameState = preload("res://scripts/game_state.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var state := PrototypeGameState.new()
	assert(state.location_id == "central_hall")
	assert(state.move_to("faculty_room"))
	var document := state.inspect("desk")
	assert(document["ok"])
	assert(document["new_entry"])
	assert(state.get_journal_entries("material").size() == 1)
	assert(document["entry"]["location_id"] == "faculty_room")
	assert(document["entry"]["discovered_order"] == 1)
	assert(document["entry"]["discovered_by"] == "Player 1")

	var duplicate := state.inspect("desk")
	assert(not duplicate["new_entry"])
	assert(state.get_journal_entries("material").size() == 1)

	assert(state.move_to("central_hall"))
	assert(state.move_to("broadcast_room"))
	var witness := state.inspect("console")
	assert(witness["new_entry"])
	assert(state.get_journal_entries("witness").size() == 1)
	assert(witness["entry"]["discovered_order"] == 2)
	assert(not state.move_to("faculty_room"))

	var main_scene: PackedScene = load("res://scenes/Main.tscn")
	var main := main_scene.instantiate()
	root.add_child(main)
	await process_frame
	assert(main.location_title.text == "중앙복도")

	main.object_list.get_child(0).pressed.emit()
	await process_frame
	assert(main.material_list.get_child_count() == 1)
	assert(main.entry_title.text == "철거 사전점검 안내문")

	main.exit_list.get_child(1).pressed.emit()
	await process_frame
	assert(main.location_title.text == "방송실")
	main.object_list.get_child(0).pressed.emit()
	await process_frame
	assert(main.witness_list.get_child_count() == 1)
	main.witness_list.get_child(0).pressed.emit()
	await process_frame
	assert(main.entry_title.text == "순간적으로 점멸한 표시등")

	print("BASIC_LOOP_TEST_OK")
	quit()
