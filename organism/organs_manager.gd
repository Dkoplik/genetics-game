@tool
extends Node2D
## Отвечает за организацию органов в организме.

const GA := preload("res://genetic/genetic_functions.gd")

const ORGANISM_BODY = preload("res://organism/body.gd")

const ORGANISM_EYE_SCENE: PackedScene = preload("res://organism/eye.tscn")
const ORGANISM_EYE = preload("res://organism/eye.gd")

@export var blackboard: OrganismBlackboard:
	set(value):
		blackboard = value

		if Engine.is_editor_hint():
			update_configuration_warnings()
			return

		if blackboard == null:
			Log.err("blackboard == null, больше невозможно передавать данные")

@export var body: ORGANISM_BODY:
	set(value):
		body = value

		if Engine.is_editor_hint():
			update_configuration_warnings()
			return

		if body == null:
			Log.err("body == null, организм не будет корректно существовать")

@export_storage var organs: Dictionary[StringName, Array] = { }


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if body != null:
		organs[&"body"] = [body]
	else:
		Log.err("Отсутствует тело организма")

	var organs_count: int = count_organs()
	if get_child_count() != organs_count:
		Log.warn(
			"На момент входа в сцену у OrgansManager",
			get_child_count(),
			"дочерних узлов, при этом известно только о",
			organs_count,
			"органов",
		)


## Количество органов в организме (о которых знает OrgansManager).
func count_organs() -> int:
	var res: int = 0
	for type: StringName in organs:
		res += organs[type].size()
	return res


## Изменить набор органов в соответствии с полученным набором генов [param genome].
## Возвращает массив с ошибками.
func parse_genome(genome: Array[Gene]) -> PackedStringArray:
	if Engine.is_editor_hint():
		Log.err("Попытка обработать геном в редакторе")
		return []

	organs.clear()
	for child: Node in get_children():
		if child is ORGANISM_BODY:
			continue
		remove_child(child)
		child.queue_free()

	var parse_warnings := PackedStringArray()

	var has_body_type := false
	for gene: Gene in genome:
		if gene.type == &"body":
			has_body_type = true
			break
	if not has_body_type:
		var msg := "Отсутствуют гены для тела организма"
		var _err := parse_warnings.append(msg)
		Log.warn(msg)

	var parsers: Dictionary[StringName, Callable] = {
		&"body": _process_body.bind(parse_warnings),
		&"eye": _process_eyes.bind(parse_warnings),
	}
	var warnings: PackedStringArray = GA.parse_genome(genome, parsers)
	parse_warnings.append_array(warnings)
	return parse_warnings


## Получить итоговое потребление энергии в секунду со всех органов организма.
func get_total_energy_consumption() -> float:
	const property_name: StringName = &"energy_consumption"
	return _sum_property(self, property_name)


## Получить итоговую скорость движения организма.
func get_total_speed() -> float:
	if body == null:
		return 0.0

	return body.speed


## Получить итоговую скорость вращения организма.
func get_total_rotation_speed() -> float:
	if body == null:
		return 0.0

	return body.rotation_speed


func _sum_property(root: Node, property_name: StringName) -> float:
	var sum: float = 0.0
	for child: Node in root.get_children():
		if child is PolarContainer:
			sum += _sum_property(child, property_name)
			continue
		if child.get(property_name) == null:
			Log.warn("найден узел без поля", property_name, ":", child.name, child)
			continue
		var energy_consumption: float = child.get(property_name)
		sum += energy_consumption
	return sum


func _process_body(body_arr: GenesTable.TypeArr, out_warnings: PackedStringArray) -> void:
	organs[&"body"] = [body]

	if body == null:
		var msg := "Не найдено тело организма"
		var _err := out_warnings.append(msg)
		if not Engine.is_editor_hint():
			Log.err(msg)
		return

	if body_arr.size() == 0:
		var msg := "Нет генома для тела организма"
		var _err := out_warnings.append(msg)
		if not Engine.is_editor_hint():
			Log.err(msg)
		return

	if body_arr.size() > 1:
		var msg := "Несколько геномов для тела организма или его индекс больше 0"
		var _err := out_warnings.append(msg)
		if not Engine.is_editor_hint():
			Log.warn(msg)

	var body_genome: Dictionary[StringName, float] = body_arr.at(0)
	if body_genome.has(&"size"):
		body.size = body_genome[&"size"]
	else:
		var msg := "В геноме для тела организма отсутствует параметр размера &'size'"
		var _err := out_warnings.append(msg)
		if not Engine.is_editor_hint():
			Log.warn(msg, ":", body_genome)


func _process_eyes(eye_arr: GenesTable.TypeArr, out_warnings: PackedStringArray) -> void:
	organs[&"eye"] = []
	for i in range(eye_arr.size()):
		var eye_genome: Dictionary[StringName, float] = eye_arr.at(i)
		if eye_genome.is_empty(): # пропуск в индексации
			continue

		var eye_container := PolarContainer.new()
		eye_container.radius = body.get_radius()

		var eye: ORGANISM_EYE = ORGANISM_EYE_SCENE.instantiate()
		if blackboard != null:
			var _err := eye.area_entered.connect(blackboard._on_vision_area_entered)
			_err = eye.area_exited.connect(blackboard._on_vision_area_exited)

		organs[&"eye"].append(eye)
		eye_container.add_child(eye, true)

		if eye_genome.has(&"angle"):
			eye_container.angle_degrees = eye_genome[&"angle"]
		else:
			var msg := "В геноме для глаза отсутствует параметр угла &'angle'"
			var _err := out_warnings.append(msg)
			if not Engine.is_editor_hint():
				Log.warn(msg, ":", eye_genome)

		if eye_genome.has(&"width_scale"):
			eye.width_scale = eye_genome[&"width_scale"]
		else:
			var msg := "В геноме для глаза отсутствует параметр ширины зрения &'width_scale'"
			var _err := out_warnings.append(msg)
			if not Engine.is_editor_hint():
				Log.warn(msg, ":", eye_genome)

		add_child(eye_container, true)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if blackboard == null:
		var _err := warnings.append("Отсутсвует ссылка на Blackboard")
	if body == null:
		var _err := warnings.append("Отсутсвует ссылка на тело организма")
	return warnings
