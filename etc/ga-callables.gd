class_name GACallables extends Object

# ========== Функции расстояния для in(out) breeding ==========

## Расстояние в 2d пространстве.
static func euclidean_2d_dist(org1: Organism, org2: Organism) -> float:
	var org2d1 := org1.behaviour as Organism2D
	var org2d2 := org2.behaviour as Organism2D
	return org2d1.position.distance_to(org2d2.position)


## Разница в приспособленности.
static func fitness_dist(org1: Organism, org2: Organism) -> float:
	return abs(org1.get_fitness() - org2.get_fitness())


# ========== Выбор партнёра (2-ого родителя) ==========

## Панмиксия, просто случайный партнёр.
static func random_partner(_this: Organism, organisms: Array[Organism]) -> Organism:
	return organisms.pick_random()

## Ближайший организм по критерию [param dist]. [param dist] имеет вид
## ([Organism], [Organism]) -> [Variant].
static func in_breeding(this: Organism, organisms: Array[Organism], dist: Callable) -> Organism:
	var best_fit: Organism = null
	for partner: Organism in organisms:
		if partner == this:
			continue
		if (not best_fit) or (dist.call(this, partner) < dist.call(this, best_fit)):
			best_fit = partner
	return best_fit


## Дальний организм по критерию [param dist]. [param dist] имеет вид
## ([Organism], [Organism]) -> [Variant].
static func out_breeding(this: Organism, organisms: Array[Organism], dist: Callable) -> Organism:
	var best_fit: Organism = null
	for partner: Organism in organisms:
		if partner == this:
			continue
		if (not best_fit) or (dist.call(this, partner) > dist.call(this, best_fit)):
			best_fit = partner
	return best_fit


# ========== Рекомбинация (скрещивание) ==========

## Копирование параметров от случайного родителя.
static func discrete_recombination(parent1: Genome, parent2: Genome) -> Genome:
	var param_names: PackedStringArray = parent1.get_param_dict().keys()
	var new_genome: Genome = parent1.duplicate()
	for param_name: String in param_names:
		var parent_of_param: Genome = [parent1, parent2].pick_random()
		new_genome.set_param(param_name, parent_of_param.get_param(param_name))
	return new_genome


## Промежуточные значения между потомками, подходит для числовых параметров.
static func intermediate_recombination(parent1: Genome, parent2: Genome, d: float) -> Genome:
	assert(d >= 0)
	var param_names: PackedStringArray = parent1.get_param_dict().keys()
	var new_genome: Genome = parent1.duplicate()
	for param_name: String in param_names:
		var param1: Variant = parent1.get_param(param_name)
		var param2: Variant = parent2.get_param(param_name)
		var alpha: float = randf_range(-d, 1 + d)
		new_genome.set_param(param_name, _alpha_recombination(param1, param2, alpha))
	return new_genome


## Аналогично [member intermediate_recombination], но alpha один для всех
## параметров.
static func line_recombination(parent1: Genome, parent2: Genome, d: float) -> Genome:
	assert(d >= 0)
	var param_names: PackedStringArray = parent1.get_param_dict().keys()
	var new_genome: Genome = parent1.duplicate()
	var alpha: float = randf_range(-d, 1 + d)
	for param_name: String in param_names:
		var param1: Variant = parent1.get_param(param_name)
		var param2: Variant = parent2.get_param(param_name)
		new_genome.set_param(param_name, _alpha_recombination(param1, param2, alpha))
	return new_genome


static func _alpha_recombination(param1: Variant, param2: Variant, alpha: float) -> Variant:
	assert((param1 is int) or (param1 is float))
	assert((param2 is int) or (param2 is float))
	if param1 is int:
		var parami1 := param1 as int
		var parami2 := param2 as int
		return roundi(parami1 + alpha * (parami2 - parami1))
	var paramf1 := param1 as float
	var paramf2 := param2 as float
	return paramf1 + alpha * (paramf2 - paramf1)


# ========== Мутация ==========

## Инвертирование случайного бита.
static func random_binary_mutation(genome: Genome) -> void:
	var bit_index: int = randi_range(0, genome.bit_array_size() - 1)
	var bit: int = 0 if genome.get_bit(bit_index) else 1
	genome.set_bit(bit_index, bit)


## Мутации для вещественных чисел.
static func real_value_mutation(genome: Genome, m: int) -> void:
	assert(m >= 1)
	var param_names := genome.get_param_dict().keys() as PackedStringArray
	var ranges := genome.get_ranges_dict()
	for param_name: String in param_names:
		assert(genome.get_param(param_name) is float)
		var alpha: float
		if ranges.has(param_name):
			var pair := ranges.get(param_name) as Array
			alpha = 0.5 * (pair[1] - pair[0])
		else:
			alpha = 0.5 * Numeric.FLOAT_MAX
		var param := genome.get_param(param_name) as float
		genome.set_param(param_name, param + alpha * _calc_delta(m))


static func _calc_delta(m: int) -> float:
	var res := 0.0
	for i: int in range(1, m + 1):
		if Numeric.roll_dice(1.0 / m):
			res += pow(2.0, -i)
	return res
