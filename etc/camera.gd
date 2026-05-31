extends Camera2D

@export var move_speed: float = 1000.0
@export var zoom_delta: Vector2 = Vector2(0.15, 0.15)


func _process(delta: float) -> void:
	var direction := Vector2.ZERO
	if Input.is_action_pressed(&"move_left"):
		direction.x -= 1
	if Input.is_action_pressed(&"move_up"):
		direction.y -= 1
	if Input.is_action_pressed(&"move_right"):
		direction.x += 1
	if Input.is_action_pressed(&"move_down"):
		direction.y += 1
	position += delta * move_speed * direction


func _unhandled_input(event: InputEvent) -> void:
	# zoom лучше через множитель, иначе он работает не равномерно
	if event.is_action_pressed(&"zoom_in"):
		zoom *= (Vector2.ONE + zoom_delta)
	if event.is_action_pressed(&"zoom_out"):
		zoom *= (Vector2.ONE - zoom_delta)
