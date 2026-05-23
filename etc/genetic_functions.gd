@abstract
extends Object
## Namespace с функциями и классами для генетического алгоритма.

const _rng = preload("res://etc/random.gd")


## Составляющая генома в виде связки параметра с идентификаторами.
##
## Структура состоит из самого параметра [member value] и дополнительной
## информации по подобию label'ов из messy GA.
class Gene extends RefCounted:
	## К какому типу структуры (органа организма) относится этот ген?
	## Гены одного типа либо полностью присутствуют, либо полностью отсутствуют.
	var type: StringName

	## Название параметра в пределах указанного типа.
	## Например, параметр может отвечать за позицию.
	var name: StringName

	## Индекс параметра в геноме в пределах своего типа.
	var index: int

	## Само значение гена (параметр).
	var value: float


	func _init(p_type: StringName, p_name: StringName, p_index: int, p_value: float) -> void:
		type = p_type
		name = p_name
		index = p_index
		value = p_value


	## Для вывода в логи.
	func to_pretty() -> Dictionary:
		return { "type": type, "name": name, "index": index, "value": value }


## Набор параметров организма.
##
## Геном имеет непостоянный размер. Гены одного типа могут повторяться,
## в случае чего гены различаюся под индексу.
class Genome extends RefCounted:
	var genes: Array[Gene] = []


	## Сгруппировать гены [Gene] в словарь. Ключём словаря являются
	## типы [member Gene.type], по которым хранится массив из словарей,
	## где каждый словарь группирует имена [member Gene.name] и значения
	## [member Gene.value] параметров в пределах единого индекса [member Gene.index].
	func groupify() -> Dictionary[StringName, Array]:
		var genome: Dictionary[StringName, Array] = { }
		for gene: Gene in genes:
			if not genome.has(gene.type):
				genome[gene.type] = []

			var type_arr: Array = genome.get(gene.type)
			if type_arr.size() <= gene.index:
				var _err: int = type_arr.resize(gene.index)
			if type_arr[gene.index] == null:
				type_arr[gene.index] = { }

			var dict: Dictionary[StringName, float] = type_arr[gene.index]
			if dict.has(gene.name): # дубликат
				Log.warn(
					"Отброшен дубликат гена",
					gene,
					"но в геноме уже был со значением value =",
					gene.value,
				)
				continue
			dict[gene.name] = gene.value
		return genome


## Рекомбинация (линейная интерполяция).
static func alpha_recombination(param1: Variant, param2: Variant, d: float = 0.25) -> Variant:
	var alpha: float = randf_range(-d, 1 + d)
	return lerp(param1, param2, alpha)


## Рекомбинация (линейная интерполяция) вещественного параметра.
static func alpha_recombinationf(paramf1: float, paramf2: float, d: float = 0.25) -> float:
	var alpha: float = randf_range(-d, 1 + d)
	return lerpf(paramf1, paramf2, alpha)


## Рекомбинация (линейная интерполяция) целочисленного параметра.
static func alpha_recombinationi(parami1: int, parami2: int, d: float = 0.25) -> int:
	var alpha: float = randf_range(-d, 1 + d)
	return roundi(lerpf(parami1 as float, parami2 as float, alpha))


## Мутации для вещественных чисел.
static func real_value_mutation(value: float, val_range: float, iter: int) -> float:
	assert(iter >= 1)
	var alpha: float = 0.5 * val_range
	alpha *= [1, -1].pick_random()

	var calc_delta: Callable = func(m: int) -> float:
		var res := 0.0
		for i: int in range(1, m + 1):
			if _rng.roll_dice(1.0 / m):
				res += pow(2.0, -i)
		return res

	return value + alpha * calc_delta.call(iter)
