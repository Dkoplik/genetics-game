@tool
extends Node2D
## Тело организма. Задаёт размер самого тела и основную скорость.

## Корень организма, у которого будет меняться размер.
@export var root: Node2D:
	set(value):
		root = value
		if Engine.is_editor_hint():
			update_configuration_warnings()
		elif root == null:
			Log.warn("Потеря корня организма, размер меняться не будет")

@export var min_size: float = 0.25:
	set(value):
		min_size = max(0.0, value)

		if min_size > max_size:
			max_size = min_size

		if energy_consumption_vs_size != null:
			energy_consumption_vs_size.min_domain = min_size

		if speed_vs_size != null:
			speed_vs_size.min_domain = min_size

		if rotation_speed_vs_size != null:
			rotation_speed_vs_size.min_domain = min_size

@export var max_size: float = 2.0:
	set(value):
		max_size = max(0.0, value)

		if min_size > max_size:
			min_size = max_size

		if energy_consumption_vs_size != null:
			energy_consumption_vs_size.max_domain = max_size

		if speed_vs_size != null:
			speed_vs_size.max_domain = max_size

		if rotation_speed_vs_size != null:
			rotation_speed_vs_size.max_domain = max_size

## Размер организма.
@export var size: float = 1.0:
	set(value):
		size = clampf(value, min_size, max_size)
		_update_consumption()
		_update_speed()
		_update_rotaion_speed()
		if root != null:
			root.scale = Vector2(size, size)

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

## Кривая зависимости между скоростью (Y) и размером (X).
@export var speed_vs_size: Curve:
	set(value):
		if speed_vs_size != null:
			speed_vs_size.changed.disconnect(_update_speed)

		speed_vs_size = value
		_process_curve(speed_vs_size, _update_speed)
		_update_speed()
		if Engine.is_editor_hint():
			update_configuration_warnings()

## Кривая зависимости между скоростью вращения (Y) и размером (X).
@export var rotation_speed_vs_size: Curve:
	set(value):
		if rotation_speed_vs_size != null:
			rotation_speed_vs_size.changed.disconnect(_update_rotaion_speed)

		rotation_speed_vs_size = value
		_process_curve(rotation_speed_vs_size, _update_rotaion_speed)
		_update_rotaion_speed()
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

## Скорость движения.
@export_custom(
	PROPERTY_HINT_NONE,
	"suffix:px/sec",
	PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
)
var speed: float:
	set(value):
		if value < 0.0:
			Log.warn("Попытка сделать speed отрицательным")
			value = 0.0
		speed = value

## Скорость вращения.
@export_custom(
	PROPERTY_HINT_NONE,
	"suffix:deg/sec",
	PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
)
var rotation_speed: float:
	set(value):
		if value < 0.0:
			Log.warn("Попытка сделать rotaion_speed отрицательным")
			value = 0.0
		rotation_speed = value

@onready var sprite: Sprite2D = $BodySprite2D


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if root == null:
		Log.warn("Отсутствует корень организма root, размер не будет меняться")


## Радиус спрайта тела в пикселях с учётом [member scale] от [Sprite2D].
func get_radius() -> float:
	if sprite == null:
		Log.err("Отсутствует Sprite2D для определения размера тела")
		return 0.0
	return scale.x * sprite.scale.x * (sprite.get_rect().size.x / 2.0)


func _update_consumption() -> void:
	if energy_consumption_vs_size != null:
		if energy_consumption_vs_size.point_count == 0:
			Log.warn("В кривой energy_consumption_vs_size отсутствуют точки")
		energy_consumption = energy_consumption_vs_size.sample(size)
	elif not Engine.is_editor_hint():
		Log.err("Попытка обновить energy_consumption без кривой energy_consumption_vs_size")


func _update_speed() -> void:
	if speed_vs_size != null:
		if speed_vs_size.point_count == 0:
			Log.warn("В кривой speed_vs_size отсутствуют точки")
		speed = speed_vs_size.sample(size)
	elif not Engine.is_editor_hint():
		Log.err("Попытка обновить speed без кривой speed_vs_size")


func _update_rotaion_speed() -> void:
	if rotation_speed_vs_size != null:
		if rotation_speed_vs_size.point_count == 0:
			Log.warn("В кривой rotation_speed_vs_size отсутствуют точки")
		rotation_speed = rotation_speed_vs_size.sample(size)
	elif not Engine.is_editor_hint():
		Log.err("Попытка обновить rotation_speed без кривой rotation_speed_vs_size")


func _process_curve(curve: Curve, updater: Callable) -> void:
	if curve == null:
		return

	curve.min_domain = min_size
	curve.max_domain = max_size
	var _err: int = curve.changed.connect(updater)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if root == null:
		var _tmp: bool = warnings.append("Отсутствует корень организма root, размер не будет меняться")
	if energy_consumption_vs_size == null:
		var _tmp: bool = warnings.append("Отсутствует график зависимости потребления от размера")
	if speed_vs_size == null:
		var _tmp: bool = warnings.append("Отсутствует график зависимости скорости от размера")
	if rotation_speed_vs_size == null:
		var _tmp: bool = warnings.append(
			"Отсутствует график зависимости скорости вращения от размера",
		)
	return warnings
