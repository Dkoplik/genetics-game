class_name GenesTable
extends RefCounted
## Сгруппированный набор генов [Gene] для строгой типизации и удобства.[br]
## Пояснение: в GDScript нет типизации для вложенных типов.

## Словарь вида имя-значение ([member Gene.name]-[member Gene.value]) для
## произвольного типа [member Gene.type].
class TypeData extends RefCounted:
	var data: Dictionary[StringName, float] = { }


	func _init(params: Dictionary[StringName, float] = { }) -> void:
		data = params


	## Поэлементное сравнение.
	func is_equal(other: TypeData) -> bool:
		if data.size() != other.data.size():
			return false
		for key: StringName in data:
			if not other.data.has(key) or data[key] != other.data[key]:
				return false
		return true


## Массив из словарей [TypeProperties] в пределах одного типа [member Gene.type].
class TypeArr extends RefCounted:
	var data: Array[TypeData] = []


	func _init(p_data: Array[TypeData] = []) -> void:
		data = p_data


	## Размер массива (количество сгруппированных по индексу параметров).
	func size() -> int:
		return data.size()


	## Получить параметры по индексу [param index].
	func at(index: int) -> Dictionary[StringName, float]:
		var type_data: TypeData = data[index]
		return type_data.data


	## Выставить параметры [param params] по индексу [param index].
	func set_at(index: int, params: Dictionary[StringName, float]) -> void:
		data[index] = TypeData.new(params)


	## Добавить в конец массива параметры [param params].
	func append(params: Dictionary[StringName, float]) -> void:
		data.append(TypeData.new(params))


	## Изменить размер массива на [param new_size]. Если новый размер больше
	## предыдущего, то новые значения заполняются пустыми словарями.
	func resize(new_size: int) -> void:
		var old_size: int = size()
		var _err: int = data.resize(new_size)
		for index in range(old_size, new_size):
			set_at(index, { })


	## Поэлементное сравнение.
	func is_equal(other: TypeArr) -> bool:
		if size() != other.size():
			return false
		for index in range(size()):
			if not data[index].is_equal(other.data[index]):
				return false
		return true

## Сгруппированный набор генов [Gene].
var data: Dictionary[StringName, TypeArr] = { }


func _init(genes: Array[Gene]) -> void:
	data = { }
	for gene: Gene in genes:
		var type: StringName = gene.type
		if not has_type(type):
			set_all_type_data(type, TypeArr.new())

		var index: int = gene.index
		if get_type_arr_size(type) <= index:
			resize_type_data(type, index + 1)
			if get_type_arr_size(type) >= 1_000:
				Log.warn("Размер массива для типа", type, "превысил 1_000")

		var name: StringName = gene.name
		var params: Dictionary[StringName, float] = get_type_data_or_assert(type, index)
		if params.has(name): # дубликат
			Log.warn(
				"Отброшен дубликат гена",
				gene,
				"но в геноме уже был со значением value =",
				params[name],
			)
			continue
		params[name] = gene.value


## Количество различных типов в таблице.
func get_types_amount() -> int:
	return data.size()


## Содержится ли тип [param type] (aka [member Gene.type])?
func has_type(type: StringName) -> bool:
	return data.has(type)


## Получить массив со всеми значениями, относящиеся к указанному типу [param type].
func get_all_type_data(type: StringName, default: TypeArr = null) -> TypeArr:
	return data.get(type, default)


## Получить массив со всеми значениями, относящиеся к указанному типу [param type].
## Если типа [param type] нет в геноме, вызывается assert.
func get_all_type_data_or_assert(type: StringName) -> TypeArr:
	var type_arr: TypeArr = get_all_type_data(type)
	assert(type_arr != null)
	return type_arr


## Выставить данные для типа [param type].
func set_all_type_data(type: StringName, type_arr: TypeArr) -> void:
	data[type] = type_arr


## Добавляет новый тип [param type] с пустым массивом [TypeArr]. Если
## такой тип уже присутствует, вызывается assert.
func add_type_data(type: StringName) -> void:
	assert(not has_type(type))
	data[type] = TypeArr.new()


