class_name Organism extends Node
## Логика организма для генетического алгоритма.
##
## Организм содержит свой геном, свою функцию приспособленности и даже свою
## функцию мутации, поскольку мутация не зависит от других организмов. Этот
## класс отвечает только за представление организма в ГА и не имеет отношения
## к его поведению в игровом мире.

signal died
signal mutated
signal chose_partner(partner: Organism)
signal ready_for_mating(parent1: Organism, parent2: Organism)
signal hp_changed(new_hp: float)

## Хормосома (геном) данного организма.
var genome: Genome
## Функция приспособленности данного организма.
var fitness_function: FitnessFunction
## Остальные параметры особи
var params: OrganismParams = preload("./organism-default-params.tres")

## Текущие жизни особи.
var _hp: float: set = set_hp

## Узел (класс) с поведением организма в игровом мире.
@onready var behaviour: Organism2D = $Organism2D


func _ready() -> void:
	chose_partner.connect(_move_to_partner)
	_hp = params.max_hp


func _physics_process(_delta: float) -> void:
	if _hp <= 0.0:
		die()
	try_mutate()
	try_choose_partner()
	_hp -= _calc_damage()


## Получить текущее значение приспособленности организма.
func get_fitness() -> float:
	return fitness_function.calculate(genome.get_param_dict())


## Произвести мутацию организма по алгоритму [member mutate_function].
func try_mutate() -> void:
	if not Numeric.roll_dice(params.mutate_chance):
		return
	params.mutate_function.call(genome)
	mutated.emit()


## Выбрать партнёра для кроссовера.
func try_choose_partner() -> void:
	if not Numeric.roll_dice(params.mutate_chance):
		return
	if get_parent() is not Population:
		push_warning("Отсутствует родительская популяция, выбор партнёра невозможен")
		return
	var population: Population = get_parent()
	var partner: Organism = params.partner_chooser.call(population.get_organisms())
	chose_partner.emit(partner)


## Запустить вымирание особи. После вызова этого метода организм должен
## осободить все занимаемые ресурсы и исчезнуть.
func die() -> void:
	died.emit()
	self.queue_free()


func set_hp(new_hp: float) -> void:
	if new_hp > params.max_hp:
		push_warning("Попытка превысить максимальные жизни")
		new_hp = params.max_hp
	if new_hp < 0.0:
		new_hp = 0.0
	_hp = new_hp
	hp_changed.emit(_hp)


func _move_to_partner(partner: Organism) -> void:
	behaviour.move_to_organism2d(partner.behaviour)
	if not behaviour.moved_to_organism2d.is_connected(_ready_for_mating):
		behaviour.moved_to_organism2d.connect(_ready_for_mating)


func _ready_for_mating(partner: Organism2D) -> void:
	if partner.get_parent() is not Organism:
		push_warning("У найденного Organism2D отсутствует родительский Organism")
		return
	ready_for_mating.emit(self, partner.get_parent())
	behaviour.moved_to_organism2d.disconnect(_ready_for_mating)


func _calc_damage() -> float:
	var fitness: float = get_fitness()
	if fitness < 0.0:
		push_warning("Отрицательная приспособленность")
		fitness = 0.0
	return min(params.damage_coef * fitness, params.max_damage)
