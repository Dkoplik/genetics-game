# test/test_eye.gd
extends GutTest

const EYE_CLASS = preload("res://organism/eye.gd")
const EYE_SCENE = preload("res://organism/eye.tscn")
const NUMERIC = preload("res://etc/numeric.gd")


func test_energy_consumption_cannot_be_negative() -> void:
	var eye: EYE_CLASS = EYE_CLASS.new()
	autoqfree(eye)

	eye.energy_consumption = -10.0
	assert_gte(eye.energy_consumption, 0.0, "energy_consumption не может быть отрицательным")

	eye.energy_consumption = 5.0
	assert_eq(eye.energy_consumption, 5.0, "energy_consumption должен установиться в 5.0")

# =============================================================
# Тесты обработки кривой
# =============================================================


class TestCurveHandling:
	extends GutTest

	var eye: EYE_CLASS


	func before_each() -> void:
		eye = EYE_CLASS.new()
		autoqfree(eye)


	func test_setting_null_curve_does_not_crash() -> void:
		eye.vision_length_vs_width = null
		assert_push_error_count(1, "Потеря кривой")
		assert_null(eye.vision_length_vs_width, "Кривая должна остаться null")
		assert_push_warning_count(0)


	func test_setting_curve_triggers_update() -> void:
		var curve: Curve = Curve.new()
		curve.min_domain = 0.5
		curve.max_domain = 2.0
		curve.min_value = 100.0
		curve.max_value = 300.0

		var _err := curve.add_point(Vector2(0.5, 100.0))
		_err = curve.add_point(Vector2(2.0, 300.0))

		eye.vision_length_vs_width = curve

		assert_eq(eye.vision_length_vs_width, curve, "Кривая должна установиться")
		assert_eq(eye.width_scale, 1.0, "width_scale должен остаться 1.0")
		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_curve_update_updates_length_scale() -> void:
		var curve: Curve = Curve.new()
		curve.min_domain = 0.5
		curve.max_domain = 2.0
		curve.min_value = 100.0
		curve.max_value = 300.0

		var _err := curve.add_point(Vector2(0.5, 100.0))
		_err = curve.add_point(Vector2(2.0, 300.0))

		eye.vision_length_vs_width = curve

		# width_scale = 1.0, должно сэмплироваться значение на X=1.0
		var expected_length: float = curve.sample(1.0)
		assert_eq(eye.length_scale, expected_length, "length_scale должен обновиться по кривой")
		assert_eq(eye.scale.x, expected_length, "scale.x должен обновиться")
		assert_eq(eye.scale.y, 1.0, "scale.y должен быть width_scale")
		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_curve_without_points_triggers_warning() -> void:
		var curve: Curve = Curve.new()
		eye.vision_length_vs_width = curve
		assert_push_warning_count(3, "Предупреждение о пустой кривой и вытекающих последствиях")

		eye.width_scale = 1.5
		assert_push_warning_count(6, "Предупреждение о пустой кривой и вытекающих последствиях")
		assert_push_error_count(0)

# =============================================================
# Тесты width_scale и его ограничений
# =============================================================


class TestWidthScale:
	extends GutTest

	var eye: EYE_CLASS
	var curve: Curve


	func before_each() -> void:
		eye = EYE_CLASS.new()
		autoqfree(eye)

		curve = Curve.new()
		curve.min_domain = 0.5
		curve.max_domain = 2.0
		curve.min_value = 100.0
		curve.max_value = 300.0

		var _err := curve.add_point(Vector2(0.5, 100.0))
		_err = curve.add_point(Vector2(2.0, 300.0))
		eye.vision_length_vs_width = curve


	func test_width_scale_clamped_to_curve_domain() -> void:
		eye.width_scale = 0.3
		assert_eq(eye.width_scale, 0.5, "width_scale не может быть меньше min_domain")

		eye.width_scale = 3.0
		assert_eq(eye.width_scale, 2.0, "width_scale не может быть больше max_domain")

		eye.width_scale = 1.5
		assert_eq(eye.width_scale, 1.5, "width_scale должен установиться в 1.5")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_width_scale_updates_length_scale() -> void:
		eye.width_scale = 0.5
		var expected_length: float = curve.sample(0.5)
		assert_eq(eye.length_scale, expected_length, "length_scale должен обновиться")

		eye.width_scale = 2.0
		expected_length = curve.sample(2.0)
		assert_eq(eye.length_scale, expected_length, "length_scale должен обновиться")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_width_scale_updates_scale() -> void:
		eye.width_scale = 0.75
		var expected_length: float = curve.sample(0.75)
		assert_eq(eye.scale, Vector2(expected_length, 0.75), "scale должен обновиться")

		eye.width_scale = 1.5
		expected_length = curve.sample(1.5)
		assert_eq(eye.scale, Vector2(expected_length, 1.5), "scale должен обновиться")

		assert_push_warning_count(0)
		assert_push_error_count(0)

