@tool
class_name PolarContainer
extends Node2D
## Контейнер для позиционирования в полярных координатах.
##
## Размещает дочерние объекты под углом [member angle] на расстоянии [member radius],
## и направляет дочерние узлы по направлению от центра (вдоль радиуса).

@export var radius: float = 25.0:
	set(value):
		radius = max(0.0, value)
		_update_position()

@export_range(-360.0, 360.0, 1.0, "suffix:deg") var angle_degrees: float = 0.0:
	set(value):
		angle_degrees = value
		_update_position()


func _update_position() -> void:
	var x: float = cos(deg_to_rad(angle_degrees)) * radius
	var y: float = sin(deg_to_rad(angle_degrees)) * radius
	position = Vector2(x, y)

	for child: Node in get_children():
		if child is not Node2D:
			continue
		var child_2d: Node2D = child
		child_2d.rotation_degrees = angle_degrees
