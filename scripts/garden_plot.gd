class_name GardenPlot
extends Interactable

signal harvested(crop_name: String, crop_id: String)

@export var plot_index: int = 0
@export var crop_id: String = "zanahoria"
@export var crop_name: String = "Zanahoria"
@export var crop_texture: Texture2D

@onready var sprout: Sprite2D = $Sprout
@onready var growing: Sprite2D = $Growing
@onready var leafy: Sprite2D = $Leafy
@onready var crop_icon: Sprite2D = $CropIcon


func _ready() -> void:
	super._ready()
	add_to_group("garden_plots")
	if crop_texture != null:
		crop_icon.texture = crop_texture
	_refresh()


func get_prompt() -> String:
	var plot: Dictionary = GameState.get_plot(plot_index)
	match String(plot.get("state", "empty")):
		"empty":
			return "Preparar tierra"
		"prepared":
			return "Sembrar " + crop_name
		"planted":
			if int(plot.get("water", 0)) >= 3:
				return "Cosechar " + crop_name
			return "Regar " + crop_name
	return "Trabajar la tierra"


func interact(actor: Node2D) -> void:
	var plot: Dictionary = GameState.get_plot(plot_index)
	match String(plot.get("state", "empty")):
		"empty":
			plot["state"] = "prepared"
			GameState.set_plot(plot_index, plot)
			AudioManager.play_pop()
		"prepared":
			plot["state"] = "planted"
			plot["seed"] = crop_id
			plot["water"] = 0
			GameState.set_plot(plot_index, plot)
			AudioManager.play_pop()
		"planted":
			if int(plot.get("water", 0)) >= 3:
				_harvest(plot)
			else:
				plot["water"] = mini(int(plot.get("water", 0)) + 1, 3)
				GameState.set_plot(plot_index, plot)
				AudioManager.play_pop()
	interacted.emit(actor)
	_refresh()


func _harvest(plot: Dictionary) -> void:
	plot["state"] = "empty"
	plot["seed"] = ""
	plot["water"] = 0
	plot["harvests"] = int(plot.get("harvests", 0)) + 1
	GameState.set_plot(plot_index, plot)
	GameState.add_ingredient(crop_id, 1)
	AudioManager.play_success()
	harvested.emit(crop_name, crop_id)


func _refresh() -> void:
	var plot: Dictionary = GameState.get_plot(plot_index)
	var state := String(plot.get("state", "empty"))
	var water := int(plot.get("water", 0))
	var planted := state == "planted"
	sprout.visible = planted and water < 2
	growing.visible = planted and water == 2
	leafy.visible = planted and water >= 3
	crop_icon.visible = planted and water >= 3
