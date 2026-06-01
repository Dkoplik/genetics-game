class_name Gene
extends Resource
## Составляющая генома в виде связки параметра с идентификаторами.
##
## Структура состоит из самого параметра [member value] и дополнительной
## информации по подобию label'ов из messy GA.

## К какому типу структуры (органа организма) относится этот ген?
## Гены одного типа либо полностью присутствуют, либо полностью отсутствуют.
@export var type: StringName

## Название параметра в пределах указанного типа.
## Например, параметр может отвечать за позицию.
@export var name: StringName

## Индекс параметра в геноме в пределах своего типа.
@export var index: int

## Само значение гена (параметр).
@export var value: float


func _init(
		p_type: StringName = &"null",
		p_name: StringName = &"null",
		p_index: int = 0,
		p_value: float = 0.0,
) -> void:
	type = p_type
	name = p_name
	index = p_index
	value = p_value


## Для вывода в логи.
func to_pretty() -> Dictionary:
	return { "type": type, "name": name, "index": index, "value": value }
