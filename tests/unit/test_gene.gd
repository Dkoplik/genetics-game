extends GutTest

const TEST_TYPE_1: StringName = &"Organ"


func test_gene_creation() -> void:
	var gene := Gene.new(TEST_TYPE_1, &"health", 0, 100.0)

	assert_eq(gene.type, TEST_TYPE_1, "Тип должен соответствовать")
	assert_eq(gene.name, &"health", "Имя должно соответствовать")
	assert_eq(gene.index, 0, "Индекс должен соответствовать")
	assert_eq(gene.value, 100.0, "Значение должно соответствовать")


func test_gene_to_pretty() -> void:
	var gene := Gene.new(TEST_TYPE_1, &"speed", 2, 50.0)
	var pretty: Dictionary = gene.to_pretty()

	assert_has(pretty, "type", "Словарь должен содержать ключ 'type'")
	assert_has(pretty, "name", "Словарь должен содержать ключ 'name'")
	assert_has(pretty, "index", "Словарь должен содержать ключ 'index'")
	assert_has(pretty, "value", "Словарь должен содержать ключ 'value'")

	@warning_ignore("unsafe_call_argument")
	assert_eq(pretty["type"], TEST_TYPE_1)
	@warning_ignore("unsafe_call_argument")
	assert_eq(pretty["value"], 50.0)
