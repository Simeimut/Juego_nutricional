class_name AdventureWorld
extends Node2D

@export_multiline var intro_message: String = ""

@onready var player: PlayerCharacter = $Player
@onready var hud: GameHUD = $HUD

var _nearby: Interactable


func _ready() -> void:
	player.interact_requested.connect(_on_interact)
	hud.interact_pressed.connect(_on_interact)
	hud.left_changed.connect(player.set_touch_left)
	hud.right_changed.connect(player.set_touch_right)
	hud.jump_pressed.connect(player.request_jump)
	if intro_message != "":
		get_tree().create_timer(0.55).timeout.connect(func() -> void: hud.show_message(intro_message, 4.5))


func _process(_delta: float) -> void:
	var best: Interactable = null
	var best_distance := 9999.0
	for node in get_tree().get_nodes_in_group("interactable"):
		if node is Interactable and node.can_interact(player):
			var distance: float = (node as Node2D).global_position.distance_to(player.global_position)
			if distance < best_distance:
				best_distance = distance
				best = node

	if best != _nearby:
		if _nearby != null and is_instance_valid(_nearby):
			_nearby.set_highlight(false)
		_nearby = best
		if _nearby != null:
			_nearby.set_highlight(true)
			hud.set_prompt(_nearby.get_prompt())
		else:
			hud.set_prompt("")
	elif _nearby != null and is_instance_valid(_nearby):
		hud.set_prompt(_nearby.get_prompt())


func _on_interact() -> void:
	if _nearby == null or not is_instance_valid(_nearby):
		return
	if _nearby is InfoPoint:
		var info := _nearby as InfoPoint
		AudioManager.play_click()
		hud.show_message(info.message, 4.0)
	else:
		_nearby.interact(player)
