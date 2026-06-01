# test/test_body.gd
extends GutTest

const BODY_CLASS = preload("res://organism/body.gd")
const BODY_SCENE = preload("res://organism/body.tscn")

# =============================================================
# Тесты ограничений переменных (clamping)
# =============================================================


class TestConstraints:
	extends GutTest

	var body: BODY_CLASS


	func before_each() -> void:
		body = BODY_CLASS.new()
		autoqfree(body)


	func test_min_size_clamping() -> void:
		body.min_size = -1.0
		assert_eq(body.min_size, 0.0, "min_size не может быть отрицательным")

		body.min_size = 5.0
		assert_eq(body.min_size, 5.0, "min_size должен установиться в 5.0")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_max_size_clamping() -> void:
		body.max_size = -1.0
		assert_eq(body.max_size, 0.0, "max_size не может быть отрицательным")

		body.max_size = 10.0
		assert_eq(body.max_size, 10.0, "max_size должен установиться в 10.0")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_min_max_size_relationship() -> void:
		# min_size > max_size должно выравнивать max_size
		body.max_size = 1.0
		body.min_size = 5.0
		assert_eq(body.min_size, 5.0)
		assert_eq(body.max_size, 5.0, "max_size должен стать равен min_size")

		# max_size < min_size должно выравнивать min_size
		body.max_size = 1.0
		assert_eq(body.max_size, 1.0)
		assert_eq(body.min_size, 1.0, "min_size должен стать равен max_size")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_size_clamping() -> void:
		body.max_size = 10.0
		body.min_size = 1.0

		body.size = -10.0
		assert_push_error_count(3, "3 кривые отсутствует")
		assert_gte(body.size, body.min_size, "size не может быть меньше min_size")

		body.size = 100.0
		assert_push_error_count(6, "3 кривые отсутствует")
		assert_lte(body.size, body.max_size, "size не может быть больше max_size")

		body.size = 1.5
		assert_push_error_count(9, "3 кривые отсутствует")
		assert_eq(body.size, 1.5, "size должен установиться в 1.5")

		assert_push_warning_count(0)


	func test_negative_energy_consumption_clamped() -> void:
		body.energy_consumption = -50.0
		assert_gte(body.energy_consumption, 0.0, "energy_consumption не может быть отрицательным")
		assert_push_warning_count(1)
		assert_push_error_count(0)


	func test_negative_speed_clamped() -> void:
		body.speed = -30.0
		assert_gte(body.speed, 0.0, "speed не может быть отрицательным")
		assert_push_warning_count(1)
		assert_push_error_count(0)


	func test_negative_rotation_speed_clamped() -> void:
		body.rotation_speed = -45.0
		assert_gte(body.rotation_speed, 0.0, "rotation_speed не может быть отрицательным")
		assert_push_warning_count(1)
		assert_push_error_count(0)

# =============================================================
# Тесты обновления при изменении size
# =============================================================


