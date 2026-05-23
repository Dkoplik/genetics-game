@abstract
extends Object
## Namespace с функциями для генерации случайных значений.


## Воспроизвести случайное событие с вероятностью [param chance] от 0.0 до 1.0.
static func roll_dice(chance: float) -> bool:
	assert((chance >= 0.0) and (chance <= 1.0))
	return randf() <= chance
