class_name PopulationParams extends Resource

## Функции мутации для [Organism].
@export var mutate_functions: Array[Callable] = [GACallables.random_binary_mutation]
## Функции выбора партнёра для [Organism].
@export var partner_choosers: Array[Callable] = [GACallables.random_partner]
## Функции формирования нового [Genome] из двух родительских.
@export var crossover_functions: Array[Callable] = [GACallables.discrete_recombination]
## Параметры [Genome] и его типы.
@export var genome_param_types: Dictionary[String, Variant.Type] = {
	"Ice": TYPE_FLOAT,
	"Fire": TYPE_FLOAT
}

## Начальная функция приспособленности.
var default_fitness_function := FitnessFunction.new("0.0", [])
