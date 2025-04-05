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
const PARAMS_TYPES: Array[Variant.Type] = [TYPE_BOOL, TYPE_INT, TYPE_FLOAT]

var _params: Array = []
var _param_names: Array[StringName] = []


func _init(params: Array, param_names: Array = []) -> void:
	assert(_check_supported_data_types(params))
	pass


## Возвращает [Variant] параметра по индексу [param index].
func get_param(index: int) -> Variant:
	return 0


## Заменяет значение [Variant] параметра по индексу [param index] на значение
## [param value]. Ожидается тот же тип [Variant].
func set_param(index: int, value: Variant) -> void:
	pass


## Возвращает байт по индексу [param index].
func get_byte(index: int) -> int:
	return 0


## Заменяет байт по индексу [param index] на значение [param value].
func set_byte(index: int, value: int):
	pass


## Возвращает бит по индексу [param index].
func get_bit(index: int) -> int:
	return 0


## Заменяет бит по индексу [param index] на значение [param value].
func set_bit(index: int, value: int):
	pass


## Проверяет массив параметров на использование только поддерживаемых типов
## даных класом [Genome]. Все поддерживаемые типы перечислены в
## [member Genome.PARAMS_TYPES].
func _check_supported_data_types(params: Array) -> bool:
	for param in params:
		if typeof(param) not in PARAMS_TYPES:
			return false
	return true


## Переводит поданное значение [param value] в двоичное Little-Endian
## представление в виде [PackedByteArray]. Все целые и вещественные числа
## состоят из 64 бит.
static func value_to_byte_array(value: Variant) -> PackedByteArray:
	var byte_array: PackedByteArray = var_to_bytes(value)
	return PackedByteArray()