class TestSizeUpdates:
	extends GutTest

	var body: BODY_CLASS


	func before_each() -> void:
		# добавить тело на сцену
		body = BODY_SCENE.instantiate()
		var root := Node2D.new()
		root.add_child(body)
		body.root = root

		# Создаём тестовые кривые
		var consumption_curve: Curve = Curve.new()
		consumption_curve.min_value = 10.0
		consumption_curve.max_value = 50.0
		body.energy_consumption_vs_size = consumption_curve
		var _err := consumption_curve.add_point(Vector2(0.25, 10.0))
		_err = consumption_curve.add_point(Vector2(2.0, 50.0))

		var speed_curve: Curve = Curve.new()
		speed_curve.min_value = 50.0
		speed_curve.max_value = 200.0
		body.speed_vs_size = speed_curve
		_err = speed_curve.add_point(Vector2(0.25, 200.0))
		_err = speed_curve.add_point(Vector2(2.0, 50.0))

		var rotation_curve: Curve = Curve.new()
		rotation_curve.min_value = 45.0
		rotation_curve.max_value = 180.0
		body.rotation_speed_vs_size = rotation_curve
		_err = rotation_curve.add_point(Vector2(0.25, 180.0))
		_err = rotation_curve.add_point(Vector2(2.0, 45.0))

		add_child_autoqfree(root)


	func test_size_updates_consumption() -> void:
		body.size = 0.25
		assert_eq(body.energy_consumption, 10.0, "При size=0.25 потребление должно быть 10")

		body.size = 2.0
		assert_eq(body.energy_consumption, 50.0, "При size=2.0 потребление должно быть 50")

		body.size = 1.0
		var expected: float = body.energy_consumption_vs_size.sample(1.0)
		assert_eq(body.energy_consumption, expected, "Потребление должно соответствовать кривой")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_size_updates_speed() -> void:
		body.size = 0.25
		assert_eq(body.speed, 200.0, "При size=0.25 скорость должна быть 200")

		body.size = 2.0
		assert_eq(body.speed, 50.0, "При size=2.0 скорость должна быть 50")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_size_updates_rotation_speed() -> void:
		body.size = 0.25
		assert_eq(body.rotation_speed, 180.0, "При size=0.25 скорость вращения должна быть 180")

		body.size = 2.0
		assert_eq(body.rotation_speed, 45.0, "При size=2.0 скорость вращения должна быть 45")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_size_updates_root_scale() -> void:
		var root := body.root

		body.size = 1.5
		assert_eq(root.scale, Vector2(1.5, 1.5), "root.scale должен обновиться")

		body.size = 0.5
		assert_eq(root.scale, Vector2(0.5, 0.5), "root.scale должен обновиться")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_size_updates_without_root_does_not_error() -> void:
		body.root = null
		body.size = 1.5
		assert_eq(body.size, 1.5, "size должен установиться даже без root")
		assert_push_warning_count(1, "потеря корня")
		assert_push_error_count(0)

# =============================================================
# Тесты обновления при изменении кривых
# =============================================================


