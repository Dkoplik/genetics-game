class_name PopulationParams extends Resource

@export_category("Функции ГА")
## Названия функций мутации для [Organism] из [GACallables].
@export var mutate_function_names: PackedStringArray = ["random_binary_mutation"]
## Названия функций выбора партнёра для [Organism] из [GACallables].
@export var partner_chooser_names: PackedStringArray = ["random_partner"]
## Названия функций формирования нового [Genome] из [GACallables].
@export var crossover_function_names: PackedStringArray = ["discrete_recombination"]

@export_category("Genome")
## Параметры [Genome] и примеры их значений.
@export var genome_params: Dictionary[String, Variant] = {"Ice": 0.0}
## Ограничения параметров [Genome].
@export var genome_param_ranges: Dictionary[String, Array] = {"Ice": [0.0, 100.0]}

@export_category("Функция приспособленности")
## Строковое представление функции.
@export var fitness_function_string: String = "0.0"
## Названия переменных из строкового представления функции.
@export var fitness_function_vars: PackedStringArray = []
