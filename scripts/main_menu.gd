extends Control

const BOY_FRAMES := preload("res://assets/characters/boy_frames.tres")
const GIRL_FRAMES := preload("res://assets/characters/girl_frames.tres")

const SCENES := {
	"GardenButton": "res://scenes/garden.tscn",
	"FoodButton": "res://scenes/food_world.tscn",
	"KitchenButton": "res://scenes/healthy_kitchen.tscn"
}

@onready var character_preview: AnimatedSprite2D = $CharacterPreview
@onready var title_label: Label = $Content/TitleLabel


func _ready() -> void:
	var character_id := GameState.selected_character()
	character_preview.sprite_frames = GIRL_FRAMES if character_id == "nina" else BOY_FRAMES
	character_preview.play("idle")

	for button_name in SCENES.keys():
		var button := find_child(button_name, true, false)
		if button is Button:
			_connect_button(button, String(SCENES[button_name]))
	_animate_title()
	entrance()


func _connect_button(button: Button, path: String) -> void:
	button.pressed.connect(func() -> void:
		AudioManager.play_click()
		SceneManager.go(path)
	)
	button.mouse_entered.connect(_animate_button.bind(button, Vector2(1.045, 1.045)))
	button.mouse_exited.connect(_animate_button.bind(button, Vector2.ONE))
	button.button_down.connect(_animate_button.bind(button, Vector2(0.98, 0.98)))
	button.button_up.connect(_animate_button.bind(button, Vector2.ONE))


func _animate_button(button: Button, target: Vector2) -> void:
	button.pivot_offset = button.size * 0.5
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target, 0.16)


func _animate_title() -> void:
	title_label.pivot_offset = title_label.size * 0.5
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(title_label, "scale", Vector2(1.018, 1.018), 1.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(title_label, "scale", Vector2.ONE, 1.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func entrance() -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.35)
