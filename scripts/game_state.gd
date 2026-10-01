class_name PrototypeGameState
extends RefCounted

const PLAYER_NAME := "Player 1"
const START_LOCATION := "central_hall"
const JOURNAL_KINDS := ["material", "witness"]

const ENTRIES := {
	"entrance_notice": {
		"kind": "material",
		"title": "철거 사전점검 안내문",
		"body": "철거 사전점검 기간에는 출입 기록을 남기고, 이상 설비를 발견하면 현장 책임자에게 보고할 것.\n\n※ 프로토타입용 문서입니다."
	},
	"inspection_sheet": {
		"kind": "material",
		"title": "교무실 점검표",
		"body": "교무실 창문 잠금 확인. 캐비닛 2번은 열쇠 분실로 확인 보류.\n\n작성자와 작성 시각은 비어 있다."
	},
	"relay_pulse": {
		"kind": "witness",
		"title": "순간적으로 점멸한 표시등",
		"body": "방송 콘솔의 네 번째 표시등이 한 차례 희미하게 점멸했다. 다른 장비에는 변화가 없었다."
	},
	"worker_note": {
		"kind": "material",
		"title": "작업자의 메모",
		"body": "별관 인터폰 선로는 연결되어 있지만 응답 상태가 불안정하다. 다음 점검 때 방송실 단자와 함께 확인할 것."
	},
	"cold_receiver": {
		"kind": "witness",
		"title": "차가운 인터폰 수화기",
		"body": "인터폰 수화기는 주변 공기보다 뚜렷하게 차갑다. 수화기에서는 아무 소리도 들리지 않는다."
	}
}

const LOCATIONS := {
	"central_hall": {
		"title": "중앙복도",
		"description": "세 방향으로 복도가 갈라진다. 빛바랜 안내판과 닫힌 교실문이 보인다.",
		"color": "#182029",
		"objects": [
			{"id": "notice_board", "label": "안내판 조사", "feedback": "안내판 아래에 접힌 안내문이 끼워져 있다.", "entry_id": "entrance_notice"},
			{"id": "classroom_door", "label": "닫힌 교실문 조사", "feedback": "문은 잠겨 있다. 지금은 열 수 없다."}
		],
		"exits": ["faculty_room", "broadcast_room", "annex_waiting_room"]
	},
	"faculty_room": {
		"title": "교무실",
		"description": "먼지가 내려앉은 책상과 철제 캐비닛이 남아 있다.",
		"color": "#29231d",
		"objects": [
			{"id": "desk", "label": "책상 조사", "feedback": "서류 더미 아래에서 점검표를 발견했다.", "entry_id": "inspection_sheet"},
			{"id": "cabinet", "label": "캐비닛 조사", "feedback": "2번 캐비닛만 잠겨 있다. 손잡이에 최근 긁힌 흔적이 있다."}
		],
		"exits": ["central_hall"]
	},
	"broadcast_room": {
		"title": "방송실",
		"description": "낡은 콘솔과 회선 표시등이 어둠 속에 줄지어 있다.",
		"color": "#151f1d",
		"objects": [
			{"id": "console", "label": "방송 콘솔 조사", "feedback": "전원은 꺼져 있지만 네 번째 표시등이 순간적으로 점멸했다.", "entry_id": "relay_pulse"},
			{"id": "breaker", "label": "배전반 조사", "feedback": "각 회로의 명칭표가 지워져 있다. 스위치는 건드리지 않았다."}
		],
		"exits": ["central_hall"]
	},
	"annex_waiting_room": {
		"title": "별관 대기실",
		"description": "금이 간 창문 옆에 인터폰과 접이식 의자가 놓여 있다.",
		"color": "#211c27",
		"objects": [
			{"id": "worker_bag", "label": "작업 가방 조사", "feedback": "가방 안쪽에서 접힌 메모를 발견했다.", "entry_id": "worker_note"},
			{"id": "interphone", "label": "인터폰 조사", "feedback": "수화기는 이상할 정도로 차갑고 아무 소리도 나지 않는다.", "entry_id": "cold_receiver"}
		],
		"exits": ["central_hall"]
	}
}

