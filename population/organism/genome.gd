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
var _ranges: Dictionary[String, Array] = {}


## Инициализация начальными значениями. [param params] является либо [Array],
## либо [Dictionary]. В первом случае имена параметрам будут выданы
## автоматически в формате 'param_{i}'. [param ranges] sets ranges for parameter
## values. Ranges could be presented as array of pairs (arrays) or as dictionary
## with param names keys and pairs as value.
func _init(params: Variant, ranges: Variant = null) -> void:
	if params is Dictionary:
		var dparams := params as Dictionary
		assert(dparams.values().all(_is_supported_type))
		var params_dict: Dictionary[String, Variant] = {}
		for key: String in dparams.keys():  # Костыль для типизированного словаря
			assert(key is String)
			assert(dparams.get(key) is Variant)
			params_dict.set(key, dparams.get(key))
		_params = params_dict
	else:
		assert(params is Array)
		var params_arr := params as Array
		assert(params_arr.all(_is_supported_type))
		for i in range(params_arr.size()):
			var key := "param_{0}".format([i])
			_params.set(key, params_arr[i])

	if not ranges:
		return
	if ranges is Array:
		var ranges_arr := ranges as Array
		for i in range(ranges_arr.size()):
			var pair := ranges_arr[i] as Array
			assert(pair.size() == 2)
			assert(pair[0] <= pair[1])
			assert(typeof(pair[0]) == typeof(pair[1]))
			var key: String = _params.keys().get(i)
			assert(typeof(_params.get(key)) == typeof(pair[0]))
			_ranges.set(key, pair)
	else:
		assert(ranges is Dictionary)
		var dranges := ranges as Dictionary
		for key: String in dranges.keys():
			var pair := dranges.get(key) as Array
			assert(pair.size() == 2)
			assert(pair[0] <= pair[1])
			assert(typeof(pair[0]) == typeof(pair[1]))
			assert(key in _params.keys())
			assert(typeof(_params.get(key)) == typeof(pair[0]))
			_ranges.set(key, pair)


## Возвращает [Variant] параметра по ключу [param key]. [param key] может быть
## либо целочисленным индексом, либо именем параметра. Для отрицательных
## значений индекса элементы берутся с конца.
func get_param(key: Variant) -> Variant:
	var str_key: String = _param_key_to_string(key)
	return _params.get(str_key)


## Заменяет значение [Variant] параметра по ключу [param key] на значение
## [param value]. Ожидается тот же тип, что и оригинальный [Variant].
## [param key] может быть либо целочисленным индексом, либо именем параметра.
## Для отрицательных значений индекса элементы берутся с конца.
func set_param(key: Variant, value: Variant) -> void:
	assert(_is_supported_type(value))
	var str_key: String = _param_key_to_string(key)

	if typeof(value) != typeof(_params.get(str_key)):
		push_warning("Change of type for {0}".format([str_key]))
	if _ranges.has(str_key):
		value = clamp(value, _ranges.get(str_key)[0], _ranges.get(str_key)[1])
	_params.set(str_key, value)


## Возвращает байт по целочисленному индексу [param index].
func get_byte(index: int) -> int:
	if index < 0:
		index += byte_array_size()
	assert((index >= 0) and (index < byte_array_size()), "Индекс выходит за границы генома")

	var target_param: Variant = get_param(index / TYPE_SIZE)
	var bytes := PackedByteArray()
	bytes.resize(TYPE_SIZE)
	if target_param is int:
		bytes.encode_s64(0, target_param as int)
	elif target_param is float:
		bytes.encode_double(0, target_param as float)
	else:
		assert(false, "Unsupported type")
	return bytes.get(index % TYPE_SIZE)


## Заменяет байт по целочисленному индексу [param index] на значение
## [param value].
func set_byte(index: int, value: int) -> void:
	if index < 0:
		index += byte_array_size()
	assert((index >= 0) and (index < byte_array_size()), "Индекс выходит за границы генома")
	assert((value >= 0) and (value < 256), "incorrect value")

	var target_param: Variant = get_param(index / TYPE_SIZE)
	var bytes := PackedByteArray()
	bytes.resize(TYPE_SIZE)
	if target_param is int:
		bytes.encode_s64(0, target_param as int)
		bytes.set(index % TYPE_SIZE, value)
		set_param(index / TYPE_SIZE, bytes.decode_s64(0))
	elif target_param is float:
		bytes.encode_double(0, target_param as float)
		bytes.set(index % TYPE_SIZE, value)
		set_param(index / TYPE_SIZE, bytes.decode_double(0))
	else:
		assert(false, "Unsupported type")


