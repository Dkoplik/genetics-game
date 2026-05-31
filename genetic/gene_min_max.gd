@tool
class_name GeneMinMax
extends Resource
## Минимальное и максимальное значение для вещественного параметра.

@export var min_value: float = -1e10:
	set(value):
		min_value = min(value, max_value)

@export var max_value: float = 1e10:
	set(value):
		max_value = max(min_value, value)


func _init(p_min: float = 1e-10, p_max: float = 1e10) -> void:
	min_value = p_min
	max_value = p_max


func value_range() -> float:
	return max_value - min_value
