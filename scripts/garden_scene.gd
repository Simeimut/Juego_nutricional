extends AdventureWorld


func _ready() -> void:
	super._ready()
	for node in get_tree().get_nodes_in_group("garden_plots"):
		if node is GardenPlot:
			node.harvested.connect(_on_harvested)


func _on_harvested(crop_name: String, _crop_id: String) -> void:
	hud.show_message("Cosechaste %s. Ya está en tu canasta." % crop_name, 3.0)
