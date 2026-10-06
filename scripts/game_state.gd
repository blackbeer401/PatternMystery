class_name PrototypeGameState
extends RefCounted

const PLAYER_NAME := "Player 1"
const START_LOCATION := "central_hall"
const JOURNAL_KINDS := ["material", "witness"]

const ENTRIES := {
	"annex_plan": {
		"kind": "material",
		"title": "과거 별관 시설도면",
		"body": "[학교 보관 시설도면 / 별관 평면 발췌]\n\n별관 대기실을 지나 복도 끝에 이르면, 외벽 쪽으로 ‘기계실’, 그 안쪽으로 ‘설비관리 공간’이 표시되어 있다. 복도와 기계실 사이에는 설비 접근구 표시가 있다. 두 공간은 별도의 구획으로 그려져 있다.\n\n대기실 창과 복도 끝 외벽의 위치를 기준으로 도면의 방향을 읽을 수 있다. 접근구 너머 구획의 경계는 표시되어 있지만, 이 도면에는 이후 벽체 변경 이력이 기재되어 있지 않다.\n\n도면은 당시 시설의 배치를 나타낸다. 현재 구조를 실측한 자료는 아니다."
	},
	"closure_record": {
		"kind": "material",
		"title": "시설 사용 종료·폐쇄 기록",
		"body": "[시설관리대장 / 별관 항목]\n\n대상: 별관 기계실 및 설비관리 공간\n처리: 사용 종료 및 폐쇄\n처리 시점: 2003년 이전\n\n해당 시설은 공식 사용 대상에서 제외하고 폐쇄 처리함.\n\n보관된 이 항목에는 행정상 처리 상태가 기재되어 있다. 공간 철거 여부, 접근구 마감 방식 및 시공 상세는 기재되어 있지 않다. 첨부된 과거 시설도면의 공간 명칭은 그대로 남아 있다."
	},
	"missing_case": {
		"kind": "material",
		"title": "2003년 박재영 실종사건 자료",
		"body": "[학교 보관 사건 자료 / 2003년]\n\n성명: 박재영\n당시 나이: 17세\n상태: 실종\n\n박재영은 학교 별관 인근에서 마지막으로 확인된 뒤 실종되었다. 학교는 교내 수색 관련 기록을 사건 자료와 함께 보관했다.\n\n이 자료의 ‘별관 인근’ 표기는 마지막 확인 위치의 범주이다. 별관 내부의 특정 방이나 설비공간을 마지막 확인 지점으로 특정하고 있지는 않다."
	},
	"search_record": {
		"kind": "material",
		"title": "2003년 교내 수색 기록",
		"body": "[박재영 실종 관련 교내 수색 기록 / 2003년]\n\n구역별 확인 사항\n\n별관 기계실 및 설비구역 확인 완료\n\n위 문구는 구역별 확인 사항에 남아 있는 원문이다. 이 보관본에는 해당 구역의 진입 지점, 내부 확인 동선 또는 확인 범위를 표시한 도면이 첨부되어 있지 않다.\n\n‘확인 완료’의 세부 범위는 이 기록만으로 특정할 수 없다. 당시 접근 가능하고 안전하게 확인할 수 있었던 범위를 가리켰을 가능성도 남아 있다."
	},
	"hidden_access": {
		"kind": "witness",
		"title": "벽 뒤에서 드러난 설비 접근구",
		"body": "[2026년 현장 관찰]\n\n별관 대기실을 지나 복도 끝 외벽 쪽에 벽체 철거 구간이 있다. 철거된 벽 마감 뒤로 오래된 설비 접근구의 테두리가 드러나 있다. 철거 전에는 복도에서 이 테두리를 볼 수 없었다.\n\n접근구와 그 앞의 벽 마감은 서로 다른 층으로 남아 있다. 현장에서 보이는 흔적만으로 벽 마감의 시공 시점을 정할 수는 없다."
	},
	"remaining_space": {
		"kind": "witness",
		"title": "접근구 너머에 남아 있는 설비공간",
		"body": "[2026년 현장 관찰 / 접근구 바깥에서 확인]\n\n접근구 너머에는 바닥과 벽으로 구획된 빈 공간이 남아 있다. 입구 전체를 채우는 막음 구조는 보이지 않는다. 보이는 공간의 안쪽에는 구획 벽이 있으며, 그 뒤는 이 위치에서 시야에 들어오지 않는다.\n\n공간 자체가 완전히 제거된 상태는 아니다. 다만 접근구 바깥에서 보이는 부분을 관찰했을 뿐, 내부 전체의 범위나 다른 구획과의 연결 상태까지 확인한 것은 아니다."
	}
}

