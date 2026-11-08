extends Node

signal progress_changed
signal settings_changed

const SAVE_PATH := "user://aventura_nutricional_save.json"
const GARDEN_PLOTS := 6
const KITCHEN_RECIPE := "ensalada_colorida"

var data: Dictionary = {}


func _ready() -> void:
	data = _default_data()
	load_game()
	_ensure_integrity()


func _default_plot() -> Dictionary:
	return {
		"state": "empty",
		"seed": "",
		"water": 0,
		"harvests": 0
	}


func _default_data() -> Dictionary:
	var plots: Array = []
	for i in GARDEN_PLOTS:
		plots.append(_default_plot())
	return {
		"selected_character": "",
		"inventory": {},
		"collected_ingredients": {},
		"garden": {"plots": plots},
		"cooked_recipes": {},
		"settings": {"music": true, "sfx": true}
	}


func _merge_dict(base: Dictionary, incoming: Dictionary) -> Dictionary:
	var result: Dictionary = base.duplicate(true)
	for key in incoming.keys():
		if result.has(key) and typeof(result[key]) == TYPE_DICTIONARY and typeof(incoming[key]) == TYPE_DICTIONARY:
			result[key] = _merge_dict(result[key], incoming[key])
		else:
			result[key] = incoming[key]
	return result


func _ensure_integrity() -> void:
	var valid_keys := _default_data().keys()
	for key in data.keys():
		if not valid_keys.has(key):
			data.erase(key)
	for key in valid_keys:
		if not data.has(key):
			data[key] = _default_data()[key]

	var character_id := String(data.get("selected_character", ""))
	if character_id != "nino" and character_id != "nina":
		character_id = ""
	data["selected_character"] = character_id

	if typeof(data.get("inventory")) != TYPE_DICTIONARY:
		data["inventory"] = {}
	var clean_inventory: Dictionary = {}
	for key in data["inventory"].keys():
		var amount := int(data["inventory"][key])
		if amount > 0:
			clean_inventory[String(key)] = amount
	data["inventory"] = clean_inventory

	if typeof(data.get("collected_ingredients")) != TYPE_DICTIONARY:
		data["collected_ingredients"] = {}
	var clean_pickups: Dictionary = {}
	for key in data["collected_ingredients"].keys():
		clean_pickups[String(key)] = String(data["collected_ingredients"][key])
	data["collected_ingredients"] = clean_pickups

	if typeof(data.get("cooked_recipes")) != TYPE_DICTIONARY:
		data["cooked_recipes"] = {}

	var settings: Dictionary = data.get("settings", {})
	if typeof(settings) != TYPE_DICTIONARY:
		settings = {}
	settings["music"] = bool(settings.get("music", true))
	settings["sfx"] = bool(settings.get("sfx", true))
	data["settings"] = settings

	if typeof(data.get("garden")) != TYPE_DICTIONARY:
		data["garden"] = {"plots": []}
	var plots_raw: Variant = data["garden"].get("plots", [])
	var plots: Array = plots_raw if typeof(plots_raw) == TYPE_ARRAY else []
	while plots.size() < GARDEN_PLOTS:
		plots.append(_default_plot())
	while plots.size() > GARDEN_PLOTS:
		plots.pop_back()
	for i in plots.size():
		var raw: Variant = plots[i]
		var plot: Dictionary = raw if typeof(raw) == TYPE_DICTIONARY else {}
		var state := String(plot.get("state", "empty"))
		if state != "empty" and state != "prepared" and state != "planted":
			state = "empty"
		plots[i] = {
			"state": state,
			"seed": String(plot.get("seed", "")),
			"water": clampi(int(plot.get("water", 0)), 0, 3),
			"harvests": maxi(int(plot.get("harvests", 0)), 0)
		}
	data["garden"]["plots"] = plots


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) == TYPE_DICTIONARY:
		data = _merge_dict(_default_data(), parsed)