var location_id := START_LOCATION
var discovery_order := 0
var journal := {"material": {}, "witness": {}}


func get_location() -> Dictionary:
	return LOCATIONS[location_id]


func get_location_title(target_id: String) -> String:
	return LOCATIONS.get(target_id, {}).get("title", target_id)


func move_to(target_id: String) -> Dictionary:
	if not LOCATIONS.has(target_id) or target_id not in get_location().get("exits", []):
		return _action_result(false, "그 장소로 바로 이동할 수 없다.")
	location_id = target_id
	return _action_result(true, "%s에 도착했다." % get_location_title(target_id))


func inspect(object_id: String) -> Dictionary:
	var object_definition: Dictionary = {}
	for candidate: Dictionary in get_location()["objects"]:
		if candidate["id"] == object_id:
			object_definition = candidate
			break

	if object_definition.is_empty():
		return _action_result(false, "현재 장소에서는 조사할 수 없다.")

	var result := _action_result(true, object_definition.get("feedback", ""))
	if not object_definition.has("entry_id"):
		return result

	var entry_id: String = object_definition["entry_id"]
	if not ENTRIES.has(entry_id):
		return _action_result(false, "조사 데이터가 올바르지 않다.")
	var definition: Dictionary = ENTRIES[entry_id]
	var kind: String = definition.get("kind", "")
	if not journal.has(kind):
		return _action_result(false, "조사 데이터가 올바르지 않다.")
	if not journal[kind].has(entry_id):
		discovery_order += 1
		journal[kind][entry_id] = {
			"location_id": location_id,
			"discovered_order": discovery_order,
			"discovered_by": PLAYER_NAME
		}
		result["new_entry"] = true
	result["entry"] = get_journal_entry(kind, entry_id)
	return result


func get_journal_entries(kind: String) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	if not journal.has(kind):
		return entries
	for entry_id: String in journal[kind]:
		entries.append(get_journal_entry(kind, entry_id))
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["discovered_order"] < b["discovered_order"])
	return entries


func get_journal_entry(kind: String, entry_id: String) -> Dictionary:
	if not journal.has(kind) or not journal[kind].has(entry_id) or not ENTRIES.has(entry_id):
		return {}
	var entry: Dictionary = ENTRIES[entry_id].duplicate(true)
	entry["entry_id"] = entry_id
	entry.merge(journal[kind][entry_id], true)
	entry["location_title"] = get_location_title(entry["location_id"])
	return entry


func validate_content() -> Array[String]:
	return _validate_content_data(LOCATIONS, ENTRIES, START_LOCATION)


