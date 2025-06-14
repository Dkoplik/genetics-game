class_name EffectSelector extends Control

signal effect_selected(effect: EffectData)
signal effect_deselected

@export var effects: EffectsArray = preload("res://config/effects-array-params.tres")

var _cur_selection: int = -1

@onready var item_list := $ItemList as ItemList


func _ready() -> void:
	item_list.max_columns = effects.data.size()
	for data: EffectData in effects.data:
		item_list.add_item(data.name)


func _on_item_list_item_selected(index: int) -> void:
	if _cur_selection == index:
		item_list.deselect(index)
		effect_deselected.emit()
		_cur_selection = -1
		return
	_cur_selection = index
	effect_selected.emit(effects.data.get(index) as EffectData)
