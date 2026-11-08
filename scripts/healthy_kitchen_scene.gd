extends AdventureWorld

const RECIPE_ID := "ensalada_colorida"
const REQUIRED := {
	"lechuga": 1,
	"tomate": 1,
	"zanahoria": 1,
	"maiz": 1
}
const INGREDIENT_NAMES := {
	"lechuga": "lechuga",
	"tomate": "tomate",
	"zanahoria": "zanahoria",
	"maiz": "maíz"
}


func _ready() -> void:
	super._ready()
	for node in get_tree().get_nodes_in_group("kitchen_stations"):
		if node is KitchenStation:
			node.interacted.connect(_on_station_interacted.bind(node))
	GameState.progress_changed.connect(_update_info)
	_update_info()


func _on_station_interacted(_actor: Node2D, station: KitchenStation) -> void:
	match station.station_id:
		"fridge":
			_take_from_fridge()
		"sink":
			AudioManager.play_pop()
			hud.show_message("El fregadero está listo. Lava los ingredientes antes de cortarlos.", 3.2)
		"table":
			AudioManager.play_click()
			hud.show_message("Receta: ensalada colorida. Necesitas lechuga, tomate, zanahoria y maíz.", 4.0)
		"board":
			AudioManager.play_pop()
			hud.show_message("La tabla y el cuchillo están listos para preparar la ensalada.", 3.0)
		"stove":
			_cook_recipe()


func _take_from_fridge() -> void:
	for ingredient_id in REQUIRED.keys():
		if GameState.ingredient_count(String(ingredient_id)) < int(REQUIRED[ingredient_id]):
			GameState.add_ingredient(String(ingredient_id), 1)
			AudioManager.play_correct()
			hud.show_message("Tomaste %s del refrigerador." % INGREDIENT_NAMES[ingredient_id], 2.4)
			return
	AudioManager.play_click()
	hud.show_message("Ya tienes todos los ingredientes de la receta.", 2.8)


func _cook_recipe() -> void:
	if GameState.recipe_cooked(RECIPE_ID):
		AudioManager.play_click()
		hud.show_message("La ensalada colorida ya está preparada. ¡Buen trabajo!", 3.2)
		return
	var missing := _missing_ingredients()
	if not missing.is_empty():
		AudioManager.play_wrong()
		hud.show_message("Faltan ingredientes: %s." % ", ".join(PackedStringArray(missing)), 3.6)
		return
	if GameState.use_ingredients(REQUIRED):
		GameState.mark_recipe_cooked(RECIPE_ID)
		AudioManager.play_success()
		hud.show_message("Preparaste una ensalada colorida. ¡Receta completada!", 4.0)
		_update_info()


func _missing_ingredients() -> Array[String]:
	var missing: Array[String] = []
	for ingredient_id in REQUIRED.keys():
		if GameState.ingredient_count(String(ingredient_id)) < int(REQUIRED[ingredient_id]):
			missing.append(String(INGREDIENT_NAMES[ingredient_id]))
	return missing


func _update_info() -> void:
	var text := "Receta: ensalada colorida\nLechuga, tomate, zanahoria y maíz"
	if GameState.recipe_cooked(RECIPE_ID):
		text += "\nReceta completada"
	hud.set_info(text)