## Получить количество генов с типом [param type], которые имеют различные
## индексы [member Gene.index]. Если [param type] отсутствует, возвращает 0.
func get_type_arr_size(type: StringName) -> int:
	var type_arr: TypeArr = get_all_type_data(type, TypeArr.new())
	return type_arr.data.size()


## Возвращает массив со всеми типами из таблицы.
func get_all_types() -> Array[StringName]:
	return data.keys()


## Существует ли тип [param type] с индексом [param index]? Возвращает true, если
## присутствует тип [param type] и среди него есть индекс [param index], иначе false.
func has_type_with_index(type: StringName, index: int) -> bool:
	if not has_type(type):
		return false
	if index < 0 or get_type_arr_size(type) <= index:
		return false
	return not get_type_data_or_assert(type, index).is_empty()


## Получить параметры типа [param type] с индексом [param index]. Если [param type]
## или [param index] отсутствуют, возвращает [param default].
func get_type_data(
		type: StringName,
		index: int,
		default: Dictionary[StringName, float] = { },
) -> Dictionary[StringName, float]:
	if not has_type_with_index(type, index):
		return default
	var type_arr: TypeArr = get_all_type_data_or_assert(type)
	return type_arr.at(index)


## Получить параметры типа [param type] с индексом [param index]. Если [param type]
## или [param index] отсутствуют, вызывается assert.
func get_type_data_or_assert(
		type: StringName,
		index: int,
) -> Dictionary[StringName, float]:
	var type_arr: TypeArr = get_all_type_data_or_assert(type)
	return type_arr.at(index)


## Выставить параметры для типа [param type] по индексу [param index] в значение
## [param params].
func set_type_data(
		type: StringName,
		index: int,
		params: Dictionary[StringName, float],
) -> void:
	var type_arr: TypeArr = get_all_type_data_or_assert(type)
	type_arr.set_at(index, params)


## Добавить в конец массива с типом [param type] параметры [param params].
func append_type_data(type: StringName, params: Dictionary[StringName, float]) -> void:
	var type_arr: TypeArr = get_all_type_data_or_assert(type)
	type_arr.append(params)


## Добавляет массив [param type_arr] в конец массива с типом [param type]. Если
## [param type] отсутствует в таблице, вызывает assert.
func append_type_arr(type: StringName, type_arr: TypeArr) -> void:
	assert(has_type(type))
	get_all_type_data(type).data.append_array(type_arr.data)


## Меняет размер массива с типом [param type]. Если новый размер больше предыдущего,
## то новые элементы заполняются пустыми словарями. Если типа [param type] нет,
## вызывает assert.
func resize_type_data(type: StringName, new_size: int) -> void:
	var type_arr: TypeArr = get_all_type_data_or_assert(type)
	type_arr.resize(new_size)


## Преобразует таблицу генов обратно в массив генов [Gene].
func into_array_of_genes() -> Array[Gene]:
	var res: Array[Gene] = []
	for type: StringName in get_all_types():
		var type_arr: TypeArr = get_all_type_data_or_assert(type)
		for index: int in range(type_arr.size()):
			var params: Dictionary[StringName, float] = type_arr.at(index)
			for name: StringName in params:
				var value: float = params[name]
				res.push_back(Gene.new(type, name, index, value))
	return res


## Полностью копирует таблицу
func duplicate() -> GenesTable:
	var new_table := GenesTable.new([])
	for type: StringName in get_all_types():
		var type_arr: Array[TypeData] = []
		var _err: int = type_arr.resize(get_type_arr_size(type))
		for index: int in range(type_arr.size()):
			var params: Dictionary[StringName, float] = get_type_data_or_assert(type, index)
			type_arr[index] = TypeData.new(params.duplicate(true))
		new_table.set_all_type_data(type, TypeArr.new(type_arr))
	return new_table


## Поэлементное сравнение.
func is_equal(other: GenesTable) -> bool:
	if get_all_types().size() != other.get_all_types().size():
		return false
	for type: StringName in get_all_types():
		if not other.get_all_types().has(type):
			return false
		if not get_all_type_data(type).is_equal(other.get_all_type_data(type)):
			return false
	return true
