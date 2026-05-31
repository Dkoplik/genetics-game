@tool
extends Area2D

const NUMERIC = preload("res://etc/numeric.gd")

## Потребление энергии в секунду.
@export_custom(PROPERTY_HINT_NONE, "suffix:per sec")
var energy_consumption: float = 0.2:
	set(value):
		energy_consumption = max(0.0, value)

## Текущий масштаб ширины взгляда. По значению этой переменной определяется
## дальность взгляда (см. [member vision_length_vs_width]).
@export var width_scale: float = 1.0:
	set(value):
		if vision_length_vs_width == null:
			if not Engine.is_editor_hint():
				Log.error(
					"Кривая vision_length_vs_width отсутствует, невозможно поменять зрение глаза",
				)
			return

		var min_width: float = vision_length_vs_width.min_domain
		var max_width: float = vision_length_vs_width.max_domain
		width_scale = clamp(value, min_width, max_width)

		if vision_length_vs_width.point_count == 0 and not Engine.is_editor_hint():
			Log.warn("Кривая vision_length_vs_width не содержит точек")

		length_scale = vision_length_vs_width.sample(width_scale)

		scale = Vector2(length_scale, width_scale)
		if scale.x <= NUMERIC.EPS or scale.y <= NUMERIC.EPS:
			Log.warn("Крайне малый scale =", scale)

## Масштаб дальности зрения. Автоматически определяется по [member width_scale] и
## [member vision_length_vs_width].
@export_custom(
	PROPERTY_HINT_NONE,
	"",
	PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
)
var length_scale: float:
	set(value):
		if value <= NUMERIC.EPS and not Engine.is_editor_hint():
			Log.warn("length_scale отрицательный или нулевой:", length_scale)
		length_scale = value

## Кривая зависимости между дальностью (Y) зрения и его шириной (X).
## Сами значения обозначают коэффициент масштаба [member Node2D.scale].
@export var vision_length_vs_width: Curve:
	set(value):
		if vision_length_vs_width != null:
			vision_length_vs_width.changed.disconnect(_update_width)

		vision_length_vs_width = value
		if vision_length_vs_width == null:
			if not Engine.is_editor_hint():
				Log.err("Потеря кривой vision_length_vs_width")
			return

		var _err: int = vision_length_vs_width.changed.connect(_update_width)
		_update_width()
		if Engine.is_editor_hint():
			update_configuration_warnings()


func _update_width() -> void:
	width_scale = width_scale # костыль для вызова сеттера


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if vision_length_vs_width == null:
		var _tmp: bool = warnings.append(
			"Отсутствует график зависимости дальности взгляда от ширины",
		)
	return warnings
