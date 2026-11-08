class_name KitchenStation
extends Interactable

@export var station_id: String = ""
@export var station_name: String = ""


func _ready() -> void:
	super._ready()
	add_to_group("kitchen_stations")


func get_prompt() -> String:
	if station_id == "table":
		return "Ver receta"
	return "Usar " + station_name
