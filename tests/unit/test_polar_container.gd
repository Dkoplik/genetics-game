# test/test_polar_container.gd
extends GutTest

const NUMERIC := preload("res://etc/numeric.gd")


func test_radius_cannot_be_negative() -> void:
	var container: PolarContainer = PolarContainer.new()
	autoqfree(container)

	container.radius = -10.0
	assert_almost_eq(container.radius, 0.0, NUMERIC.EPS, "radius не может быть отрицательным")

	container.radius = 50.0
	assert_almost_eq(container.radius, 50.0, NUMERIC.EPS, "radius должен установиться в 50.0")

# =============================================================
# Тесты позиционирования
# =============================================================


class TestPositioning:
	extends GutTest

	var container: PolarContainer


	func before_each() -> void:
		container = PolarContainer.new()
		autoqfree(container)


	func test_position_at_angle_0_degrees() -> void:
		container.radius = 100.0
		container.angle_degrees = 0.0

		# cos(0) = 1, sin(0) = 0
		assert_almost_eq(
			container.position,
			Vector2(100.0, 0.0),
			Vector2(NUMERIC.EPS, NUMERIC.EPS),
			"При угле 0° позиция должна быть (radius, 0)",
		)


	func test_position_at_angle_90_degrees() -> void:
		container.radius = 100.0
		container.angle_degrees = 90.0

		# cos(90°) = 0, sin(90°) = 1
		assert_almost_eq(
			container.position,
			Vector2(0.0, 100.0),
			Vector2(NUMERIC.EPS, NUMERIC.EPS),
			"При угле 90° позиция должна быть (0, radius)",
		)


	func test_position_at_angle_180_degrees() -> void:
		container.radius = 100.0
		container.angle_degrees = 180.0

		# cos(180°) = -1, sin(180°) = 0
		assert_almost_eq(
			container.position,
			Vector2(-100.0, 0.0),
			Vector2(NUMERIC.EPS, NUMERIC.EPS),
			"При угле 180° позиция должна быть (-radius, 0)",
		)


	func test_position_at_angle_270_degrees() -> void:
		container.radius = 100.0
		container.angle_degrees = 270.0

		# cos(270°) = 0, sin(270°) = -1
		assert_almost_eq(
			container.position,
			Vector2(0.0, -100.0),
			Vector2(NUMERIC.EPS, NUMERIC.EPS),
			"При угле 270° позиция должна быть (0, -radius)",
		)


	func test_position_at_angle_45_degrees() -> void:
		container.radius = 100.0
		container.angle_degrees = 45.0

		var expected_x: float = cos(deg_to_rad(45.0)) * 100.0
		var expected_y: float = sin(deg_to_rad(45.0)) * 100.0

		assert_almost_eq(
			container.position,
			Vector2(expected_x, expected_y),
			Vector2(NUMERIC.EPS, NUMERIC.EPS),
			"При угле 45° позиция должна рассчитываться правильно",
		)


	func test_position_updates_when_radius_changes() -> void:
		container.angle_degrees = 60.0
		container.radius = 50.0

		var expected: Vector2 = Vector2(
			cos(deg_to_rad(60.0)) * 50.0,
			sin(deg_to_rad(60.0)) * 50.0,
		)
		assert_almost_eq(
			container.position,
			expected,
			Vector2(NUMERIC.EPS, NUMERIC.EPS),
			"При изменении radius позиция должна обновиться",
		)

		container.radius = 150.0
		expected = Vector2(
			cos(deg_to_rad(60.0)) * 150.0,
			sin(deg_to_rad(60.0)) * 150.0,
		)
		assert_almost_eq(
			container.position,
			expected,
			Vector2(NUMERIC.EPS, NUMERIC.EPS),
			"После изменения radius позиция должна пересчитаться",
		)


	func test_position_updates_when_angle_changes() -> void:
		container.radius = 75.0
		container.angle_degrees = 30.0

		var expected: Vector2 = Vector2(
			cos(deg_to_rad(30.0)) * 75.0,
			sin(deg_to_rad(30.0)) * 75.0,
		)
		assert_almost_eq(
			container.position,
			expected,
			Vector2(NUMERIC.EPS, NUMERIC.EPS),
			"При изменении angle позиция должна обновиться",
		)

		container.angle_degrees = 120.0
		expected = Vector2(
			cos(deg_to_rad(120.0)) * 75.0,
			sin(deg_to_rad(120.0)) * 75.0,
		)
		assert_almost_eq(
			container.position,
			expected,
			Vector2(NUMERIC.EPS, NUMERIC.EPS),
			"После изменения angle позиция должна пересчитаться",
		)


	func test_position_with_zero_radius() -> void:
		container.radius = 0.0
		container.angle_degrees = 45.0

		assert_almost_eq(
			container.position,
			Vector2.ZERO,
			Vector2(NUMERIC.EPS, NUMERIC.EPS),
			"При radius = 0 позиция всегда должна быть Vector2.ZERO",
		)


	func test_position_with_negative_radius_becomes_zero() -> void:
		container.radius = -50.0
		container.angle_degrees = 45.0

		# radius должен стать 0.0 из-за max(0.0, value)
		assert_almost_eq(
			container.radius,
			0.0,
			NUMERIC.EPS,
			"Отрицательный radius должен стать 0",
		)
		assert_almost_eq(
			container.position,
			Vector2.ZERO,
			Vector2(NUMERIC.EPS, NUMERIC.EPS),
			"При отрицательном radius позиция должна быть Vector2.ZERO",
		)

