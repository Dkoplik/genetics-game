class_name InfoLabel extends Label

@export var preffix: String = "":
	set = set_preffix
@export var data: String = "":
	set = set_data


func _ready() -> void:
	text = preffix + data


func set_preffix(value: String) -> void:
	preffix = value
	text = preffix + data


func set_data(value: String) -> void:
	data = value
	text = preffix + data
