extends Node

@export var start_population_size: int = 4

var _effect_scene: PackedScene = preload("res://local-effect/local-effect.tscn")
var _cur_effect: EffectData = null

@onready var population := $Population as Population
@onready var info_panel := $"VBoxContainer/Info-panel" as InfoPanel
@onready var _effects_folder := $LocalEffects as Node
@onready var _eow_timer := $"VBoxContainer/Eow-timer" as EOWTimer


func _ready() -> void:
	_eow_timer.start()
	_eow_timer.started_eow.connect(_start_end_of_world)
	SelectManager.selection_changed.connect(_on_selection_changed)
	for i in range(start_population_size):
		population.create_random_organism()


func _on_selection_changed(selection: SelectableArea) -> void:
	if selection == null:
		info_panel.clear()
		return
	#print("show info")
	var organism := selection.get_parent().get_parent() as Organism
	info_panel.target_organism = organism


func _unhandled_input(event: InputEvent) -> void:
	# отменить выделение организма
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			SelectManager.clear_selection()
	elif event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.canceled:
			return
		if touch_event.is_released() and (not touch_event.double_tap):
			SelectManager.clear_selection()

	# поставить эффект
	if not _cur_effect:
		return
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			var effect := _effect_scene.instantiate() as LocalEffect
			effect.data = _cur_effect
			effect.position = mouse_event.position
			_effects_folder.add_child(effect)
			get_viewport().set_input_as_handled()


func _on_effect_selector_effect_selected(effect: EffectData) -> void:
	_cur_effect = effect


func _on_effect_selector_effect_deselected() -> void:
	_cur_effect = null


func _start_end_of_world() -> void:
	population.add_global_summand(_eow_timer.params.function, _eow_timer.params.variables)
