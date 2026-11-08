extends AdventureWorld


func _ready() -> void:
	super._ready()
	for node in get_tree().get_nodes_in_group("ingredient_collectibles"):
		if node is IngredientCollectible:
			node.collected.connect(_on_collected)


func _on_collected(display_name: String) -> void:
	hud.show_message("Guardaste %s en tu canasta." % display_name, 2.6)
