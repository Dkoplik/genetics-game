class_name Numeric extends Object

const INT_MAX: int = 9223372036854775807
const INT_MIN: int = -9223372036854775808

const FLOAT_MAX: float = 1.79769e308
const FLOAT_MIN: float = -1.79769e308

## Для приблизительного сравнения вещественных чисел.
const EPS: float = 1e-8


## Из указанного целого числа [param num] извлекает бит по индексу
## [param index]. Биты расположенны в little-endian порядке, соответственно,
## индекс 0 отвечает за самый младший бит.
static func get_bit_from_int(num: int, index: int) -> int:
	assert(index >= 0, "Отрицательный индекс")
	assert(index < 64, "Индекс выходит за границы 64-битного int")

	return (num >> index) & 1


## Заменяет в указанном целом числе [param num] бит по индексу [param index] на
## значение [param value]. Биты расположенны в little-endian порядке,
## соответственно, индекс 0 отвечает за самый младший бит.
static func set_bit_in_int(num: int, index: int, value: int) -> int:
	assert(index >= 0, "Отрицательный индекс")
	assert(index < 64, "Индекс выходит за границы 64-битного int")
	assert((value == 0) or (value == 1), "Бит может принимать только значение 0 и 1")

	if ((num >> index) & 1) == value:
		return num
	return num ^ (1 << index)


## Воспроизвести случайное событие с вероятностью [param chance] от 0.0 до 1.0.
static func roll_dice(chance: float) -> bool:
	assert((chance >= 0.0) and (chance <= 1.0))
	return randf() <= chance


static func random_value(type: Variant.Type) -> Variant:
	if type == TYPE_INT:
		return randi()
	if type == TYPE_FLOAT:
		return 1000 * randf()
	assert(false, "Неподдерживаемый тип")
	return null
