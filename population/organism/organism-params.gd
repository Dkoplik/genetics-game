class_name OrganismParams extends Resource

## Максимальное (начальное) количество жизней особи.
@export var max_hp: float = 100.0
## Максимальный урон за 1 тик.
@export var max_damage: float = 25
## Множитель функции приспособленности для определения урона за 1 тик.
@export var damage_coef: float = 0.3
## Шанс срабатывания [member mutate_function] на каждой итерации.
@export var mutate_chance := 0.0001
## Шанс срабатывания [member partner_chooser] на каждой итерации.
@export var reproduction_chance := 0.002
