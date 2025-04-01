class_name Genome extends RefCounted
## Этот класс предоставляет удобные методы для манимуляции над геномом как
## побитово, так и по отдельным переменным.
##
## Класс [Genome] хранит гены какого-либо индивида в виде параметров и
## предоставляет методы для получения и изменения как отдельных параметров, так
## и всех битов итогого генома. Этот класс отвечает только за геном, чтобы его
## можно передавать в функции выбора, мутации и скрещивания, при этом индивида
## надо делать отдельно под конкретную задачу вокруг этого базового генома.

## Поддерживаемые типы данных для использования в качестве параметров решения.
const PARAMS_TYPES: Array[Variant.Type] = [TYPE_BOOL, TYPE_INT]

var _params: Array = []
var _param_names: Array[StringName] = []


func _init(params: Array, param_names: Array = []) -> void:
	assert(_check_supported_data_types(params))
	pass


func get_param(index):
	pass


func set_param(index, value):
	pass


func get_bit(index):
	pass


func set_bit(index, value):
	pass


## Проверяет массив параметров на использование только поддерживаемых типов
## даных класом [Genome]. Все поддерживаемые типы перечислены в
## [member Genome.PARAMS_TYPES].
func _check_supported_data_types(params: Array) -> bool:
	for param in params:
		if typeof(param) not in PARAMS_TYPES:
			return false
	return true
