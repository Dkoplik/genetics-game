class_name EffectSelector extends Control

signal effect_selected(effect: EffectData)
signal effect_deselected

@export var effects: Array[EffectData]

var _cur_selection: int = -1

@onready var item_list := $ItemList as ItemList


func _ready() -> void:
	item_list.max_columns = effects.size()
	for data:EffectData in effects:
		item_list.add_item(data.name)


func _on_item_list_item_selected(index: int) -> void:
	if _cur_selection == index:
		item_list.deselect(index)
		effect_deselected.emit()
		return
	_cur_selection = index
	effect_selected.emit(effects.get(index))