# =============================================================
# Тесты поворота дочерних узлов
# =============================================================


class TestChildRotation:
	extends GutTest

	var container: PolarContainer


	func before_each() -> void:
		container = PolarContainer.new()
		autoqfree(container)


	func test_child_node2d_rotation_updates() -> void:
		var child: Node2D = Node2D.new()
		container.add_child(child)

		container.angle_degrees = 45.0
		assert_almost_eq(
			child.rotation_degrees,
			45.0,
			NUMERIC.EPS,
			"Дочерний Node2D должен поворачиваться на угол контейнера",
		)

		container.angle_degrees = 120.0
		assert_almost_eq(
			child.rotation_degrees,
			120.0,
			NUMERIC.EPS,
			"Дочерний Node2D должен обновить поворот при изменении угла",
		)


	func test_multiple_children_rotate() -> void:
		var child1: Node2D = Node2D.new()
		var child2: Node2D = Node2D.new()
		var child3: Node2D = Node2D.new()

		container.add_child(child1)
		container.add_child(child2)
		container.add_child(child3)

		container.angle_degrees = 75.0

		assert_almost_eq(child1.rotation_degrees, 75.0, NUMERIC.EPS)
		assert_almost_eq(child2.rotation_degrees, 75.0, NUMERIC.EPS)
		assert_almost_eq(child3.rotation_degrees, 75.0, NUMERIC.EPS)


	func test_non_node2d_children_are_ignored() -> void:
		# Создаём дочерние узлы, не являющиеся Node2D
		var control_child: Control = Control.new()
		var node_child: Node = Node.new()
		var node2d_child: Node2D = Node2D.new() # Этот должен поворачиваться

		container.add_child(control_child)
		container.add_child(node_child)
		container.add_child(node2d_child)

		container.angle_degrees = 90.0

		# Node2D должен повернуться
		assert_almost_eq(
			node2d_child.rotation_degrees,
			90.0,
			NUMERIC.EPS,
			"Node2D должен поворачиваться",
		)

		# Control и Node не должны повернуться (у них нет rotation_degrees)
		# Просто проверяем, что ошибок нет
		assert_not_null(control_child, "Control должен существовать")
		assert_not_null(node_child, "Node должен существовать")


	func test_children_rotate_when_radius_changes() -> void:
		var child: Node2D = Node2D.new()
		container.add_child(child)

		container.angle_degrees = 30.0
		container.radius = 50.0

		# Должны повернуться при изменении radius, потому что вызывается _update_position()
		assert_almost_eq(
			child.rotation_degrees,
			30.0,
			NUMERIC.EPS,
			"Дочерний узел должен сохранять поворот при изменении radius",
		)


	func test_children_rotate_when_both_properties_change() -> void:
		var child: Node2D = Node2D.new()
		container.add_child(child)

		container.radius = 100.0
		container.angle_degrees = 60.0

		assert_almost_eq(
			child.rotation_degrees,
			60.0,
			NUMERIC.EPS,
			"Дочерний узел должен повернуться на 60°",
		)

		container.radius = 200.0
		container.angle_degrees = 150.0

		assert_almost_eq(
			child.rotation_degrees,
			150.0,
			NUMERIC.EPS,
			"Дочерний узел должен обновить поворот до 150°",
		)


	func test_new_child_receives_current_rotation() -> void:
		container.angle_degrees = 80.0
		add_child(container) # без дерева нет сигналов о новых узнал

		var child: Node2D = Node2D.new()
		container.add_child(child)

		assert_almost_eq(
			child.rotation_degrees,
			80.0,
			NUMERIC.EPS,
			"Новый дочерний узел должен получить текущий угол после обновления",
		)


	func test_deeply_nested_children() -> void:
		var child: Node2D = Node2D.new()
		var grandchild: Node2D = Node2D.new()

		container.add_child(child)
		child.add_child(grandchild)

		container.angle_degrees = 45.0

		# Только прямые потомки должны поворачиваться
		assert_almost_eq(child.rotation_degrees, 45.0, NUMERIC.EPS, "Прямой потомок должен повернуться")

		# Внуки не должны поворачиваться автоматически (если только они не в контейнере)
		assert_almost_ne(
			grandchild.rotation_degrees,
			45.0,
			NUMERIC.EPS,
			"Внуки не должны автоматически поворачиваться",
		)

