class_name OrganismParams extends Resource

## Максимальное (начальное) количество жизней особи.
@export var max_hp: float = 100.0
## Шанс срабатывания [member mutate_function] на каждой итерации.
@export var mutate_chance := 0.0001
## Шанс срабатывания [member partner_chooser] на каждой итерации.
@export var reproduction_chance := 0.002
