class_name SelectableArea extends Area2D

signal selected
signal deselected

var is_selected := false


func _ready() -> void:
	selected.connect(SelectManager._on_selectable_area_selected)
	deselected.connect(SelectManager._on_selectable_area_deselected)
	input_pickable = true


func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			toggle_selection()
			viewport.set_input_as_handled()
			#print(str(self) + "was clicked")
	elif event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			toggle_selection()
			get_viewport().set_input_as_handled()


func toggle_selection() -> void:
	if is_selected:
		deselect()
	else:
		select()


func select() -> void:
	if is_selected:
		return
	is_selected = true
	SelectManager.new_selection = self
	selected.emit()
	#print(str(self) + "selected")


func deselect() -> void:
	if not is_selected:
		return
	is_selected = false
	deselected.emit()
	#print(str(self) + "deselected")
