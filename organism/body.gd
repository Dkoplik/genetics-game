@tool
class_name OrganismBody
extends Node2D
## Тело организма. Задаёт размер самого тела и основную скорость.

## Корень организма, у которого будет меняться размер.
@export var root: Node2D

@export var min_size: float = 0.25:
	set(value):
		min_size = max(0.0, value)

		if min_size > max_size:
			max_size = min_size

		if energy_consumption_vs_size != null:
			energy_consumption_vs_size.min_domain = min_size

		if speed_vs_size != null:
			speed_vs_size.min_domain = min_size

@export var max_size: float = 2.0:
	set(value):
		max_size = max(0.0, value)

		if min_size > max_size:
			min_size = max_size

		if energy_consumption_vs_size != null:
			energy_consumption_vs_size.min_domain = max_size

		if speed_vs_size != null:
			speed_vs_size.min_domain = max_size

## Размер организма.
@export var size: float = 1.0:
	set(value):
		size = clampf(value, min_size, max_size)
		_update_consumption()
		_update_speed()
		if root != null:
			root.scale = Vector2(size, size)

## Кривая зависимости между потреблением энергии (Y) и размером (X).
@export var energy_consumption_vs_size: Curve:
	set(value):
		if energy_consumption_vs_size:
			energy_consumption_vs_size.changed.disconnect(_update_consumption)

		energy_consumption_vs_size = value
		_process_curve(energy_consumption_vs_size, _update_consumption)

## Кривая зависимости между скоростью (Y) и размером (X).
@export var speed_vs_size: Curve:
	set(value):
		if speed_vs_size:
			speed_vs_size.changed.disconnect(_update_speed)

		speed_vs_size = value
		_process_curve(speed_vs_size, _update_speed)

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

@onready var sprite: Sprite2D = $BodySprite2D

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if root == null:
		Log.warn("Отсутствует корень организма root, размер не будет меняться")

	var _err: int
	if not energy_consumption_vs_size.changed.is_connected(_update_consumption):
		Log.debug("energy_consumption_vs_size не соединён с _update_consumption на момент _ready")
		_err = energy_consumption_vs_size.changed.connect(_update_consumption)

	if not speed_vs_size.changed.is_connected(_update_speed):
		Log.debug("speed_vs_size не соединён с _update_speed на момент _ready")
		_err = speed_vs_size.changed.connect(_update_speed)


## Радиус спрайта тела в пикселях с учётом [member scale] от [Sprite2D].
func get_radius() -> float:
	return scale.x * (sprite.get_rect().size.x / 2.0)


## Возвращает суммарное потребление энергии со всеми органами.
func get_total_consumption() -> float:
	var sum: float = energy_consumption
	for child: Node in get_children():
		if child.name == "BodySprite2D" or child.name == "BodyShape2D":
			continue

		var energy: Variant = child.get("energy_consumption")
		if energy == null:
			Log.warn("Найден орган без energy_consumption:", child.name, child)
			continue

		if energy is not float:
			Log.warn(
				"Найден орган с energy_consumption, но типа",
				type_string(typeof(energy)),
				"вместо float:",
				child.name,
				child,
			)
			continue

		var value: float = energy
		sum += value
	return sum


func _update_consumption() -> void:
	if energy_consumption_vs_size != null and energy_consumption_vs_size.point_count > 0:
		energy_consumption = energy_consumption_vs_size.sample(size)
	elif not Engine.is_editor_hint():
		Log.err("Кривая energy_consumption_vs_size не задана")


func _update_speed() -> void:
	if speed_vs_size != null and speed_vs_size.point_count > 0:
		speed = speed_vs_size.sample(size)
	elif not Engine.is_editor_hint():
		Log.err("Кривая speed_vs_size не задана")


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
	return warnings
