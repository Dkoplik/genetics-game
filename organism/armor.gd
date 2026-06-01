@tool
extends Area2D
## Броня/панцирь организма. Защищает от атак.

const ORGANISM_CLASS := preload("res://organism/organism_root.gd")
const ORGANISM_PHYSICS := preload("res://organism/character_body_2d.gd")
const ORGANS_MANAGER := preload("res://organism/organs_manager.gd")

@export var min_size: float = 0.25:
	set(value):
		min_size = max(0.0, value)

		if min_size > max_size:
			max_size = min_size

		if energy_consumption_vs_size != null:
			energy_consumption_vs_size.min_domain = min_size

@export var max_size: float = 2.0:
	set(value):
		max_size = max(0.0, value)

		if min_size > max_size:
			min_size = max_size

		if energy_consumption_vs_size != null:
			energy_consumption_vs_size.max_domain = max_size

## Размер организма.
@export var size: float = 1.0:
	set(value):
		size = clampf(value, min_size, max_size)
		_update_consumption()
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


func _update_consumption() -> void:
	if energy_consumption_vs_size != null:
		if energy_consumption_vs_size.point_count == 0:
			Log.warn("В кривой energy_consumption_vs_size отсутствуют точки")
		energy_consumption = energy_consumption_vs_size.sample(size)
	elif not Engine.is_editor_hint():
		Log.err("Попытка обновить energy_consumption без кривой energy_consumption_vs_size")


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
	return warnings
