extends CanvasLayer

var _fade: ColorRect
var _busy: bool = false


func _ready() -> void:
	layer = 128
	process_mode = Node.PROCESS_MODE_ALWAYS

	_fade = ColorRect.new()
	_fade.color = Color(1.0, 0.972549, 0.913725, 0.0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade)
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func go(path: String) -> void:
	if _busy:
		return
	_busy = true
	var fade_in := create_tween()
	fade_in.tween_property(_fade, "color", Color(1.0, 0.972549, 0.913725, 1.0), 0.22)
	await fade_in.finished
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	var fade_out := create_tween()
	fade_out.tween_property(_fade, "color", Color(1.0, 0.972549, 0.913725, 0.0), 0.28)
	await fade_out.finished
	_busy = false
