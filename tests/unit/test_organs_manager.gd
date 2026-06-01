extends GutTest

const ORGANISM_BODY_SCENE: PackedScene = preload("res://organism/body.tscn")
const ORGANISM_BODY = preload("res://organism/body.gd")

const ORGANISM_EYE_SCENE: PackedScene = preload("res://organism/eye.tscn")
const ORGANISM_EYE = preload("res://organism/eye.gd")

const ORGANS_MANAGER = preload("res://organism/organs_manager.gd")


func test_init_manager() -> void:
	var body: ORGANISM_BODY = ORGANISM_BODY_SCENE.instantiate()
	body.name = "Body"

	var organs_manager := ORGANS_MANAGER.new()
	organs_manager.add_child(body)
	organs_manager.body = body
	body.root = organs_manager
	add_child_autoqfree(organs_manager)

	assert_eq(organs_manager.count_organs(), 1)
	assert_eq(organs_manager.get_child_count(), 1)
	assert_true(organs_manager.get_child(0) is ORGANISM_BODY)

	assert_push_warning_count(0)
	assert_push_error_count(0)


class TestParseGenome:
	extends GutTest

	var body: ORGANISM_BODY
	var organs_manager: ORGANS_MANAGER


	func before_each() -> void:
		body = ORGANISM_BODY_SCENE.instantiate()
		body.name = "Body"

		organs_manager = ORGANS_MANAGER.new()
		organs_manager.add_child(body)
		organs_manager.body = body
		body.root = organs_manager
		add_child_autoqfree(organs_manager)


	func test_parse_empty_genome() -> void:
		var warnings := Array(organs_manager.parse_genome([]))

		assert_true(warnings.has("Отсутствуют гены для тела организма"))
		assert_not_null(body, "Пустой геном не должен удалять тело")

		assert_push_warning_count(1)
		assert_push_error_count(0)


	func test_parse_body_genome() -> void:
		assert_ne(body.size, 2.0)

		var genome: Array[Gene] = [
			Gene.new(&"body", &"size", 0, 2.0),
		]
		var warnings: PackedStringArray = organs_manager.parse_genome(genome)

		assert_eq(body.size, 2.0, "Размер тела должен поменяться под геном")
		assert_true(warnings.is_empty(), "Не должно быть предупреждений")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_no_body_size_warning() -> void:
		var genome: Array[Gene] = [
			Gene.new(&"body", &"random_name", 0, 2.0),
		]
		var warnings: PackedStringArray = organs_manager.parse_genome(genome)

		assert_not_null(body, "Геном без размера тела не должен удалять тело")
		assert_eq(warnings.size(), 1, "Предупреждение об отсутствии размера тела в геноме")
		assert_has(warnings, "В геноме для тела организма отсутствует параметр размера &'size'")

		assert_push_warning_count(1)
		assert_push_error_count(0)


	func test_several_bodies_warning() -> void:
		assert_ne(body.size, 2.0)

		var genome: Array[Gene] = [
			Gene.new(&"body", &"size", 0, 2.0),
			Gene.new(&"body", &"size", 1, 0.5),
		]
		var warnings: PackedStringArray = organs_manager.parse_genome(genome)

		assert_not_null(body, "Геном с несколькими телами не должен удалять тело")
		assert_eq(body.size, 2.0, "Размер тела должен измениться под 0-ой геном")
		assert_eq(warnings.size(), 1, "Предупреждение о нескольких генах с телом")
		assert_has(warnings, "Несколько геномов для тела организма или его индекс больше 0")

		assert_push_warning_count(1)
		assert_push_error_count(0)


	func test_parse_single_eye_genome() -> void:
		var genome: Array[Gene] = [
			Gene.new(&"body", &"size", 0, 1.0),
			Gene.new(&"eye", &"angle", 0, 45.0),
			Gene.new(&"eye", &"width_scale", 0, 1.5),
		]
		var warnings: PackedStringArray = organs_manager.parse_genome(genome)
		var eye_container: PolarContainer
		for child: Node in organs_manager.get_children():
			if child is PolarContainer:
				eye_container = child
				break

		assert_true(warnings.is_empty(), "Не должно быть предупреждений")
		assert_eq(eye_container.angle_degrees, 45.0, "Угол должен совпадать с геном")
		assert_eq(eye_container.get_child_count(), 1, "В контейнере должен быть только глаз")

		var eye: ORGANISM_EYE = eye_container.get_child(0)
		assert_not_null(eye, "В контейнере должен быть глаз")
		assert_eq(eye.width_scale, 1.5, "Масштаб должен быть как в геноме")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_parse_single_eye_with_no_angle() -> void:
		var genome: Array[Gene] = [
			Gene.new(&"body", &"size", 0, 1.0),
			Gene.new(&"eye", &"width_scale", 0, 1.5),
		]
		var warnings: PackedStringArray = organs_manager.parse_genome(genome)
		var eye_container: PolarContainer
		for child: Node in organs_manager.get_children():
			if child is PolarContainer:
				eye_container = child
				break

		assert_eq(warnings.size(), 1, "Должно быть предупреждение об отсутствии угла")
		assert_has(warnings, "В геноме для глаза отсутствует параметр угла &'angle'")

		assert_not_null(eye_container, "Глаз не должен пропасть при неполном геноме")
		assert_eq(eye_container.angle_degrees, 0.0, "Угол не должен был поменяться")
		assert_eq(eye_container.get_child_count(), 1, "В контейнере должен быть только глаз")

		var eye: ORGANISM_EYE = eye_container.get_child(0)
		assert_not_null(eye, "В контейнере должен быть глаз")
		assert_eq(eye.width_scale, 1.5, "Масштаб должен быть как в геноме")

		assert_push_warning_count(1)
		assert_push_error_count(0)


	func test_parse_single_eye_with_no_width_scale() -> void:
		var genome: Array[Gene] = [
			Gene.new(&"body", &"size", 0, 1.0),
			Gene.new(&"eye", &"angle", 0, 45.0),
		]
		var warnings: PackedStringArray = organs_manager.parse_genome(genome)
		var eye_container: PolarContainer
		for child: Node in organs_manager.get_children():
			if child is PolarContainer:
				eye_container = child
				break

		assert_eq(warnings.size(), 1, "Должно быть предупреждение об отсутствии угла")
		assert_has(warnings, "В геноме для глаза отсутствует параметр ширины зрения &'width_scale'")

		assert_not_null(eye_container, "Глаз не должен пропасть при неполном геноме")
		assert_eq(eye_container.angle_degrees, 45.0, "Угол должен быть как в геноме")
		assert_eq(eye_container.get_child_count(), 1, "В контейнере должен быть только глаз")

		var eye: ORGANISM_EYE = eye_container.get_child(0)
		assert_not_null(eye, "В контейнере должен быть глаз")
		assert_eq(eye.width_scale, 1.0, "Масштаб должен быть по-умолчанию")

		assert_push_warning_count(1)
		assert_push_error_count(0)


	func test_parse_more_eyes_genome() -> void:
		var genome: Array[Gene] = [
			Gene.new(&"body", &"size", 0, 1.0),
			Gene.new(&"eye", &"angle", 0, 45.0),
			Gene.new(&"eye", &"width_scale", 0, 1.5),
		]
		var warnings: PackedStringArray = organs_manager.parse_genome(genome)

		assert_true(warnings.is_empty(), "Не должно быть предупреждений")

		genome = [
			Gene.new(&"body", &"size", 0, 1.0),
			Gene.new(&"eye", &"angle", 0, 45.0),
			Gene.new(&"eye", &"width_scale", 0, 1.5),
			Gene.new(&"eye", &"angle", 1, -45.0),
			Gene.new(&"eye", &"width_scale", 1, 0.5),
		]
		warnings = organs_manager.parse_genome(genome)

		assert_true(warnings.is_empty(), "Не должно быть предупреждений")
		assert_eq(organs_manager.count_organs(), 3, "Должно быть 1 тело и 2 глаза")

		var eye_container1: PolarContainer = null
		var eye_container2: PolarContainer = null
		for child: Node in organs_manager.get_children():
			if child is PolarContainer:
				if eye_container1 == null:
					eye_container1 = child
				else:
					eye_container2 = child
					break

		if eye_container1.angle_degrees != 45.0:
			var tmp: PolarContainer = eye_container1
			eye_container1 = eye_container2
			eye_container2 = tmp

		assert_eq(eye_container1.angle_degrees, 45.0, "Угол должен совпадать с геном")
		assert_eq(eye_container1.get_child_count(), 1, "В контейнере должен быть только глаз")
		assert_eq(eye_container2.angle_degrees, -45.0, "Угол должен совпадать с геном")
		assert_eq(eye_container2.get_child_count(), 1, "В контейнере должен быть только глаз")

		var eye1: ORGANISM_EYE = eye_container1.get_child(0)
		assert_not_null(eye1, "В контейнере должен быть глаз")
		assert_eq(eye1.width_scale, 1.5, "Масштаб должен быть как в геноме")

		var eye2: ORGANISM_EYE = eye_container2.get_child(0)
		assert_not_null(eye2, "В контейнере должен быть глаз")
		assert_eq(eye2.width_scale, 0.5, "Масштаб должен быть как в геноме")

		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_parse_less_eyes_genome() -> void:
		var genome: Array[Gene] = [
			Gene.new(&"body", &"size", 0, 1.0),
			Gene.new(&"eye", &"angle", 0, 45.0),
			Gene.new(&"eye", &"width_scale", 0, 1.5),
		]
		var warnings: PackedStringArray = organs_manager.parse_genome(genome)

		assert_true(warnings.is_empty(), "Не должно быть предупреждений")

		assert_gt(organs_manager.count_organs(), 1, "Помимо тела должен быть глаз")

		genome = [
			Gene.new(&"body", &"size", 0, 1.0),
		]
		warnings = organs_manager.parse_genome(genome)

		assert_true(warnings.is_empty(), "Не должно быть предупреждений")
		assert_eq(organs_manager.count_organs(), 1, "Глаз должен быть удалён")
		assert_eq(organs_manager.get_child_count(), 1, "Глаз должен быть удалён")

		assert_push_warning_count(0)
		assert_push_error_count(0)