class TestCurveUpdates:
	extends GutTest

	var body: BODY_CLASS


	func before_each() -> void:
		body = BODY_CLASS.new()
		body.size = 1.0
		autoqfree(body)


	func test_changing_consumption_curve_updates_consumption() -> void:
		var curve: Curve = Curve.new()
		curve.min_value = 5.0
		curve.max_value = 20.0
		curve.min_domain = 0.25
		curve.max_domain = 2.0

		var _err := curve.add_point(Vector2(0.25, 5.0))
		_err = curve.add_point(Vector2(2.0, 20.0))
		body.energy_consumption_vs_size = curve

		var expected: float = curve.sample(1.0)

		assert_eq(body.energy_consumption, expected, "Потребление должно обновиться по новой кривой")

		# Изменяем кривую
		curve.set_point_value(1, 30.0)
		# Нужно подождать сигнал
		await wait_physics_frames(1)

		var new_expected: float = curve.sample(1.0)
		assert_eq(body.energy_consumption, new_expected, "Потребление должно обновиться при изменении кривой")
		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_changing_speed_curve_updates_speed() -> void:
		var curve: Curve = Curve.new()
		curve.min_value = 100.0
		curve.max_value = 300.0
		curve.min_domain = 0.25
		curve.max_domain = 2.0

		var _err := curve.add_point(Vector2(0.25, 100.0))
		_err = curve.add_point(Vector2(2.0, 300.0))
		body.speed_vs_size = curve

		var expected: float = curve.sample(1.0)

		assert_eq(body.speed, expected, "Скорость должна обновиться по новой кривой")

		curve.set_point_value(1, 400.0)
		await wait_physics_frames(1)

		var new_expected: float = curve.sample(1.0)
		assert_eq(body.speed, new_expected, "Скорость должна обновиться при изменении кривой")
		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_changing_rotation_curve_updates_rotation_speed() -> void:
		var curve: Curve = Curve.new()
		curve.min_value = 90.0
		curve.max_value = 360.0
		curve.min_domain = 0.25
		curve.max_domain = 2.0

		var _err := curve.add_point(Vector2(0.25, 360.0))
		_err = curve.add_point(Vector2(2.0, 90.0))
		body.rotation_speed_vs_size = curve

		var expected: float = curve.sample(1.0)

		assert_eq(
			body.rotation_speed,
			expected,
			"Скорость вращения должна обновиться по новой кривой",
		)

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_setting_null_curve_does_not_crash() -> void:
		body.energy_consumption_vs_size = null
		assert_push_error_count(1)

		body.speed_vs_size = null
		assert_push_error_count(2)

		body.rotation_speed_vs_size = null
		assert_push_error_count(3)

		body.size = 1.5
		assert_eq(body.size, 1.5, "size должен установиться")
		assert_push_error_count(6)


	func test_consumption_curve_min_max_domain_updates() -> void:
		var curve: Curve = Curve.new()
		curve.min_value = 10.0
		curve.max_value = 20.0
		curve.min_domain = 0.25
		curve.max_domain = 2.0

		var _err := curve.add_point(Vector2(0.5, 10.0))
		_err = curve.add_point(Vector2(1.5, 20.0))
		body.energy_consumption_vs_size = curve

		assert_eq(curve.min_domain, body.min_size, "min_domain кривой должен синхронизироваться")
		assert_eq(curve.max_domain, body.max_size, "max_domain кривой должен синхронизироваться")

		body.min_size = 0.5
		assert_eq(curve.min_domain, 0.5, "min_domain должен обновиться")

		body.max_size = 3.0
		assert_eq(curve.max_domain, 3.0, "max_domain должен обновиться")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_speed_curve_min_max_domain_updates() -> void:
		var curve: Curve = Curve.new()
		curve.min_value = 10.0
		curve.max_value = 20.0
		curve.min_domain = 0.25
		curve.max_domain = 2.0

		var _err := curve.add_point(Vector2(0.5, 10.0))
		_err = curve.add_point(Vector2(1.5, 20.0))
		body.speed_vs_size = curve

		assert_eq(curve.min_domain, body.min_size, "min_domain кривой должен синхронизироваться")
		assert_eq(curve.max_domain, body.max_size, "max_domain кривой должен синхронизироваться")

		body.min_size = 0.5
		assert_eq(curve.min_domain, 0.5, "min_domain должен обновиться")

		body.max_size = 3.0
		assert_eq(curve.max_domain, 3.0, "max_domain должен обновиться")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_rotation_curve_min_max_domain_updates() -> void:
		var curve: Curve = Curve.new()
		curve.min_value = 10.0
		curve.max_value = 20.0
		curve.min_domain = 0.25
		curve.max_domain = 2.0

		var _err := curve.add_point(Vector2(0.5, 10.0))
		_err = curve.add_point(Vector2(1.5, 20.0))
		body.rotation_speed_vs_size = curve

		assert_eq(curve.min_domain, body.min_size, "min_domain кривой должен синхронизироваться")
		assert_eq(curve.max_domain, body.max_size, "max_domain кривой должен синхронизироваться")

		body.min_size = 0.5
		assert_eq(curve.min_domain, 0.5, "min_domain должен обновиться")

		body.max_size = 3.0
		assert_eq(curve.max_domain, 3.0, "max_domain должен обновиться")

		assert_push_warning_count(0)
		assert_push_error_count(0)

# =============================================================
# Тесты configuration warnings
# =============================================================


