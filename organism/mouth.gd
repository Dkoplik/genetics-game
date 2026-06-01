@tool
extends Area2D
## Рот/челюсть/клещни организма. Позволяют атаковать другие организмы.

@export var min_size: float = 0.25:
	set(value):
		min_size = max(0.0, value)

		if min_size > max_size:
			max_size = min_size

		if energy_consumption_vs_size != null:
			energy_consumption_vs_size.min_domain = min_size

		if damage_vs_size != null:
			damage_vs_size.min_domain = min_size

@export var max_size: float = 2.0:
	set(value):
		max_size = max(0.0, value)

		if min_size > max_size:
			min_size = max_size

		if energy_consumption_vs_size != null:
			energy_consumption_vs_size.max_domain = max_size

		if damage_vs_size != null:
			damage_vs_size.max_domain = max_size

## Размер организма.
@export var size: float = 1.0:
	set(value):
		size = clampf(value, min_size, max_size)
		_update_consumption()
		_update_damage()
		scale = Vector2(size, size)

## Кривая зависимости между потреблением энергии (Y) и размером (X).
@export var energy_consumption_vs_size: Curve:
	set(value):
		if energy_consumption_vs_size != null:
			energy_consumption_vs_size.changed.disconnect(_update_consumption)

		energy_consumption_vs_size = value
		_process_curve(energy_consumption_vs_size, _update_consumption)
		_update_consumption()
		if Engine.is_editor_hint():
			update_configuration_warnings()

## Кривая зависимости между уроном (Y) и размером (X).
@export var damage_vs_size: Curve:
	set(value):
		if damage_vs_size != null:
			damage_vs_size.changed.disconnect(_update_damage)

		damage_vs_size = value
		_process_curve(damage_vs_size, _update_damage)
		_update_damage()
		if Engine.is_editor_hint():
			update_configuration_warnings()

## Потребление энергии в секунду.
@export_custom(
	PROPERTY_HINT_NONE,
	"suffix:per sec",
	PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
)
var energy_consumption: float:
	set(value):
		if value < 0.0:
			Log.warn("Попытка сделать energy_consumption отрицательным")
			value = 0.0
		energy_consumption = value

## Урон за один удар.
@export_custom(
	PROPERTY_HINT_NONE,
	"suffix:hp per hit",
	PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
)
var damage: float:
	set(value):
		if value < 0.0:
			Log.warn("Попытка сделать damage отрицательным")
			value = 0.0
		damage = value


func _update_consumption() -> void:
	if energy_consumption_vs_size != null:
		if energy_consumption_vs_size.point_count == 0:
			Log.warn("В кривой energy_consumption_vs_size отсутствуют точки")
		energy_consumption = energy_consumption_vs_size.sample(size)
	elif not Engine.is_editor_hint():
		Log.err("Попытка обновить energy_consumption без кривой energy_consumption_vs_size")


func _update_damage() -> void:
	if damage_vs_size != null:
		if damage_vs_size.point_count == 0:
			Log.warn("В кривой damage_vs_size отсутствуют точки")
		damage = damage_vs_size.sample(size)
	elif not Engine.is_editor_hint():
		Log.err("Попытка обновить rotation_speed без кривой damage_vs_size")


func _process_curve(curve: Curve, updater: Callable) -> void:
	if curve == null:
		return

	curve.min_domain = min_size
	curve.max_domain = max_size
	var _err: int = curve.changed.connect(updater)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if energy_consumption_vs_size == null:
		var _tmp: bool = warnings.append("Отсутствует график зависимости потребления от размера")
	if damage_vs_size == null:
		var _tmp: bool = warnings.append(
			"Отсутствует график зависимости урона от размера",
		)
	return warnings
