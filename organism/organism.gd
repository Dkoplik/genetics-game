class_name Organism extends Node
## Логика организма для генетического алгоритма.
##
## Организм содержит свой геном, свою функцию приспособленности и даже свою
## функцию мутации, поскольку мутация не зависит от других организмов. Этот
## класс отвечает только за представление организма в ГА и не имеет отношения
## к его поведению в игровом мире.

## Хормосома (геном) данного организма.
var genome: Genome
## Функция приспособленности данного организма.
var fitness_function: FitnessFunction
## Функция мутации данного организма. Genome -> Void.
var mutate_function: Callable
## Функция выбора патнёра. Массив из [Organism] -> [Organism]
var partner_chooser: Callable
var generation: int
var hp: float
## Узел (класс) с поведением организма в игровом мире.
@onready var behaviour: Organism2D = $Organism2D


## Получить текущее значение приспособленности организма.
func get_fitness() -> float:
	return fitness_function.calculate(genome.get_param_dict())


## Произвести мутацию организма по алгоритму [member mutate_function].
func mutate() -> void:
	mutate_function.call(genome)


## Запустить вымирание особи. После вызова этого метода организм должен
## осободить все занимаемые ресурсы и исчезнуть.
func die() -> void:
	self.queue_free()
