class_name PlayerCharacter
extends CharacterBody2D

signal interact_requested

const BOY_FRAMES := preload("res://assets/characters/boy_frames.tres")
const GIRL_FRAMES := preload("res://assets/characters/girl_frames.tres")

@export var speed: float = 285.0
@export var jump_velocity: float = -650.0
@export var gravity: float = 1650.0
@export var min_x: float = 55.0
@export var max_x: float = 1225.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _spawn_position: Vector2
var _touch_left: bool = false
var _touch_right: bool = false
var _jump_requested: bool = false


func _ready() -> void:
	_spawn_position = global_position
	var character_id := GameState.selected_character()
	sprite.sprite_frames = GIRL_FRAMES if character_id == "nina" else BOY_FRAMES
	sprite.play("idle")


func _physics_process(delta: float) -> void:
	var direction := 0.0
	if _left_pressed():
		direction -= 1.0
	if _right_pressed():
		direction += 1.0
	if _touch_left:
		direction -= 1.0
	if _touch_right:
		direction += 1.0
	direction = clampf(direction, -1.0, 1.0)

	velocity.x = direction * speed
	if absf(direction) > 0.05:
		sprite.flip_h = direction < 0.0

	var wants_jump := Input.is_action_just_pressed("ui_accept") or _jump_requested
	_jump_requested = false
	if wants_jump and is_on_floor():
		velocity.y = jump_velocity
		AudioManager.play_pop()

	velocity.y = minf(velocity.y + gravity * delta, 1250.0)
	move_and_slide()
	global_position.x = clampf(global_position.x, min_x, max_x)
	if global_position.y > 790.0:
		global_position = _spawn_position
		velocity = Vector2.ZERO

	if not is_on_floor():
		_play_animation("jump")
	elif absf(velocity.x) > 18.0:
		_play_animation("walk")
	else:
		_play_animation("idle")


func _play_animation(animation_name: String) -> void:
	if sprite.animation == animation_name:
		if animation_name != "jump" and not sprite.is_playing():
			sprite.play(animation_name)
		return
	sprite.play(animation_name)


func _left_pressed() -> bool:
	return Input.is_action_pressed("ui_left") or Input.is_physical_key_pressed(KEY_A)


func _right_pressed() -> bool:
	return Input.is_action_pressed("ui_right") or Input.is_physical_key_pressed(KEY_D)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_E or event.keycode == KEY_E:
			request_interact()
			get_viewport().set_input_as_handled()


func set_touch_left(pressed: bool) -> void:
	_touch_left = pressed


func set_touch_right(pressed: bool) -> void:
	_touch_right = pressed


func request_jump() -> void:
	_jump_requested = true


func request_interact() -> void:
	interact_requested.emit()
