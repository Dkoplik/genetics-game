extends RefCounted

func _init() -> void:
	assert(false, "Попытка создать экземпляр namespace'а")


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
