class_name Population extends Node
## Отвечает за популяцию из [Organism].
##
## Содержит методы для создания новых организмов и для нанесения глобальных
## эффектов или глобального урона.

var params: PopulationParams = preload("./population-default-params.tres")
var organism_params: OrganismParams = preload("./organism/organism-default-params.tres")
var organism2d_params: Organism2DParams = preload(
	"./organism/organism2d/organism2d-default-params.tres"
)
var _organism_scene: PackedScene = preload("./organism/organism.tscn")


func _physics_process(_delta: float) -> void:
	deal_global_damage(_calc_population_damage())


## Получить массив всех организмов в этой популяции.
func get_organisms() -> Array[Organism]:
	var res: Array[Organism] = []
	for node: Node in get_children():
		if node is Organism:
			res.append(node as Organism)
	return res


## Создать новый организм с геномом [param genome] в позиции [param position].
func create_organism(genome: Genome, position: Vector2) -> void:
	var new_organism_params: OrganismParams = organism_params.duplicate()
	new_organism_params.mutate_function = params.mutate_functions.pick_random()
	new_organism_params.partner_chooser = params.partner_choosers.pick_random()

	var organism: Organism = _organism_scene.instantiate()
	organism.params = new_organism_params

	organism.genome = genome
	organism.fitness_function = params.default_fitness_function.duplicate()
	organism.ready_for_mating.connect(_on_organism_ready_for_mating)
	add_child(organism)
	organism.behaviour.params = organism2d_params
	organism.behaviour.position = position


## Создать организм со случайным геномом в случайной позиции.
func create_random_organism() -> void:
	var random_params: Dictionary[String, Variant] = {}
	for param_name: String in params.genome_param_types.keys():
		var param_type: Variant.Type = params.genome_param_types.get(param_name)
		random_params.set(param_name, Numeric.random_value(param_type))
	create_organism(Genome.new(random_params), _get_random_point())


## Получить размер популяции.
func get_population_size() -> int:
	return get_organisms().size()


## Добавляет глобальный эффект для всех [Organism] в этой популяции и для всех
## будущих организмов.
func add_global_summand(summand: String, variables: PackedStringArray) -> void:
	var err: Error = params.default_fitness_function.add_summand(summand, variables)
	assert(err == Error.OK)
	for organism: Organism in get_organisms():
		err = organism.fitness_function.add_summand(summand, variables)
		assert(err == Error.OK)


## Удаляет глобальный эффект для всех [Organism] в этой популяции и для всех
## будущих организмов.
func remove_global_summand(summand: String, variables: PackedStringArray) -> void:
	var err: Error = params.default_fitness_function.remove_summand(summand, variables)
	assert(err == Error.OK)
	for organism: Organism in get_organisms():
		err = organism.fitness_function.remove_summand(summand, variables)
		assert(err == Error.OK)


## Нанести урон в размере [param damage] всем организмам этой популяции.
func deal_global_damage(damage: float) -> void:
	if damage < 0.0:
		push_warning("Отрицательный глобальный урон")
	for organism: Organism in get_organisms():
		organism._hp -= damage


## Рассчитать урон из-за размера популяции.
func _calc_population_damage() -> float:
	return 0.001 * get_population_size() ** 2


func _on_organism_ready_for_mating(parent1: Organism, parent2: Organism) -> void:
	var crossover: Callable = params.crossover_functions.pick_random()
	var new_genome: Genome = crossover.call(parent1.genome, parent2.genome)
	var position: Vector2 = (parent1.behaviour.position + parent2.behaviour.position) / 2
	create_organism(new_genome, position)


## Случайная точка в игровом мире.
func _get_random_point() -> Vector2:
	return Vector2(
		randf_range(organism2d_params.world_left_border, organism2d_params.world_right_border),
		randf_range(organism2d_params.world_upper_border, organism2d_params.world_lower_border)
	)
