@tool
class_name GeneRanges
extends Resource
## Диапазон значений для каждого гена.

@export var gene_ranges: Dictionary[StringName, TypeRanges]


## Есть ли информация о поле [param property_name] из типа [param type].
func has_gene(type: StringName, property_name: StringName) -> bool:
	if not gene_ranges.has(type):
		return false
	var type_ranges: TypeRanges = gene_ranges.get(type)
	return type_ranges.has(property_name)


## Возвращает [GeneMinMax] для поля [param property_name] из типа [param type].
## Если такого типа или поля нет, возвращает null.
func get_gene_range(type: StringName, property_name: StringName) -> GeneMinMax:
	if not gene_ranges.has(type):
		return null
	var type_ranges: TypeRanges = gene_ranges.get(type)
	return type_ranges.get_minmax(property_name)