# =============================================================
# Тесты углов с отрицательными значениями
# =============================================================


class TestNegativeAngles:
	extends GutTest

	var container: PolarContainer


	func before_each() -> void:
		container = PolarContainer.new()
		container.radius = 100.0
		autoqfree(container)


	func test_negative_angle_minus_45_degrees() -> void:
		container.angle_degrees = -45.0

		var expected_x: float = cos(deg_to_rad(-45.0)) * 100.0
		var expected_y: float = sin(deg_to_rad(-45.0)) * 100.0

		assert_almost_eq(
			container.position,
			Vector2(expected_x, expected_y),
			Vector2(NUMERIC.EPS, NUMERIC.EPS),
			"Угол -45° должен корректно обрабатываться",
		)


	func test_negative_angle_minus_90_degrees() -> void:
		container.angle_degrees = -90.0

		var expected_x: float = cos(deg_to_rad(-90.0)) * 100.0
		var expected_y: float = sin(deg_to_rad(-90.0)) * 100.0

		assert_almost_eq(
			container.position,
			Vector2(expected_x, expected_y),
			Vector2(NUMERIC.EPS, NUMERIC.EPS),
			"Угол -90° должен корректно обрабатываться",
		)


	func test_negative_angle_with_child_rotation() -> void:
		var child: Node2D = Node2D.new()
		container.add_child(child)

		container.angle_degrees = -120.0

		assert_almost_eq(
			child.rotation_degrees,
			-120.0,
			NUMERIC.EPS,
			"Дочерний узел должен повернуться на отрицательный угол",
		)

# =============================================================
# Тесты углов за пределами 360°
# =============================================================


