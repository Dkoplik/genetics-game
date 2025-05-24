class_name SelectableArea extends Area2D

signal selected
signal deselected

var is_selected := false


func _ready() -> void:
	selected.connect(SelectManager._on_selectable_area_selected)
	deselected.connect(SelectManager._on_selectable_area_deselected)
	input_pickable = true


func _input_event(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	#print("got event " + str(event))
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			#print(str(self) + "was clicked")
			toggle_selection()
			viewport.set_input_as_handled()
	elif event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.canceled:
			return
		if touch_event.is_released() and (not touch_event.double_tap):
			#print("touch")
			toggle_selection()
			viewport.set_input_as_handled()


func toggle_selection() -> void:
	if is_selected:
		deselect()
	else:
		select()


func select() -> void:
	#print(str(self) + "selected")
	if is_selected:
		return
	is_selected = true
	SelectManager.new_selection = self
	selected.emit()


func deselect() -> void:
	#print(str(self) + "deselected")
	if not is_selected:
		return
	is_selected = false
	deselected.emit()
