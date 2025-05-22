extends Node

signal selection_changed(new_selection: SelectableArea)

var current_selection: SelectableArea = null
var new_selection: SelectableArea = null


func _on_selectable_area_selected() -> void:
	#print("got click")
	assert(current_selection != new_selection)
	if current_selection:
		current_selection.deselect()
	current_selection = new_selection
	selection_changed.emit(current_selection)


func _on_selectable_area_deselected() -> void:
	current_selection = null
	selection_changed.emit(current_selection)


func clear_selection() -> void:
	if current_selection:
		current_selection.deselect()
	current_selection = null
	selection_changed.emit(current_selection)
