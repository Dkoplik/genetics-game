class_name FitnessFunction extends Expression
## [Expression] с возможностью добавления и удаления слагаемых выражения.
##
## Этот класс, в отличие от обычного [Expression], позволяет не просто сохранить
## какое-то конкретное выражение, но и менять его, добавляя/удаляя слагаемые.

## Текущие слагаемые в функции приспособленности.
var _summands: Dictionary[String, bool] = {}  # Вместо Set
## Количество вхождений каждой переменной в выражение.
var _variables_uses: Dictionary[String, int] = {}
## Порядок указания переменных для дальнейшего использования в
## [method Expression.parse] и [method Expression.execute].
var _variables_order: PackedStringArray = []


## Инициализация начальными слагаемыми [param summands] с их переменными
## [param variables]. [param summands] может быть как массивом строк, так и
## единственной строкой-выражением.
func _init(summands: Variant = null, variables: Variant = null) -> void:
	if summands == null:
		self.parse("null")
		return
	assert((summands is String) or (summands is Array) or (summands is PackedStringArray))
	assert((variables is Array) or (variables is PackedStringArray))
	if summands is String:
		var err: Error = add_summand(summands as String, variables)
		assert(err == Error.OK)
		return
	for summand: String in summands as PackedStringArray:
		var tmp: PackedStringArray = []
		for variable: String in variables:
			if variable in summand:
				tmp.append(variable)
		var err: Error = add_summand(summand, tmp)
		assert(err == Error.OK)


## Добавляет слагаемое в выражение. [param summand] содержит добавляемое
## слагаемое, а [param variables] должно содержать названия переменных,
## используемых в [param summand]. Возвращает код ошибки [Error], если после
## добавления слагаемого [method Expression.parse] провалился.
func add_summand(summand: String, variables: PackedStringArray) -> Error:
	if summand.is_empty():
		push_error("Попытка добавить пустое слагаемое")
		return Error.OK

	_summands.set(summand, true)

	for variable in variables:
		if variable not in summand:
			var err_msg := "Перменная '{0}' указана, но отсутствует в '{1}'"
			push_warning(err_msg.format([variable, summand]))
			continue

		if _variables_uses.has(variable):
			_variables_uses.set(variable, _variables_uses.get(variable) + 1)
		else:
			_variables_uses.set(variable, 1)
			_variables_order.append(variable)

	return self.parse(_join_summands(), _variables_order)


## Удаляет слагаемое из выражения. [param summand] содержит удаляемое
## слагаемое, а [param variables] должно содержать названия переменных,
## используемых в [param summand]. Возвращает код ошибки [Error], если после
## удаления слагаемого [method Expression.parse] провалился.
func remove_summand(summand: String, variables: PackedStringArray) -> Error:
	assert(contains(summand))
	_summands.erase(summand)

	# Удаление переменных
	for variable in variables:
		if variable not in summand:
			var err_msg := "Перменная '{0}' указана, но отсутствует в '{1}'"
			push_warning(err_msg.format([variable, summand]))
			continue
		_variables_uses.set(variable, _variables_uses.get(variable) - 1)
		if _variables_uses.get(variable) == 0:
			_variables_uses.erase(variable)
			_variables_order.remove_at(_variables_order.find(variable))

	return self.parse(_join_summands(), _variables_order)


## Проверяет, содержится ли слагаемое [param summand] в выражении.
func contains(summand: String) -> bool:
	return _summands.has(summand)


## Возвращает массив со всеми текущими слагаемыми функции.
func get_summands_array() -> PackedStringArray:
	return _summands.keys() as PackedStringArray


## Вычисляет значение функции приспособленности. [param params] должно содержать
## [b]все[/b] используемые значения переменных в выражении и их значения. Если
## во время исполнения возникла ошибка, возвращает null. Лишние переменные
## игнорируются.
func calculate(params: Dictionary[String, Variant]) -> Variant:
	var inputs: Array[Variant] = []
	for variable in _variables_order:
		assert(variable in params)
		inputs.append(params.get(variable))
	var res: Variant = self.execute(inputs, null, true, true)
	if self.has_execute_failed():
		return null
	return res


## Создать копию текущей [FitnessFunction].
func duplicate() -> FitnessFunction:
	return FitnessFunction.new(_summands.keys(), _variables_order)


## Объединяет слагаемые [member _summands] в единое выражение.
func _join_summands() -> String:
	if _summands.is_empty():
		return "null"

	var summand_arr: PackedStringArray = _summands.keys()
	var res: String = summand_arr[0]
	for i in range(1, len(summand_arr)):
		res += "+" + summand_arr[i]
	return res
