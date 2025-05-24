class_name Population extends Node
## Отвечает за популяцию из [Organism].
##
## Содержит методы для создания новых организмов и для нанесения глобальных
## эффектов или глобального урона.

## Параметры популяции.
var params: PopulationParams = preload("res://config/population-default-params.tres"):
	set = set_params

## Структура [Genome] для всех [Organism] в этой популяции.
var _genome: Genome
var _fitness_function: FitnessFunction
## Сцена с [Organism].
## Доступные функции мутации для [Organism].
var _mutate_functions: Array[Callable]
## Доступные функции выбора партнёра для [Organism].
var _partner_choosers: Array[Callable]
## Доступные функции кроссовера для [Genome].
var _crossover_functions: Array[Callable]
## Глобальная [FitnessFunction] этой популяции.
var _organism_scene: PackedScene = preload("./organism/organism.tscn")
## Массив [Organism] этой популяции.
var _organism_array: Dictionary[Organism, Variant] = {} # Вместо set


func _ready() -> void:
	_process_params()
	for node: Node in get_children():
		if node is Organism:
			_organism_array.set(node as Organism, null)


func _physics_process(_delta: float) -> void:
	deal_global_damage(_calc_population_damage())


func set_params(value: PopulationParams) -> void:
	params = value
	_process_params()


## Получить массив всех организмов в этой популяции.
func get_organisms() -> Array[Organism]:
	return _organism_array.keys() as Array[Organism]


## Создать новый организм с геномом [param genome] в позиции [param position].
func create_organism(genome: Genome, position: Vector2, random_pos := false) -> void:
	var organism := _organism_scene.instantiate() as Organism
	_organism_array.set(organism, null)
	organism.died.connect(_on_organism_died, CONNECT_ONE_SHOT)

	organism.genome = genome
	organism.fitness_function = _fitness_function.duplicate()
	organism.mutate_function = _mutate_functions.pick_random()
	organism.partner_chooser = _partner_choosers.pick_random()
	organism.crossover_function = _crossover_functions.pick_random()
	organism.reproduced.connect(_on_organism_reproduced)
	add_child(organism)
	if random_pos:
		organism.behaviour.position = organism.behaviour.get_random_point()
	else:
		organism.behaviour.position = position


## Создать организм со случайным геномом в случайной позиции.
func create_random_organism() -> void:
	var new_genome := _genome.duplicate() as Genome
	new_genome.randomize_params()
	create_organism(new_genome, Vector2.ZERO, true)


## Получить размер популяции.
func get_population_size() -> int:
	return get_organisms().size()


## Добавляет глобальный эффект для всех [Organism] в этой популяции и для всех
## будущих организмов.
func add_global_summand(summand: String, variables: PackedStringArray) -> void:
	var err: Error = _fitness_function.add_summand(summand, variables)
	assert(err == Error.OK)
	for organism: Organism in get_organisms():
		err = organism.fitness_function.add_summand(summand, variables)
		assert(err == Error.OK)


## Удаляет глобальный эффект для всех [Organism] в этой популяции и для всех
## будущих организмов.
func remove_global_summand(summand: String, variables: PackedStringArray) -> void:
	var err: Error = _fitness_function.remove_summand(summand, variables)
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
	return 0.0 #0.001 * get_population_size() ** 2


func _on_organism_reproduced(parent1: Organism, parent2: Organism, new_genome: Genome) -> void:
	var position: Vector2 = (parent1.behaviour.position + parent2.behaviour.position) / 2
	create_organism(new_genome, position)


func _on_organism_died(organism: Organism) -> void:
	_organism_array.erase(organism)


## Обработать [PopulationParams].
func _process_params() -> void:
	_genome = Genome.new(params.genome_params, params.genome_param_ranges)
	_fitness_function = FitnessFunction.new(
		params.fitness_function_string,
		params.fitness_function_vars
	)
	_mutate_functions = _get_ga_callables(params.mutate_function_names)
	_partner_choosers = _get_ga_callables(params.partner_chooser_names)
	_crossover_functions = _get_ga_callables(params.crossover_function_names)


func _get_ga_callables(names: PackedStringArray) -> Array[Callable]:
	var res: Array[Callable] = []
	res.resize(names.size())
	for i in range(names.size()):
		res[i] = Callable(GACallables, names[i])
	return res
