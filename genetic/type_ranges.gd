@tool
class_name TypeRanges
extends Resource
## Ограничения [GeneMinMax] для различных [Gene.name] в пределах одного [Gene.type].

@export var ranges_for_type: Dictionary[StringName, GeneMinMax]


## Содержит ли поле [param name].
func has(name: StringName) -> bool:
	return ranges_for_type.has(name)


## Возвращает [GeneMinMax] для поля [param name] или null, если такого нет.
func get_minmax(name: StringName) -> GeneMinMax:
	return ranges_for_type.get(name, null)
