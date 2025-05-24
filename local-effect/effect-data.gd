class_name EffectData extends Resource

## Название эффекта.
@export var name: String = ""
## Цвет эффекта.
@export var color: Color = Color(0, 0, 0, 0.5)
## Функция эффекта (сам эффект).
@export var function: String = ""
## Переменные из [member function].
@export var variables: PackedStringArray = []
## Длительность эффекта.
@export var duration: float = 15.0
