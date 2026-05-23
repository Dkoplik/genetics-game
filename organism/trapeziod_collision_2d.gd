@tool
class_name TrapezoidCollision2D
extends CollisionPolygon2D

## Ширина ближнего основания трапеции.
@export_range(1.0, 100.0, 1.0, "suffix:px", "or_greater")
var near_width: float = 10.0:
	set(value):
		near_width = max(1.0, value)
		update_trapezoid()

## Ширина дальнего основания трапеции.
@export_range(1.0, 700.0, 1.0, "suffix:px", "or_greater")
var far_width: float = 200.0:
	set(value):
		far_width = max(1.0, value)
		update_trapezoid()

## Длина (высота) трапеции.
@export_range(1.0, 1_500.0, 1.0, "suffix:px", "or_greater")
var vision_length: float = 300.0:
	set(value):
		vision_length = max(1.0, value)
		update_trapezoid()

## Смещение ближнего основания.
@export_custom(PROPERTY_HINT_NONE, "suffix:px")
var offset_x: float = 0.0:
	set(value):
		offset_x = value
		update_trapezoid()


func _init() -> void:
	update_trapezoid()


func update_trapezoid() -> void:
	# Ближнее основание
	var near_left := Vector2(offset_x, -near_width / 2.0)
	var near_right := Vector2(offset_x, near_width / 2.0)

	# Дальнее основание
	var far_left := Vector2(vision_length + offset_x, -far_width / 2.0)
	var far_right := Vector2(vision_length + offset_x, far_width / 2.0)

	polygon = PackedVector2Array([near_left, far_left, far_right, near_right])

	# Обновить визуализацию в редакторе
	if Engine.is_editor_hint():
		queue_redraw()
