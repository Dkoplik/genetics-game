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
const PARAMS_TYPES: Array[Variant.Type] = [TYPE_BOOL, TYPE_INT, TYPE_FLOAT]

var _params: PackedByteArray = []
var _param_types: PackedByteArray = []
# var _param_names: Array[StringName] = []
var _numeric_count: int = 0

func _init(params: Array, param_names: Array = []) -> void:
	var bool_count: int = params.reduce(_count_bools, 0)
	var bool_offset: int = 64 * (params.size() - bool_count)
	var byte_amount: int = (bool_offset / 8) + ceili(bool_count / 8.0)
	_params.resize(byte_amount)
	_param_types.resize(params.size())

	bool_count = 0
	_numeric_count = 0
	for param: Variant in params:
		if typeof(param) == TYPE_BOOL:
			self.set_bit(bool_offset + bool_count, int(param as bool))
			_param_types[(bool_offset / 64) + bool_count] = TYPE_BOOL
			bool_count += 1
		elif typeof(param) == TYPE_INT:
			_params.encode_s64(8 * _numeric_count, param as int)
			_param_types[_numeric_count] = TYPE_INT
			_numeric_count += 1
		elif typeof(param) == TYPE_FLOAT:
			_params.encode_double(8 * _numeric_count, param as float)
			_param_types[_numeric_count] = TYPE_FLOAT
			_numeric_count += 1
		else:
			var err_msg := "Неподдерживаемый тип данных {0}"
			push_error(err_msg.format([type_string(typeof(param))]))


## Возвращает [Variant] параметра по индексу [param index]. Для отрицательных
## значений индекса элементы берутся с конца.
func get_param(index: int) -> Variant:
	if index < 0:
		index += _param_types.size()
	assert((index >= 0) and (index < _param_types.size()), "Индекс выходит за границы генома")

	var dtype: int = _param_types[index]
	if dtype == TYPE_BOOL:
		return bool(self.get_bit(64 * _numeric_count + (index - _numeric_count)))
	if dtype == TYPE_INT:
		return _params.decode_s64(8 * index)
	if dtype == TYPE_FLOAT:
		return _params.decode_double(8 * index)

	assert(false, "Неизвестный тип данных среди инициализированных переменных")
	return 0


## Заменяет значение [Variant] параметра по индексу [param index] на значение
## [param value]. Ожидается тот же тип, что и оригинальный [Variant].
func set_param(index: int, value: Variant) -> void:
	if index < 0:
		index += _param_types.size()
	assert((index >= 0) and (index < _param_types.size()), "Индекс выходит за границы генома")

	var dtype: int = _param_types[index]
	if dtype == TYPE_BOOL:
		if typeof(value) != TYPE_BOOL:
			var err_msg := "Попытка изменить TYPE_BOOL на {0}"
			push_error(err_msg.format([type_string(typeof(value))]))
			return
		self.set_bit(64 * _numeric_count + (index - _numeric_count), value as int)
	elif dtype == TYPE_INT:
		if typeof(value) != TYPE_INT:
			var err_msg := "Попытка изменить TYPE_INT на {0}"
			push_error(err_msg.format([type_string(typeof(value))]))
			return
		_params.encode_s64(8 * index, value as int)
	elif dtype == TYPE_FLOAT:
		if typeof(value) != TYPE_FLOAT:
			var err_msg := "Попытка изменить TYPE_FLOAT на {0}"
			push_error(err_msg.format([type_string(typeof(value))]))
			return
		_params.encode_double(8 * index, value as float)
	else:
		assert(false, "Неизвестный тип данных среди инициализированных переменных")


## Возвращает байт по индексу [param index].
func get_byte(index: int) -> int:
	if index < 0:
		index += _params.size()
	assert((index >= 0) and (index < _params.size()), "Индекс выходит за границы генома")

	return _params[index]


## Заменяет байт по индексу [param index] на значение [param value].
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


## Возвращает бит по индексу [param index].
func get_bit(index: int) -> int:
	if index < 0:
		index += 8 * _params.size()
	assert((index >= 0) and (index < 8 * _params.size()), "Индекс выходит за границы генома")

	var byte: int = _params[index / 8]
	var bit_index_in_byte: int = index % 8
	return Numeric.get_bit_from_int(byte, bit_index_in_byte)


## Заменяет бит по индексу [param index] на значение [param value].
func set_bit(index: int, value: int) -> void:
	if index < 0:
		index += 8 * _params.size()
	assert((index >= 0) and (index < 8 * _params.size()), "Индекс выходит за границы генома")

	var byte: int = _params[index / 8]
	var bit_index_in_byte: int = index % 8
	_params[index / 8] = Numeric.set_bit_in_int(byte, bit_index_in_byte, value)

## Возвращает список из всех текущих параметров этого генома.
func get_all_params() -> Array:
	var res := Array()
	res.resize(_param_types.size())
	for i in range(_param_types.size()):
		res[i] = self.get_param(i)
	return res

## Возвращает все текущие параметры в виде [PackedByteArray].
func get_all_bytes() -> PackedByteArray:
	return _params

## Проверяет массив параметров на использование только поддерживаемых типов
## даных класом [Genome]. Все поддерживаемые типы перечислены в
## [member Genome.PARAMS_TYPES].
func _check_supported_data_types(params: Array) -> bool:
	for param: Variant in params:
		if typeof(param) not in PARAMS_TYPES:
			return false
	return true

## Функция подсчёта булевых переменных для метода [method Array.reduce].
func _count_bools(count: int, x: Variant) -> int:
	if typeof(x) == TYPE_BOOL:
		return count + 1
	return count