## Возвращает бит по целочисленному индексу [param index].
func get_bit(index: int) -> int:
	if index < 0:
		index += bit_array_size()
	assert((index >= 0) and (index < bit_array_size()), "Индекс выходит за границы генома")

	var byte: int = get_byte(index / 8)
	var bit_index_in_byte: int = index % 8
	return Numeric.get_bit_from_int(byte, bit_index_in_byte)


## Заменяет бит по целочисленному индексу [param index] на значение
## [param value].
func set_bit(index: int, value: int) -> void:
	if index < 0:
		index += bit_array_size()
	assert((index >= 0) and (index < bit_array_size()), "Индекс выходит за границы генома")
	assert((value == 0) or (value == 1))

	var byte: int = get_byte(index / 8)
	var bit_index_in_byte: int = index % 8
	set_byte(index / 8, Numeric.set_bit_in_int(byte, bit_index_in_byte, value))


func duplicate() -> Genome:
	return Genome.new(_params, _ranges)


func randomize_params() -> void:
	for key: String in _params.keys():
		if _params.get(key) is int:
			if _ranges.has(key):
				var pair := _ranges.get(key) as Array
				set_param(key, randi_range(pair[0] as int, pair[1] as int))
			else:
				set_param(key, randi())
		elif _params.get(key) is float:
			if _ranges.has(key):
				var pair := _ranges.get(key) as Array
				set_param(key, randf_range(pair[0] as float, pair[1] as float))
			else:
				set_param(key, randf() * (Numeric.FLOAT_MAX / 2))
		else:
			assert(false)


func get_ranges_dict() -> Dictionary[String, Array]:
	return _ranges


func get_param_dict() -> Dictionary[String, Variant]:
	return _params


## Установить все значения параметров через массив параметров [param array].
func set_param_array(array: Array) -> void:
	assert(array.size() == param_array_size())
	for i in range(array.size()):
		self.set_param(i, array[i])


## Возвращает все текущие параметры в виде [PackedByteArray].
func get_byte_array() -> PackedByteArray:
	var bytes := PackedByteArray()
	bytes.resize(byte_array_size())
	for i in range(bytes.size()):
		bytes.set(i, get_byte(i))
	return bytes


## Установить все значения параметров через массив байтов [param array].
func set_byte_array(array: PackedByteArray) -> void:
	assert(array.size() == byte_array_size())
	for i in range(array.size()):
		set_byte(i, array[i])


## Возвращает отрезок параметров с номерами от [param from] до [param to] (не
## включительно).
func get_param_slice(from: int, to: int) -> Array:
	var res: Array[Variant] = []
	res.resize(to - from)
	for i in range(from, to):
		res[i - from] = get_param(i)
	return res


## Возвращает отрезок из байтов с номерами от [param from] до [param to] (не
## включительно).
func get_byte_slice(from: int, to: int) -> PackedByteArray:
	var res: Array[int] = []
	res.resize(to - from)
	for i in range(from, to):
		res[i] = get_byte(i)
	return res


## Возвращает отрезок из битов с номерами от [param from] до [param to] (не
## включительно).
func get_bit_slice(from: int, to: int) -> Array[int]:
	var res: Array[int] = []
	res.resize(to - from)
	for i in range(from, to):
		res[i] = get_bit(i)
	return res


## Количество параметров в [Genome].
func param_array_size() -> int:
	return _params.size()


## Количество байтов в [Genome].
func byte_array_size() -> int:
	return TYPE_SIZE * param_array_size()


## Количество битов в [Genome].
func bit_array_size() -> int:
	return 8 * byte_array_size()


## Проверяет, поддерживает ли [Genome] данный тип данных.
func _is_supported_type(val: Variant) -> bool:
	return typeof(val) in PARAMS_TYPES


## Проверяет индекс на выход за границы и переводит его в соответсвующий
## строковый ключ.
func _param_key_to_string(key: Variant) -> String:
	if key is int:
		if key < 0:
			key += param_array_size()
		assert((key >= 0) and (key < param_array_size()), "Индекс выходит за границы")
		return _params.keys()[key]

	assert(key is String)
	return key
