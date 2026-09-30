extends Control

const PrototypeGameState = preload("res://scripts/game_state.gd")

var state := PrototypeGameState.new()

@onready var background: ColorRect = $Background
@onready var location_title: Label = $Margin/Layout/Header/LocationTitle
@onready var location_description: Label = $Margin/Layout/Body/LocationPanel/LocationDescription
@onready var object_list: VBoxContainer = $Margin/Layout/Body/LocationPanel/ObjectList
@onready var exit_list: HBoxContainer = $Margin/Layout/Body/LocationPanel/ExitList
@onready var feedback: Label = $Margin/Layout/Body/LocationPanel/Feedback
@onready var material_list: VBoxContainer = $Margin/Layout/Body/JournalPanel/JournalColumns/MaterialColumn/MaterialList
@onready var witness_list: VBoxContainer = $Margin/Layout/Body/JournalPanel/JournalColumns/WitnessColumn/WitnessList
@onready var entry_title: Label = $Margin/Layout/Body/JournalPanel/EntryTitle
@onready var entry_meta: Label = $Margin/Layout/Body/JournalPanel/EntryMeta
@onready var entry_body: Label = $Margin/Layout/Body/JournalPanel/EntryBody


func _ready() -> void:
	_render_all()


func _render_all() -> void:
	_render_location()
	_render_journal()


func _render_location() -> void:
	var location := state.get_location()
	background.color = Color(location["color"])
	location_title.text = location["title"]
	location_description.text = location["description"]
	_clear(object_list)
	_clear(exit_list)

	for object_definition: Dictionary in location["objects"]:
		var button := Button.new()
		button.text = object_definition["label"]
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_inspect.bind(object_definition["id"]))
		object_list.add_child(button)

	for target_id: String in location["exits"]:
		var button := Button.new()
		button.text = "%s로 이동" % state.get_location_title(target_id)
		button.pressed.connect(_on_move.bind(target_id))
		exit_list.add_child(button)


func _render_journal() -> void:
	_render_journal_list("material", material_list)
	_render_journal_list("witness", witness_list)


func _render_journal_list(kind: String, container: VBoxContainer) -> void:
	_clear(container)
	var entries := state.get_journal_entries(kind)
	if entries.is_empty():
		var empty_label := Label.new()
		empty_label.text = "아직 없음"
		empty_label.modulate = Color(0.6, 0.62, 0.64)
		container.add_child(empty_label)
		return

	for entry: Dictionary in entries:
		var button := Button.new()
		button.text = "%d. %s" % [entry["discovered_order"], entry["title"]]
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_show_entry.bind(kind, entry["entry_id"]))
		container.add_child(button)


func _on_move(target_id: String) -> void:
	if not state.move_to(target_id):
		feedback.text = "그 장소로 바로 이동할 수 없다."
		return
	feedback.text = "%s에 도착했다." % state.get_location()["title"]
	_render_location()


func _on_inspect(object_id: String) -> void:
	var result := state.inspect(object_id)
	feedback.text = result["feedback"]
	if not result["entry"].is_empty():
		_render_journal()
		_show_entry(result["entry"]["kind"], result["entry"]["entry_id"])


func _show_entry(kind: String, entry_id: String) -> void:
	var entry := state.get_journal_entry(kind, entry_id)
	if entry.is_empty():
		return
	entry_title.text = entry["title"]
	entry_meta.text = "%s · 발견 장소: %s · 발견 순서: %d · 발견자: %s" % [
		"자료" if kind == "material" else "목격",
		entry["location_title"],
		entry["discovered_order"],
		entry["discovered_by"]
	]
	entry_body.text = entry["body"]


func _clear(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
