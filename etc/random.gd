@abstract
extends Object
## Namespace с функциями для генерации случайных значений.

## Воспроизвести случайное событие с вероятностью [param chance] от 0.0 до 1.0.
static func roll_dice(chance: float) -> bool:
	return randf() <= clampf(chance, 0.0, 1.0)