class TestCountOrgans:
	extends GutTest

	var body: ORGANISM_BODY
	var organs_manager: ORGANS_MANAGER


	func before_each() -> void:
		body = ORGANISM_BODY_SCENE.instantiate()
		body.name = "Body"

		organs_manager = ORGANS_MANAGER.new()
		organs_manager.add_child(body)
		organs_manager.body = body
		body.root = organs_manager
		add_child_autoqfree(organs_manager)


	func test_init_count_organs() -> void:
		assert_eq(organs_manager.count_organs(), 1, "У организма только тело")
		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_count_organs_with_eye() -> void:
		var genome: Array[Gene] = [
			Gene.new(&"body", &"size", 0, 1.0),
			Gene.new(&"eye", &"angle", 0, 45.0),
			Gene.new(&"eye", &"width_scale", 0, 1.5),
		]
		var _warnings: PackedStringArray = organs_manager.parse_genome(genome)

		assert_eq(organs_manager.count_organs(), 2, "У организма тело и глаз")
		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_count_organs_with_several_eyes() -> void:
		var genome: Array[Gene] = [
			Gene.new(&"body", &"size", 0, 1.0),
			Gene.new(&"eye", &"angle", 0, 45.0),
			Gene.new(&"eye", &"width_scale", 0, 1.5),
			Gene.new(&"eye", &"angle", 1, 45.0),
			Gene.new(&"eye", &"width_scale", 1, 1.5),
		]
		var _warnings: PackedStringArray = organs_manager.parse_genome(genome)

		assert_eq(organs_manager.count_organs(), 3, "У организма тело и 2 глаза")
		assert_push_warning_count(0)
		assert_push_error_count(0)