const LOCATIONS := {
	"central_hall": {
		"title": "중앙복도",
		"description": "2026년. 별관 정비 전 조사를 위해 학교 보관 자료와 현장이 개방되어 있다. 복도에서 교무실, 시설자료실, 별관 대기실로 갈 수 있다.",
		"color": "#182029",
		"objects": [
			{"id": "notice_board", "label": "현장 조사 안내문", "feedback": "2026년 별관 리모델링 또는 철거 전 조사. 오래된 벽체 일부를 철거하는 중이며, 조사자는 개방된 복도에서 현장을 관찰할 것. 접근구 내부는 안전 확인 전까지 진입하지 말 것."},
			{"id": "archive_guide", "label": "자료 배치 안내", "feedback": "학교 보관 사건·수색 기록: 교무실. 과거 시설도면·시설관리대장: 시설자료실. 현장 작업 기록: 별관 대기실."}
		],
		"exits": ["faculty_room", "facility_archive", "annex_waiting_room"]
	},
	"faculty_room": {
		"title": "교무실",
		"description": "보관 자료철 두 권이 책상 위에 펼쳐져 있다. 사건 자료와 교내 수색 기록은 각각 다른 표지를 갖고 있다.",
		"color": "#29231d",
		"objects": [
			{"id": "case_file", "label": "실종사건 자료철", "feedback": "2003년 박재영 실종사건 자료를 읽었다.", "entry_id": "missing_case"},
			{"id": "search_file", "label": "교내 수색 기록철", "feedback": "구역별 확인 사항이 적힌 수색 기록을 읽었다.", "entry_id": "search_record"}
		],
		"exits": ["central_hall"]
	},
	"facility_archive": {
		"title": "시설자료실",
		"description": "과거 별관 도면과 시설관리대장이 나란히 놓여 있다. 도면에는 복도와 방의 경계가, 대장에는 시설 처리 상태가 기록되어 있다.",
		"color": "#151f1d",
		"objects": [
			{"id": "plan_drawer", "label": "과거 별관 시설도면", "feedback": "별관 평면도에 기계실과 설비관리 공간이 표시되어 있다.", "entry_id": "annex_plan"},
			{"id": "facility_register", "label": "시설관리대장", "feedback": "해당 시설의 사용 종료·폐쇄 항목을 읽었다.", "entry_id": "closure_record"}
		],
		"exits": ["central_hall"]
	},
	"annex_waiting_room": {
		"title": "별관 대기실",
		"description": "현장 작업 기록과 위치 약도가 접이식 탁자에 놓여 있다. 창 옆 복도는 벽체 철거 구간으로 이어진다.",
		"color": "#211c27",
		"objects": [
			{"id": "work_log", "label": "벽체 철거 작업 기록", "feedback": "2026년 작업 기록: 복도 끝의 오래된 벽 마감을 철거하던 중 뒤쪽에서 설비 접근구 테두리를 발견함. 작업은 접근구 내부에 진입하지 않고 현 상태에서 중단함."},
			{"id": "site_map", "label": "현장 위치 약도", "feedback": "현재 위치는 별관 대기실. 창을 왼쪽에 두고 복도를 따라가면 끝의 외벽 쪽에 철거 구간이 있다. 약도는 현재 복도와 작업 구간만 표시한다."}
		],
		"exits": ["central_hall", "annex_wall"]
	},
	"annex_wall": {
		"title": "별관 벽체 철거 구간",
		"description": "복도 끝 외벽 쪽의 마감이 일부 걷혀 있다. 드러난 접근구 바깥에서 벽체와 그 너머를 관찰할 수 있다. 내부 진입은 제한되어 있다.",
		"color": "#242329",
		"objects": [
			{"id": "access_frame", "label": "벽체와 설비 접근구 관찰", "feedback": "철거된 마감 뒤에 오래된 접근구 테두리가 남아 있다.", "entry_id": "hidden_access"},
			{"id": "space_view", "label": "접근구 너머 관찰", "feedback": "구획된 공간이 남아 있다. 안쪽 구획 벽 뒤는 여기서 보이지 않는다.", "entry_id": "remaining_space"}
		],
		"exits": ["annex_waiting_room"]
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
