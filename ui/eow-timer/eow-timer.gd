class_name EOWTimer extends Control

signal started_eow

@onready var _timer := $Timer as Timer
@onready var _label := $Label as Label

func _ready() -> void:
	_timer.timeout.connect(_start_eow)


func _physics_process(_delta: float) -> void:
	if _timer.is_stopped():
		return
	var minutes: int = int(_timer.time_left) / 60
	var seconds: int = int(_timer.time_left) % 60
	var str_seconds: String = str(seconds) if seconds > 9 else "0" + str(seconds)
	_label.text = str(minutes) + ":" + str_seconds


func start(seconds: float) -> void:
	_timer.start(seconds)


func _start_eow() -> void:
	started_eow.emit()