class TestGetTotalEnergyConsumption:
	extends GutTest

	var body: ORGANISM_BODY
	var organs_manager: ORGANS_MANAGER


	func before_each() -> void:
		body = ORGANISM_BODY_SCENE.instantiate()
		body.name = "Body"

		organs_manager = ORGANS_MANAGER.new()
		organs_manager.add_child(body)
		organs_manager.body = body
		body.root = organs_manager
		add_child_autoqfree(organs_manager)


	func test_body_only_consumption() -> void:
		var body_consumption: float = body.energy_consumption
		assert_eq(
			organs_manager.get_total_energy_consumption(),
			body_consumption,
			"У организма только тело",
		)
		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_body_and_eye_consumption() -> void:
		var genome: Array[Gene] = [
			Gene.new(&"body", &"size", 0, 1.0),
			Gene.new(&"eye", &"angle", 0, 45.0),
			Gene.new(&"eye", &"width_scale", 0, 1.5),
		]
		var _warnings: PackedStringArray = organs_manager.parse_genome(genome)

		var body_consumption: float = body.energy_consumption
		assert_gt(
			organs_manager.get_total_energy_consumption(),
			body_consumption,
			"Итоговое потребление должно быть больше чем потребление тела",
		)
		assert_push_warning_count(0)
		assert_push_error_count(0)


	func test_body_and_eyes_consumption() -> void:
		var genome: Array[Gene] = [
			Gene.new(&"body", &"size", 0, 1.0),
			Gene.new(&"eye", &"angle", 0, 45.0),
			Gene.new(&"eye", &"width_scale", 0, 1.5),
		]
		var _warnings: PackedStringArray = organs_manager.parse_genome(genome)
		var prev_consumption: float = organs_manager.get_total_energy_consumption()

		genome = [
			Gene.new(&"body", &"size", 0, 1.0),
			Gene.new(&"eye", &"angle", 0, 45.0),
			Gene.new(&"eye", &"width_scale", 0, 1.5),
			Gene.new(&"eye", &"angle", 1, 45.0),
			Gene.new(&"eye", &"width_scale", 1, 1.5),
		]
		_warnings = organs_manager.parse_genome(genome)

		assert_gt(
			organs_manager.get_total_energy_consumption(),
			prev_consumption,
			"Итоговое потребление должно увеличится после добавления нового глаза",
		)
		assert_push_warning_count(0)
		assert_push_error_count(0)
