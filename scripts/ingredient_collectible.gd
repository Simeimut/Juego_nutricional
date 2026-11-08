class_name IngredientCollectible
extends Interactable

signal collected(display_name: String)

@export var ingredient_id: String = ""
@export var pickup_id: String = ""
@export var display_name: String = ""
@export var icon_texture: Texture2D

@onready var icon_sprite: Sprite2D = $Icon

var _base_y: float = 0.0
var _time: float = 0.0


func _ready() -> void:
	super._ready()
	add_to_group("ingredient_collectibles")
	if icon_texture != null:
		icon_sprite.texture = icon_texture
	_base_y = position.y
	_time = randf() * TAU
	if pickup_id != "" and GameState.has_collected_pickup(pickup_id):
		visible = false
		_remove_from_world()


func _process(delta: float) -> void:
	if not visible:
		return
	_time += delta
	position.y = _base_y + sin(_time * 2.6) * 4.0


func get_prompt() -> String:
	return "Recoger " + display_name


func interact(_actor: Node2D) -> void:
	if not visible:
		return
	if not GameState.collect_ingredient(ingredient_id, pickup_id):
		_remove_from_world()
		return
	AudioManager.play_correct()
	collected.emit(display_name)
	_remove_from_world()
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(0.2, 0.2), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.18)
	tween.tween_callback(hide)


func _remove_from_world() -> void:
	remove_from_group("interactable")
	monitoring = false
	monitorable = false
	set_process(false)
