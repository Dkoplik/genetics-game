extends Node

signal selection_changed(new_selection: SelectableArea)

var current_selection: SelectableArea = null:
	set = set_current_selection
var new_selection: SelectableArea = null


func _on_selectable_area_selected() -> void:
	assert(current_selection != new_selection)
	if current_selection:
		current_selection.deselect()
	current_selection = new_selection


func _on_selectable_area_deselected() -> void:
	current_selection = null


func set_current_selection(selection: SelectableArea) -> void:
	current_selection = selection
	selection_changed.emit(current_selection)
