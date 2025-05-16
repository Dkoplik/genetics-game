class_name Genome extends RefCounted
## Этот класс предоставляет удобные методы для манимуляции над геномом как
## побитово, так и по отдельным переменным.
##
## Класс [Genome] хранит гены (параметры) какого-либо индивида и предоставляет
## методы для получения и изменения как отдельных параметров, так и байтов или
## битов параметров из итогового генома. Этот класс отвечает только за геном,
## чтобы его можно передавать в функции выбора, мутации и скрещивания, при этом
## индивида надо делать отдельно под конкретную задачу вокруг этого базового
## генома. Стоит учитывать, что все параметры используют little-endian порядок
## в байтовых и битовых представлениях, соответственно, 0-ой индекс отвечает
## за самый младший байт или бит.

## Поддерживаемые типы данных для использования в качестве параметров решения.
const PARAMS_TYPES: Array[Variant.Type] = [TYPE_INT, TYPE_FLOAT]
## Размер всех типов в байтах.
const TYPE_SIZE: int = 8

var _params: Dictionary[String, Variant] = {}

## Инициализация начальными значениями. [param params] является либо [Array],
## либо [Dictionary]. В первом случае имена параметрам будут выданы
## автоматически в формате 'param_{i}'.
func _init(params: Variant) -> void:
	if params is Dictionary:
		_params = params
	else:
		assert(params is Array)
		for i in range(params.size()):
			var key := 'param_{0}'.format([i])
			_params.set(key, params[i])
	assert(_params.size() == params.size())
	assert(params.all(_is_supported_type))


## Возвращает [Variant] параметра по ключу [param key]. [param key] может быть
## либо целочисленным индексом, либо именем параметра. Для отрицательных
## значений индекса элементы берутся с конца.
func get_param(key: Variant) -> Variant:
	if key is int:
		key = _int_key_to_string(key)

	assert(key is String)
	return _params.get(key)


## Заменяет значение [Variant] параметра по ключу [param key] на значение
## [param value]. Ожидается тот же тип, что и оригинальный [Variant].
## [param key] может быть либо целочисленным индексом, либо именем параметра.
## Для отрицательных значений индекса элементы берутся с конца.
func set_param(key: Variant, value: Variant) -> void:
	if key is int:
		key = _int_key_to_string(key)

	assert(key is String)
	if typeof(value) != typeof(_params.get(key)):
		push_warning('Change of type for {0}'.format([key]))
		assert(_is_supported_type(value))
	_params.set(key, value)


## Возвращает байт по целочисленному индексу [param index].
func get_byte(index: int) -> int:
	if index < 0:
		index += _params.size()
	assert((index >= 0) and (index < _params.size()), "Индекс выходит за границы генома")

	for i in range(_params.size()):
		var len: int = 0
		var param: Variant = self.get_param(i)
		if
	return self.get_byte_array()[index]


## Заменяет байт по целочисленному индексу [param index] на значение
## [param value].
func set_byte(index: int, value: int) -> void:
	if index < 0:
		index += _params.size()
	assert((index >= 0) and (index < _params.size()), "Индекс выходит за границы генома")

	if value < 0:
		var err_msg := "Попытка установить отрицательный байт {0}"
		push_error(err_msg.format([value]))
		return
	if value > 255:
		var err_msg := "Значение {0} выходит за границы байта"
		push_error(err_msg.format([value]))
		return

	_params[index] = value


## Возвращает бит по целочисленному индексу [param index].
func get_bit(index: int) -> int:
	if index < 0:
		index += 8 * _params.size()
	assert((index >= 0) and (index < 8 * _params.size()), "Индекс выходит за границы генома")

	var byte: int = _params[index / 8]
	var bit_index_in_byte: int = index % 8
	return Numeric.get_bit_from_int(byte, bit_index_in_byte)


## Заменяет бит по целочисленному индексу [param index] на значение
## [param value].
func set_bit(index: int, value: int) -> void:
	if index < 0:
		index += 8 * _params.size()
	assert((index >= 0) and (index < 8 * _params.size()), "Индекс выходит за границы генома")

	var byte: int = _params[index / 8]
	var bit_index_in_byte: int = index % 8
	_params[index / 8] = Numeric.set_bit_in_int(byte, bit_index_in_byte, value)


## Возвращает список из всех текущих параметров этого генома в виде [Array].
func get_param_array() -> Array:
	var res := Array()
	res.resize(_param_types.size())
	for i in range(_param_types.size()):
		res[i] = self.get_param(i)
	return res


## Установить все значения параметров через массив параметров [param array].
func set_param_array(array: Array) -> void:
	for i in range(_param_types.size()):
		self.set_param(i, array[i])


## Возвращает все текущие параметры в виде [PackedByteArray].
func get_byte_array() -> PackedByteArray:
	return _params


## Установить все значения параметров через массив байтов [param array].
func set_byte_array(array: PackedByteArray) -> void:
	for i in range(_params.size()):
		self.set_byte(i, array[i])


## Возвращает отрезок из битов с номерами от [param from] до [param to] (не
## включительно).
func get_bit_slice(from: int, to: int) -> Array[int]:
	var res: Array[int] = []
	res.resize(to - from)
	for i in range(from, to):
		res[i] = self.get_bit(i)
	return res


## Возвращает отрезок из байтов с номерами от [param from] до [param to] (не
## включительно).
func get_byte_slice(from: int, to: int) -> PackedByteArray:
	var res: Array[int] = []
	res.resize(to - from)
	for i in range(from, to):
		res[i] = self.get_byte(i)
	return res


## Возвращает отрезок параметров с номерами от [param from] до [param to] (не
## включительно).
func get_param_slice(from: int, to: int) -> Array:
	var res: Array[int] = []
	res.resize(to - from)
	for i in range(from, to):
		res[i] = self.get_param(i)
	return res


## Количество параметров в [Genome].
func params_size() -> int:
	return _params.size()


## Количество байтов в [Genome].
func byte_size() -> int:
	return 0


## Количество битов в [Genome].
func bit_size() -> int:
	return 0


## TODO desc
func _is_supported_type(val: Variant) -> bool:
	return typeof(val) in PARAMS_TYPES

## TODO desc
func _int_key_to_string(index: int) -> String:
	if index < 0:
		index += _params.size()
	assert((index >= 0) and (index < _params.size()), "Индекс выходит за границы")
	return _params.keys()[index]