class TestConfigurationWarnings:
	extends GutTest

	var body: BODY_CLASS


	func before_each() -> void:
		body = BODY_CLASS.new()
		autoqfree(body)


	func test_warning_when_root_is_null() -> void:
		var warnings := Array(body._get_configuration_warnings())
		var has_warning: bool = warnings.any(func(w: String) -> bool: return "root" in w)
		assert_true(has_warning, "Должно быть предупреждение об отсутствии root")


	func test_no_root_warning_when_root_set() -> void:
		var root := Node2D.new()
		autoqfree(root)
		body.root = root
		var warnings := Array(body._get_configuration_warnings())
		var has_root_warning: bool = warnings.any(
			func(w: String) -> bool: return "root" in w and "отсутствует" in w
		)
		assert_false(has_root_warning, "Предупреждение о root должно исчезнуть")


	func test_warning_when_consumption_curve_missing() -> void:
		var warnings := Array(body._get_configuration_warnings())
		var has_warning: bool = warnings.any(func(w: String) -> bool: return "потребления" in w)
		assert_true(has_warning, "Должно быть предупреждение об отсутствии кривой потребления")


	func test_warning_when_speed_curve_missing() -> void:
		var warnings := Array(body._get_configuration_warnings())
		var has_warning: bool = warnings.any(func(w: String) -> bool: return "скорости" in w)
		assert_true(has_warning, "Должно быть предупреждение об отсутствии кривой скорости")


	func test_warning_when_rotation_curve_missing() -> void:
		var warnings := Array(body._get_configuration_warnings())
		var has_warning: bool = warnings.any(func(w: String) -> bool: return "вращения" in w)
		assert_true(has_warning, "Должно быть предупреждение об отсутствии кривой вращения")


	func test_no_curve_warnings_when_curves_set() -> void:
		body.energy_consumption_vs_size = Curve.new()
		body.speed_vs_size = Curve.new()
		body.rotation_speed_vs_size = Curve.new()

		var warnings := Array(body._get_configuration_warnings())
		var has_curve_warning: bool = warnings.any(func(w: String) -> bool: return "график" in w or "кривая" in w)
		assert_false(has_curve_warning, "Предупреждения о кривых должны исчезнуть")
		assert_push_warning_count(3, "Пустые кривые")

# =============================================================
# Интеграционные тесты
# =============================================================


class TestIntegration:
	extends GutTest

	func test_full_workflow_with_curves() -> void:
		var body: BODY_CLASS = BODY_SCENE.instantiate()
		var root: Node2D = Node2D.new()
		root.add_child(body)
		body.root = root
		body.max_size = 2.0
		body.min_size = 0.5

		# Создаём кривые
		var consumption_curve: Curve = Curve.new()
		consumption_curve.min_value = 10.0
		consumption_curve.max_value = 40.0

		body.energy_consumption_vs_size = consumption_curve
		var _err := consumption_curve.add_point(Vector2(0.5, 10.0))
		_err = consumption_curve.add_point(Vector2(1.0, 20.0))
		_err = consumption_curve.add_point(Vector2(2.0, 40.0))

		var speed_curve: Curve = Curve.new()
		speed_curve.min_value = 100.0
		speed_curve.max_value = 300.0

		body.speed_vs_size = speed_curve
		_err = speed_curve.add_point(Vector2(0.5, 300.0))
		_err = speed_curve.add_point(Vector2(1.0, 200.0))
		_err = speed_curve.add_point(Vector2(2.0, 100.0))

		add_child_autoqfree(root)

		# Изменяем размер
		body.size = 0.5
		assert_eq(body.energy_consumption, 10.0)
		assert_eq(body.speed, 300.0)
		assert_eq(root.scale, Vector2(0.5, 0.5))

		body.size = 1.5
		var expected_consumption: float = consumption_curve.sample(1.5)
		var expected_speed: float = speed_curve.sample(1.5)
		assert_eq(body.energy_consumption, expected_consumption)
		assert_eq(body.speed, expected_speed)
		assert_eq(root.scale, Vector2(1.5, 1.5))

		body.size = 2.0
		assert_eq(body.energy_consumption, 40.0)
		assert_eq(body.speed, 100.0)
