extends Node

var current_selection: SelectableArea = null
var new_selection: SelectableArea = null


func _on_selectable_area_selected() -> void:
	assert(current_selection != new_selection)
	if current_selection:
		current_selection.deselect()
	current_selection = new_selection


func _on_selectable_area_deselected() -> void:
	current_selection = null
