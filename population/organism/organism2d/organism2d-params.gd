class_name Organism2DParams extends Resource

@export var speed: float = 80.0
## Дистанция, при которой движение к целевому организму можно считать
## законченным. Указывается в долях от радиуса организма.
@export var move_to_organism_dist_coef: float = 1.5

@export_category("Границы мира")
@export var world_upper_border: float = 0
@export var world_lower_border: float = 2400
@export var world_left_border: float = 0
@export var world_right_border: float = 1080
