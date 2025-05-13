class_name FitnessFunction extends Expression
## [Expression] с возможностью добавления и удаления слагаемых выражения.
##
## Этот класс, в отличие от обычного [Expression], позволяет не просто сохранить
## какое-то конкретное выражение, но и менять его, добавляя/удаляя слагаемые.

## Текущие слагаемые в функции приспособленности.
var _summands: PackedStringArray = []
## Количество вхождений каждой переменной в выражение.
var _variables_uses: Dictionary[String, int] = {}
## Порядок указания переменных для дальнейшего использования в
## [method Expression.parse] и [method Expression.execute].
var _variables_order: PackedStringArray = []


## Добавляет слагаемое в выражение. [param summand] содержит добавляемое
## слагаемое, а [param variables] должно содержать названия переменных,
## используемых в [param summand]. Возвращает код ошибки [Error], если после
## добавления слагаемого [method Expression.parse] провалился.
func add_summand(summand: String, variables: PackedStringArray) -> Error:
	if summand.is_empty():
		push_warning("Попытка добавить пустое слагаемое")
		return Error.OK

	for variable in variables:
		if variable not in summand:
			var err_msg := "Перменная '{0}' указана, но отсутствует в '{1}'"
			push_warning(err_msg.format([variable, summand]))

	_summands.append(summand)

	for variable in variables:
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
	if not contains(summand):
		var err_msg := "Попытка удалить несуществующее слагаемое '{0}' из {1}"
		push_warning(err_msg.format([summand, _summands]))
		return Error.OK

	_summands.remove_at(_summands.find(summand))

	# Удаление переменных
	for variable in variables:
		_variables_uses.set(variable, _variables_uses.get(variable) - 1)
		if _variables_uses.get(variable) == 0:
			_variables_uses.erase(variable)
			_variables_order.remove_at(_variables_order.find(variable))

	return self.parse(_join_summands(), _variables_order)


## Проверяет, содержится ли слагаемое [param summand] в выражении.
func contains(summand: String) -> bool:
	return _summands.has(summand)


## Вычисляет значение функции приспособленности. [param params] должно содержать
## [b]все[/b] используемые значения переменных в выражении и их значения. Если
## во время исполнения возникла ошибка, возвращает null.
func calculate(params: Dictionary[String, Variant]) -> Variant:
	var inputs: Array[Variant] = []
	for variable in _variables_order:
		if variable not in params:
			var err_msg := "Отсутствует значение переменной {0}"
			push_error(err_msg.format([variable]))
			return null
		inputs.append(params.get(variable))
	var res: Variant = self.execute(inputs, null, true, true)
	if self.has_execute_failed():
		return null
	return res


## Объединяет массив слагаемых [member _summands] в единое выражение.
func _join_summands() -> String:
	if _summands.is_empty():
		return "null"

	var res: String = _summands[0]
	for i in range(1, len(_summands)):
		res += "+" + _summands[i]
	return res