func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func selected_character() -> String:
	return String(data.get("selected_character", ""))


func has_selected_character() -> bool:
	var character_id := selected_character()
	return character_id == "nino" or character_id == "nina"


func set_selected_character(character_id: String) -> void:
	if character_id != "nino" and character_id != "nina":
		return
	if selected_character() == character_id:
		return
	data["selected_character"] = character_id
	save_game()
	progress_changed.emit()


func ingredient_count(ingredient_id: String) -> int:
	return int(data["inventory"].get(ingredient_id, 0))


func total_ingredients_collected() -> int:
	var total := 0
	for value in data["inventory"].values():
		total += int(value)
	return total


func has_collected_pickup(pickup_id: String) -> bool:
	return data["collected_ingredients"].has(pickup_id)


func collect_ingredient(ingredient_id: String, pickup_id: String) -> bool:
	if ingredient_id == "" or pickup_id == "":
		return false
	if data["collected_ingredients"].has(pickup_id):
		return false
	data["collected_ingredients"][pickup_id] = ingredient_id
	data["inventory"][ingredient_id] = int(data["inventory"].get(ingredient_id, 0)) + 1
	save_game()
	progress_changed.emit()
	return true


func add_ingredient(ingredient_id: String, amount: int = 1) -> void:
	if ingredient_id == "" or amount <= 0:
		return
	data["inventory"][ingredient_id] = int(data["inventory"].get(ingredient_id, 0)) + amount
	save_game()
	progress_changed.emit()


func use_ingredients(requirements: Dictionary) -> bool:
	for ingredient_id in requirements.keys():
		if ingredient_count(String(ingredient_id)) < int(requirements[ingredient_id]):
			return false
	for ingredient_id in requirements.keys():
		var remaining := ingredient_count(String(ingredient_id)) - int(requirements[ingredient_id])
		if remaining <= 0:
			data["inventory"].erase(String(ingredient_id))
		else:
			data["inventory"][String(ingredient_id)] = remaining
	save_game()
	progress_changed.emit()
	return true


func recipe_cooked(recipe_id: String) -> bool:
	return data["cooked_recipes"].has(recipe_id)


func mark_recipe_cooked(recipe_id: String) -> void:
	data["cooked_recipes"][recipe_id] = true
	save_game()
	progress_changed.emit()


func music_enabled() -> bool:
	return bool(data.get("settings", {}).get("music", true))


func sfx_enabled() -> bool:
	return bool(data.get("settings", {}).get("sfx", true))


func set_music_enabled(value: bool) -> void:
	data["settings"]["music"] = value
	save_game()
	settings_changed.emit()


func set_sfx_enabled(value: bool) -> void:
	data["settings"]["sfx"] = value
	save_game()
	settings_changed.emit()


func get_plot(index: int) -> Dictionary:
	var plots_raw: Variant = data["garden"].get("plots", [])
	if typeof(plots_raw) != TYPE_ARRAY:
		return _default_plot()
	var plots: Array = plots_raw
	if index < 0 or index >= plots.size():
		return _default_plot()
	var plot: Variant = plots[index]
	return plot if typeof(plot) == TYPE_DICTIONARY else _default_plot()


func set_plot(index: int, plot: Dictionary) -> void:
	var plots_raw: Variant = data["garden"].get("plots", [])
	if typeof(plots_raw) != TYPE_ARRAY:
		return
	var plots: Array = plots_raw
	if index < 0 or index >= plots.size():
		return
	plots[index] = plot
	save_game()
	progress_changed.emit()


func harvest_count() -> int:
	var total := 0
	var plots_raw: Variant = data["garden"].get("plots", [])
	if typeof(plots_raw) != TYPE_ARRAY:
		return 0
	var plots: Array = plots_raw
	for plot in plots:
		if typeof(plot) == TYPE_DICTIONARY:
			total += int(plot.get("harvests", 0))
	return total
