class_name Monster2DParams extends Resource

@export_category("Движение")
@export var speed: float = 100.0
## Дистанция, при которой движение к целевому организму можно прекратить.
## Указывается в долях от радиуса организма.
@export var move_to_organism_dist_coef: float = 1.1

@export_category("Границы мира")
@export var world_upper_border: float = 0
@export var world_lower_border: float = 500
@export var world_left_border: float = 0
@export var world_right_border: float = 500