func _validate_content_data(locations: Dictionary, entries: Dictionary, start_location: String) -> Array[String]:
	var errors: Array[String] = []
	if not locations.has(start_location):
		errors.append("시작 장소가 존재하지 않음: %s" % start_location)

	for raw_entry_id: Variant in entries:
		if typeof(raw_entry_id) != TYPE_STRING:
			errors.append("journal entry ID가 String이 아님")
			continue
		var entry_id: String = raw_entry_id
		if entry_id.is_empty():
			errors.append("빈 journal entry ID")
			continue
		var entry_value: Variant = entries[entry_id]
		if typeof(entry_value) != TYPE_DICTIONARY:
			errors.append("journal entry가 Dictionary가 아님: %s" % entry_id)
			continue
		var entry: Dictionary = entry_value
		if typeof(entry.get("title")) != TYPE_STRING:
			errors.append("journal title이 String이 아님: %s" % entry_id)
		if typeof(entry.get("body")) != TYPE_STRING:
			errors.append("journal body가 String이 아님: %s" % entry_id)
		if typeof(entry.get("kind")) != TYPE_STRING:
			errors.append("journal kind가 String이 아님: %s" % entry_id)
			continue
		var kind: String = entry["kind"]
		if kind not in JOURNAL_KINDS:
			errors.append("지원하지 않는 journal kind: %s (%s)" % [kind, entry_id])

	for raw_source_id: Variant in locations:
		if typeof(raw_source_id) != TYPE_STRING:
			errors.append("장소 ID가 String이 아님")
			continue
		var source_id: String = raw_source_id
		var location_value: Variant = locations[source_id]
		if typeof(location_value) != TYPE_DICTIONARY:
			errors.append("장소가 Dictionary가 아님: %s" % source_id)
			continue
		var location: Dictionary = location_value
		if typeof(location.get("title")) != TYPE_STRING:
			errors.append("장소 title이 String이 아님: %s" % source_id)
		if typeof(location.get("description")) != TYPE_STRING:
			errors.append("장소 description이 String이 아님: %s" % source_id)
		var color_value: Variant = location.get("color")
		if typeof(color_value) != TYPE_STRING or not Color.html_is_valid(color_value):
			errors.append("장소 color가 유효한 HTML 색상이 아님: %s" % source_id)

		var exits_value: Variant = location.get("exits")
		if typeof(exits_value) != TYPE_ARRAY:
			errors.append("장소 exits가 Array가 아님: %s" % source_id)
		else:
			var seen_exits := {}
			for target_value: Variant in exits_value:
				if typeof(target_value) != TYPE_STRING:
					errors.append("exit 목적지가 String이 아님: %s" % source_id)
					continue
				var target_id: String = target_value
				if not locations.has(target_id):
					errors.append("존재하지 않는 exit: %s -> %s" % [source_id, target_id])
				if seen_exits.has(target_id):
					errors.append("중복 exit: %s -> %s" % [source_id, target_id])
				seen_exits[target_id] = true

		var objects_value: Variant = location.get("objects")
		if typeof(objects_value) != TYPE_ARRAY:
			errors.append("장소 objects가 Array가 아님: %s" % source_id)
			continue

		var seen_objects := {}
		for object_value: Variant in objects_value:
			if typeof(object_value) != TYPE_DICTIONARY:
				errors.append("조사 오브젝트가 Dictionary가 아님: %s" % source_id)
				continue
			var object_definition: Dictionary = object_value
			if typeof(object_definition.get("id")) != TYPE_STRING:
				errors.append("조사 오브젝트 ID가 String이 아님: %s" % source_id)
				continue
			var object_id: String = object_definition["id"]
			if object_id.is_empty():
				errors.append("빈 조사 오브젝트 ID: %s" % source_id)
			elif seen_objects.has(object_id):
				errors.append("중복 조사 오브젝트 ID: %s/%s" % [source_id, object_id])
			seen_objects[object_id] = true
			if typeof(object_definition.get("label")) != TYPE_STRING:
				errors.append("조사 오브젝트 label이 String이 아님: %s/%s" % [source_id, object_id])
			if object_definition.has("feedback") and typeof(object_definition["feedback"]) != TYPE_STRING:
				errors.append("조사 오브젝트 feedback이 String이 아님: %s/%s" % [source_id, object_id])

			if object_definition.has("entry_id"):
				if typeof(object_definition["entry_id"]) != TYPE_STRING:
					errors.append("entry_id가 String이 아님: %s/%s" % [source_id, object_id])
					continue
				var entry_id: String = object_definition["entry_id"]
				if not entries.has(entry_id):
					errors.append("존재하지 않는 entry_id: %s/%s -> %s" % [source_id, object_id, entry_id])

	return errors


func _action_result(ok: bool, feedback: String, new_entry: bool = false, entry: Dictionary = {}) -> Dictionary:
	return {
		"ok": ok,
		"feedback": feedback,
		"new_entry": new_entry,
		"entry": entry
	}
