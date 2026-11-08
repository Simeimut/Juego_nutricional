class_name InfoPoint
extends Interactable

@export var title: String = ""
@export_multiline var message: String = ""


func get_prompt() -> String:
	return prompt_text
