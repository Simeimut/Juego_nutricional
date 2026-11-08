class_name Interactable
extends Area2D

signal interacted(actor: Node2D)

@export var prompt_text: String = "Usar"
@export var max_distance: float = 135.0


func _ready() -> void:
	add_to_group("interactable")
	monitoring = false
	monitorable = false


func get_prompt() -> String:
	return prompt_text


func can_interact(actor: Node2D) -> bool:
	if not is_visible_in_tree() or actor == null:
		return false
	if get_prompt() == "":
		return false
	return global_position.distance_to(actor.global_position) <= max_distance


func set_highlight(active: bool) -> void:
	modulate = Color(1.0, 1.0, 0.80) if active else Color.WHITE


func interact(actor: Node2D) -> void:
	interacted.emit(actor)
