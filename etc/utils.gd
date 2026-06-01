class_name Utils


static func get_world_border() -> Rect2:
	return Rect2(-2000.0, -2000.0, 2000.0, 2000.0)


static func get_world_random_point() -> Vector2:
	return get_rect_random_point(get_world_border())


static func get_rect_random_point(rect: Rect2) -> Vector2:
	var x: float = randf_range(rect.position.x, rect.end.x)
	var y: float = randf_range(rect.position.y, rect.end.y)
	return Vector2(x, y)
