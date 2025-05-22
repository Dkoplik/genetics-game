class_name Organism extends Node
## Логика организма для генетического алгоритма.
##
## Отвечает только за реализацию логики генетического алгоритма. Этот класс
## не затрагивает поведение и положение организма в мире. Где это необходимо,
## изменения в поведении передаются по ссылке классу, отвечающему за поведение.

signal died
signal mutated
signal chose_partner(partner: Organism)
signal ready_for_mating(parent1: Organism, parent2: Organism)
signal reproduced(parent1: Organism, parent2: Organism, genome: Genome)
signal hp_changed(new_hp: float)

## Хормосома (геном) данного организма.
var genome: Genome = null
## Функция приспособленности данного организма.
var fitness_function: FitnessFunction = null
## Остальные параметры особи.
var params: OrganismParams = preload("./organism-default-params.tres")

## Время жизни организма.
var _time_alive: float = 0.0
## Текущие жизни особи.
var _hp: float:
	get = get_hp,
	set = set_hp
## Количество мутаций.
var _mutations_count: int = 0
## Количество детей.
var _children_count: int = 0

## Узел (класс) с поведением организма в игровом мире.
@onready var behaviour: Organism2D = $Organism2D


func _ready() -> void:
	chose_partner.connect(_move_to_partner)
	_hp = params.max_hp


func _physics_process(delta: float) -> void:
	if _hp <= 0.0:
		die()
	try_mutate()
	try_choose_partner()
	_time_alive += delta
	_hp -= _calc_damage()


## Получить текущее значение приспособленности организма.
func get_fitness() -> float:
	if genome == null:
		push_warning("genome == null")
		return 0.0
	if fitness_function == null:
		push_warning("fitness function == null")
		return 0.0
	return fitness_function.calculate(genome.get_param_dict())


## Произвести мутацию организма по алгоритму [member mutate_function].
func try_mutate() -> void:
	if not Numeric.roll_dice(params.mutate_chance):
		return
	if genome == null:
		push_warning("genome == null")
		return
	params.mutate_function.call(genome)
	mutated.emit()
	_mutations_count += 1


## Выбрать партнёра для кроссовера.
func try_choose_partner() -> void:
	if not Numeric.roll_dice(params.mutate_chance):
		return
	if get_parent() is not Population:
		push_error("No Population parent")
		return
	var population := get_parent() as Population
	var partner := params.partner_chooser.call(population.get_organisms()) as Organism
	chose_partner.emit(partner)


## Запустить вымирание особи. После вызова этого метода организм должен
## осободить все занимаемые ресурсы и исчезнуть.
func die() -> void:
	died.emit()
	self.queue_free()


## Время жизни организма.
func get_time_alive() -> float:
	return _time_alive


## Нанести урон в размере [param damage].
func deal_damage(damage: float) -> void:
	if damage <= 0.0:
		push_error("урон = {0}".format([damage]))
		return
	_hp -= damage


## Увеличить здоровье на [param heal_amount].
func heal(heal_amount: float) -> void:
	if heal_amount <= 0.0:
		push_error("восстановление жизней = {0}".format([heal_amount]))
		return
	_hp += heal_amount


func set_hp(new_hp: float) -> void:
	_hp = clampf(new_hp, 0.0, params.max_hp)
	hp_changed.emit(_hp)


func get_hp() -> float:
	return _hp


func get_mutations_count() -> int:
	return _mutations_count


func get_children_count() -> int:
	return _children_count


func _move_to_partner(partner: Organism) -> void:
	behaviour.move_to_organism2d(partner.behaviour)
	if not behaviour.moved_to_organism2d.is_connected(_ready_for_mating):
		behaviour.moved_to_organism2d.connect(_ready_for_mating)


func _ready_for_mating(partner: Organism2D) -> void:
	if partner.get_parent() is not Organism:
		push_warning("У найденного Organism2D отсутствует родительский Organism")
		return
	if genome == null:
		push_warning("genome == null")
		return
	var partner_org := partner.get_parent() as Organism
	ready_for_mating.emit(self, partner_org)
	behaviour.moved_to_organism2d.disconnect(_ready_for_mating)
	var new_genome := params.crossover_function.call(genome, partner_org.genome) as Genome
	reproduced.emit(self, partner_org, new_genome)
	_children_count += 1


func _calc_damage() -> float:
	var fitness: float = get_fitness()
	if fitness < 0.0:
		push_error("Отрицательная приспособленность")
		fitness = 0.0
	return min(params.damage_coef * fitness, params.max_damage)
