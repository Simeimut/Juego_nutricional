class_name GameHUD
extends CanvasLayer

signal interact_pressed
signal left_changed(pressed: bool)
signal right_changed(pressed: bool)
signal jump_pressed

@export var title_text: String = "Aventura"
@export var show_inventory: bool = true
@export_multiline var info_text: String = ""

@onready var title_label: Label = $Root/TopBar/TopRow/TitleLabel
@onready var inventory_panel: PanelContainer = $Root/InventoryPanel
@onready var inventory_label: Label = $Root/InventoryPanel/InventoryLabel
@onready var info_panel: PanelContainer = $Root/InfoPanel
@onready var info_label: Label = $Root/InfoPanel/InfoLabel
@onready var prompt_panel: PanelContainer = $Root/PromptPanel
@onready var prompt_label: Label = $Root/PromptPanel/PromptLabel
@onready var message_panel: PanelContainer = $Root/MessagePanel
@onready var message_label: Label = $Root/MessagePanel/MessageLabel
@onready var left_button: Button = $Root/TouchControls/LeftButton
@onready var right_button: Button = $Root/TouchControls/RightButton
@onready var jump_button: Button = $Root/TouchControls/JumpButton
@onready var interact_button: Button = $Root/TouchControls/InteractButton

var _message_tween: Tween


func _ready() -> void:
	title_label.text = title_text
	inventory_panel.visible = show_inventory
	message_panel.visible = false
	prompt_panel.visible = false
	set_info(info_text)
	GameState.progress_changed.connect(_refresh_inventory)
	_refresh_inventory()

	$Root/TopBar/TopRow/BackButton.pressed.connect(_on_back_pressed)
	left_button.button_down.connect(func() -> void: left_changed.emit(true))
	left_button.button_up.connect(func() -> void: left_changed.emit(false))
	right_button.button_down.connect(func() -> void: right_changed.emit(true))
	right_button.button_up.connect(func() -> void: right_changed.emit(false))
	jump_button.pressed.connect(func() -> void: jump_pressed.emit())
	interact_button.pressed.connect(func() -> void: interact_pressed.emit())


func set_title(value: String) -> void:
	title_text = value
	if is_node_ready():
		title_label.text = value


func set_prompt(value: String) -> void:
	prompt_label.text = value
	prompt_panel.visible = value != ""


func set_info(value: String) -> void:
	info_text = value
	if not is_node_ready():
		return
	info_label.text = value
	info_panel.visible = value != ""


func show_message(value: String, duration: float = 3.0) -> void:
	if _message_tween != null and _message_tween.is_valid():
		_message_tween.kill()
	message_label.text = value
	message_panel.visible = true
	message_panel.modulate.a = 0.0
	_message_tween = create_tween()
	_message_tween.tween_property(message_panel, "modulate:a", 1.0, 0.16)
	_message_tween.tween_interval(duration)
	_message_tween.tween_property(message_panel, "modulate:a", 0.0, 0.25)
	_message_tween.tween_callback(func() -> void: message_panel.visible = false)


func _refresh_inventory() -> void:
	if inventory_label == null:
		return
	inventory_label.text = "Canasta: %d" % GameState.total_ingredients_collected()


func _on_back_pressed() -> void:
	AudioManager.play_click()
	SceneManager.go("res://scenes/main_menu.tscn")