class TestAnglesBeyond360:
	extends GutTest

	var container: PolarContainer


	func before_each() -> void:
		container = PolarContainer.new()
		container.radius = 100.0
		autoqfree(container)


	func test_angle_400_degrees() -> void:
		# 400° эквивалентно 40°
		container.angle_degrees = 400.0

		var expected_x: float = cos(deg_to_rad(400.0)) * 100.0
		var expected_y: float = sin(deg_to_rad(400.0)) * 100.0

		assert_almost_eq(
			container.position,
			Vector2(expected_x, expected_y),
			Vector2(NUMERIC.EPS, NUMERIC.EPS),
			"Угол 400° должен обрабатываться (эквивалентно 40°)",
		)


	func test_angle_720_degrees() -> void:
		container.angle_degrees = 720.0

		var expected_x: float = cos(deg_to_rad(720.0)) * 100.0
		var expected_y: float = sin(deg_to_rad(720.0)) * 100.0

		assert_almost_eq(
			container.position,
			Vector2(expected_x, expected_y),
			Vector2(NUMERIC.EPS, NUMERIC.EPS),
			"Угол 720° должен обрабатываться (эквивалентно 0°)",
		)


	func test_angle_minus_400_degrees() -> void:
		container.angle_degrees = -400.0

		var expected_x: float = cos(deg_to_rad(-400.0)) * 100.0
		var expected_y: float = sin(deg_to_rad(-400.0)) * 100.0

		assert_almost_eq(
			container.position,
			Vector2(expected_x, expected_y),
			Vector2(NUMERIC.EPS, NUMERIC.EPS),
			"Угол -400° должен обрабатываться",
		)

# =============================================================
# Интеграционные тесты
# =============================================================


class TestIntegration:
	extends GutTest

	func test_multiple_containers_independent() -> void:
		var container1: PolarContainer = PolarContainer.new()
		autoqfree(container1)

		var container2: PolarContainer = PolarContainer.new()
		autoqfree(container2)

		container1.radius = 50.0
		container1.angle_degrees = 30.0

		container2.radius = 100.0
		container2.angle_degrees = 60.0

		var expected1: Vector2 = Vector2(
			cos(deg_to_rad(30.0)) * 50.0,
			sin(deg_to_rad(30.0)) * 50.0,
		)
		var expected2: Vector2 = Vector2(
			cos(deg_to_rad(60.0)) * 100.0,
			sin(deg_to_rad(60.0)) * 100.0,
		)

		assert_almost_eq(
			container1.position,
			expected1,
			Vector2(NUMERIC.EPS, NUMERIC.EPS),
			"Первый контейнер должен иметь свою позицию",
		)

		assert_almost_eq(
			container2.position,
			expected2,
			Vector2(NUMERIC.EPS, NUMERIC.EPS),
			"Второй контейнер должен иметь свою позицию",
		)


	func test_nested_polar_containers() -> void:
		var parent: PolarContainer = PolarContainer.new()
		autoqfree(parent)

		var child: PolarContainer = PolarContainer.new()

		parent.add_child(child)

		parent.radius = 100.0
		parent.angle_degrees = 45.0

		child.radius = 50.0
		child.angle_degrees = 90.0

		# Родитель должен быть на своей позиции
		var parent_expected: Vector2 = Vector2(
			cos(deg_to_rad(45.0)) * 100.0,
			sin(deg_to_rad(45.0)) * 100.0,
		)
		assert_almost_eq(parent.position, parent_expected, Vector2(NUMERIC.EPS, NUMERIC.EPS))

		# Ребёнок должен быть на позиции относительно родителя
		var child_expected: Vector2 = Vector2(
			cos(deg_to_rad(90.0)) * 50.0,
			sin(deg_to_rad(90.0)) * 50.0,
		)
		assert_almost_eq(child.position, child_expected, Vector2(NUMERIC.EPS, NUMERIC.EPS))

		# Ребёнок должен быть повёрнут на свой угол (не на угол родителя)
		assert_almost_eq(
			child.angle_degrees,
			90.0,
			NUMERIC.EPS,
			"Ребёнок должен сохранять свой угол поворота",
		)
