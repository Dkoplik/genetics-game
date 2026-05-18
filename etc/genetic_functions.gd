extends RefCounted

const rng = preload("res://etc/random.gd")


func _init() -> void:
	assert(false, "Попытка создать экземпляр namespace'а")


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
			if rng.roll_dice(1.0 / m):
				res += pow(2.0, -i)
		return res

	return value + alpha * calc_delta.call(iter)
