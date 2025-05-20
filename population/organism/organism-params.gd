class_name OrganismParams extends Resource

@export_category("Жизни и урон")
## Максимальное (начальное) количество жизней особи.
@export var max_hp: float = 100.0
## Максимальный урон за 1 тик.
@export var max_damage: float = 25
## Множитель функции приспособленности для определения урона.
@export var damage_coef: float = 0.3

@export_category("Мутации")
## Функция мутации данного организма. [Genome] -> Void
@export var mutate_function: Callable = GACallables.random_binary_mutation
## Шанс срабатывания [member mutate_function] на каждой итерации.
@export var mutate_chance := 0.0001

@export_category("Выбор партнёра")
## Функция выбора патнёра. Array[Organism] -> [Organism]
@export var partner_chooser: Callable = GACallables.random_partner
## Шанс срабатывания [member partner_chooser] на каждой итерации.
@export var reproduction_chance := 0.002