# =============================================================
# Тесты обновления при изменении кривой
# =============================================================


class TestCurveUpdates:
	extends GutTest

	var eye: EYE_CLASS


	func before_each() -> void:
		eye = EYE_CLASS.new()
		autoqfree(eye)

		var curve: Curve = Curve.new()
		curve.min_domain = 0.5
		curve.max_domain = 2.0
		curve.min_value = 50.0
		curve.max_value = 400.0

		var _err := curve.add_point(Vector2(0.5, 100.0))
		_err = curve.add_point(Vector2(2.0, 300.0))
		eye.vision_length_vs_width = curve
		eye.width_scale = 1.0


	func test_changing_curve_points_updates_values() -> void:
		var curve: Curve = eye.vision_length_vs_width
		var original_length: float = eye.length_scale

		# Изменяем точку на кривой
		curve.set_point_value(1, 500.0)
		await wait_physics_frames(1) # Ждём сигнал

		var expected_length: float = curve.sample(1.0)
		assert_eq(eye.length_scale, expected_length, "length_scale должен обновиться")
		assert_ne(eye.length_scale, original_length, "length_scale должен измениться")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_adding_point_to_curve_updates_values() -> void:
		var curve: Curve = eye.vision_length_vs_width

		# Добавляем новую точку
		var _err := curve.add_point(Vector2(1.5, 400.0))
		await wait_physics_frames(1)

		var expected_length: float = curve.sample(1.0)
		assert_eq(
			eye.length_scale,
			expected_length,
			"length_scale должен обновиться после добавления точки",
		)

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_removing_point_from_curve_updates_values() -> void:
		var curve: Curve = eye.vision_length_vs_width

		# Удаляем точку
		curve.remove_point(1)
		await wait_physics_frames(1)

		var expected_length: float = curve.sample(1.0)
		assert_eq(
			eye.length_scale,
			expected_length,
			"length_scale должен обновиться после удаления точки",
		)

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_replacing_curve_completely_updates_values() -> void:
		var new_curve: Curve = Curve.new()
		var _err := new_curve.add_point(Vector2(0.5, 50.0))
		_err = new_curve.add_point(Vector2(2.0, 150.0))

		eye.vision_length_vs_width = new_curve

		var expected_length: float = new_curve.sample(1.0)
		assert_eq(
			eye.length_scale,
			expected_length,
			"length_scale должен обновиться по новой кривой",
		)
		assert_eq(eye.scale.x, expected_length, "scale.x должен обновиться")

		assert_push_warning_count(0)
		assert_push_error_count(0)

# =============================================================
# Тесты scale и его обновлений
# =============================================================


class TestScale:
	extends GutTest

	var eye: EYE_CLASS
	var curve: Curve


	func before_each() -> void:
		eye = EYE_CLASS.new()
		autoqfree(eye)

		curve = Curve.new()
		curve.min_domain = 0.5
		curve.max_domain = 2.0
		curve.min_value = 100.0
		curve.max_value = 300.0

		var _err := curve.add_point(Vector2(0.5, 100.0))
		_err = curve.add_point(Vector2(2.0, 300.0))
		curve.min_domain = 0.5
		curve.max_domain = 2.0
		eye.vision_length_vs_width = curve


	func test_scale_updates_with_width_scale() -> void:
		var test_values: Array[float] = [0.5, 0.75, 1.0, 1.5, 2.0]

		for width: float in test_values:
			eye.width_scale = width
			var expected_length: float = curve.sample(width)
			assert_eq(
				eye.scale,
				Vector2(expected_length, width),
				"При width_scale=%f scale должен быть (%f, %f)" % [width, expected_length, width],
			)


	func test_very_small_scale_triggers_warning() -> void:
		# Создаём кривую, которая даёт очень маленькие значения
		var small_curve: Curve = Curve.new()
		small_curve.min_domain = 0.1
		small_curve.max_domain = 1.0
		small_curve.min_value = 0.0
		small_curve.max_value = 10.0

		var _err := small_curve.add_point(Vector2(0.1, NUMERIC.EPS * 0.01)) # Очень маленький length
		_err = small_curve.add_point(Vector2(1.0, NUMERIC.EPS * 0.01))

		eye.vision_length_vs_width = small_curve
		assert_push_warning_count(2, "Слишком маленькие значения scale")
		eye.width_scale = 0.5
		assert_push_warning_count(4, "Слишком маленькие значения scale")
		assert_push_error_count(0)

