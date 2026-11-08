extends Control

@onready var boy_card: Button = $Content/Cards/BoyCard
@onready var girl_card: Button = $Content/Cards/GirlCard
@onready var boy_badge: PanelContainer = $Content/Cards/BoyCard/SelectedBadge
@onready var girl_badge: PanelContainer = $Content/Cards/GirlCard/SelectedBadge
@onready var boy_sprite: AnimatedSprite2D = $Content/Cards/BoyCard/Preview
@onready var girl_sprite: AnimatedSprite2D = $Content/Cards/GirlCard/Preview
@onready var confirmation: Label = $Content/ConfirmationLabel
@onready var continue_button: Button = $Content/ContinueButton
@onready var cancel_button: Button = $Content/CancelButton

var _selected: String = ""
var _original_character: String = ""
var _return_path: String = "res://scenes/main_menu.tscn"


func _ready() -> void:
	_original_character = GameState.selected_character()

	boy_card.pressed.connect(_select_character.bind("nino", true))
	girl_card.pressed.connect(_select_character.bind("nina", true))
	continue_button.pressed.connect(_on_continue_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)

	boy_sprite.play("idle")
	girl_sprite.play("idle")
	boy_badge.visible = false
	girl_badge.visible = false
	cancel_button.visible = _original_character != ""

	if _original_character != "":
		_select_character(_original_character, false)
	else:
		continue_button.disabled = true
		confirmation.text = "Elige un personaje para comenzar."

	content_entrance()


func _select_character(character_id: String, play_sound: bool) -> void:
	_selected = character_id
	GameState.set_selected_character(character_id)
	var boy_selected := character_id == "nino"
	boy_badge.visible = boy_selected
	girl_badge.visible = not boy_selected
	boy_card.modulate = Color.WHITE if boy_selected else Color(0.88, 0.88, 0.88)
	girl_card.modulate = Color.WHITE if not boy_selected else Color(0.88, 0.88, 0.88)
	_scale_card(boy_card, Vector2(1.035, 1.035) if boy_selected else Vector2.ONE)
	_scale_card(girl_card, Vector2(1.035, 1.035) if not boy_selected else Vector2.ONE)
	confirmation.text = "Este será tu compañero de aventura."
	continue_button.disabled = false
	if play_sound:
		AudioManager.play_pop()


func _scale_card(card: Button, target: Vector2) -> void:
	card.pivot_offset = card.size * 0.5
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "scale", target, 0.2)


func _on_continue_pressed() -> void:
	if _selected == "":
		return
	AudioManager.play_click()
	GameState.set_selected_character(_selected)
	SceneManager.go(_return_path)


func _on_cancel_pressed() -> void:
	AudioManager.play_click()
	if _original_character != "":
		GameState.set_selected_character(_original_character)
	SceneManager.go(_return_path)


func content_entrance() -> void:
	var content: Control = $Content
	content.modulate.a = 0.0
	content.scale = Vector2(0.96, 0.96)
	content.pivot_offset = content.size * 0.5
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(content, "modulate:a", 1.0, 0.35)
	tween.tween_property(content, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