# =============================================================
# Тесты конфигурационных предупреждений
# =============================================================


class TestConfigurationWarnings:
	extends GutTest

	var eye: EYE_CLASS


	func before_each() -> void:
		eye = EYE_CLASS.new()
		autoqfree(eye)


	func test_warning_when_curve_missing() -> void:
		var warnings := Array(eye._get_configuration_warnings())
		var has_warning: bool = warnings.any(func(w: String) -> bool: return "график" in w)
		assert_true(has_warning, "Должно быть предупреждение об отсутствии кривой")


	func test_no_warning_when_curve_present() -> void:
		var curve: Curve = Curve.new()
		eye.vision_length_vs_width = curve

		var warnings := Array(eye._get_configuration_warnings())
		var has_curve_warning: bool = warnings.any(func(w: String) -> bool: return "график" in w)
		assert_false(has_curve_warning, "Предупреждение о кривой должно исчезнуть")

# =============================================================
# Интеграционные тесты
# =============================================================


class TestIntegration:
	extends GutTest

	func test_full_workflow() -> void:
		var eye: EYE_CLASS = EYE_CLASS.new()
		autoqfree(eye)

		# Создаём и устанавливаем кривую
		var curve: Curve = Curve.new()
		curve.min_domain = 0.3
		curve.max_domain = 2.0
		curve.min_value = 50.0
		curve.max_value = 250.0

		var _err := curve.add_point(Vector2(0.3, 50.0))
		_err = curve.add_point(Vector2(1.0, 150.0))
		_err = curve.add_point(Vector2(2.0, 250.0))

		eye.vision_length_vs_width = curve

		# Проверяем начальные значения
		assert_eq(eye.width_scale, 1.0)
		assert_eq(eye.length_scale, curve.sample(1.0))

		# Изменяем width_scale
		eye.width_scale = 0.5
		assert_eq(eye.width_scale, 0.5)
		assert_eq(eye.length_scale, curve.sample(0.5))
		assert_eq(eye.scale, Vector2(curve.sample(0.5), 0.5))

		# Изменяем на максимальное значение
		eye.width_scale = 2.0
		assert_eq(eye.width_scale, 2.0)
		assert_eq(eye.length_scale, curve.sample(2.0))
		assert_eq(eye.scale, Vector2(curve.sample(2.0), 2.0))

		# Пытаемся выйти за пределы
		eye.width_scale = 3.0
		assert_eq(eye.width_scale, 2.0, "Не может выйти за max_domain")

		# Заменяем кривую
		var new_curve: Curve = Curve.new()
		new_curve.min_domain = 0.5
		new_curve.max_domain = 1.5
		new_curve.min_value = 200.0
		new_curve.max_value = 400.0

		_err = new_curve.add_point(Vector2(0.5, 200.0))
		_err = new_curve.add_point(Vector2(1.5, 400.0))
		new_curve.min_domain = 0.5
		new_curve.max_domain = 1.5

		eye.vision_length_vs_width = new_curve

		# width_scale должен быть скорректирован под новую кривую
		assert_eq(eye.width_scale, 1.5, "width_scale должен быть скорректирован")
		assert_eq(eye.length_scale, new_curve.sample(1.5))
		assert_eq(eye.scale, Vector2(new_curve.sample(1.5), 1.5))

		assert_push_warning_count(0)
		assert_push_error_count(0)
