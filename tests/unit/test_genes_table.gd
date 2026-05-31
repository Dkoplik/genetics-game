extends GutTest

const TEST_TYPE_1: StringName = &"Organ"
const TEST_TYPE_2: StringName = &"Leg"
const TEST_TYPE_3: StringName = &"Eye"
const SINGULAR_TYPE: StringName = &"Body"


class TestTypeData:
	extends GutTest

	func test_type_data_creation_empty() -> void:
		var type_data := GenesTable.TypeData.new()

		assert_eq(type_data.data.size(), 0, "Пустой словарь должен иметь размер 0")
		assert_typeof(type_data.data, TYPE_DICTIONARY, "data должен быть словарём")


	func test_type_data_creation_with_params() -> void:
		var params: Dictionary[StringName, float] = {
			&"health": 100.0,
			&"speed": 50.0,
			&"strength": 75.0,
		}
		var type_data := GenesTable.TypeData.new(params)

		assert_eq(type_data.data.size(), 3)
		assert_eq(type_data.data[&"health"], 100.0)
		assert_eq(type_data.data[&"speed"], 50.0)
		assert_eq(type_data.data[&"strength"], 75.0)


	func test_same_type_data_is_equal() -> void:
		var params1: Dictionary[StringName, float] = {
			&"health": 100.0,
			&"speed": 50.0,
			&"strength": 75.0,
		}
		var type_data1 := GenesTable.TypeData.new(params1)

		var params2: Dictionary[StringName, float] = {
			&"health": 100.0,
			&"speed": 50.0,
			&"strength": 75.0,
		}
		var type_data2 := GenesTable.TypeData.new(params2)
		assert_true(type_data1.is_equal(type_data2))


	func test_different_type_data_sizes_not_equal() -> void:
		var params1: Dictionary[StringName, float] = {
			&"health": 100.0,
			&"speed": 50.0,
		}
		var type_data1 := GenesTable.TypeData.new(params1)

		var params2: Dictionary[StringName, float] = {
			&"health": 100.0,
			&"speed": 50.0,
			&"strength": 75.0,
		}
		var type_data2 := GenesTable.TypeData.new(params2)
		assert_false(type_data1.is_equal(type_data2))


	func test_different_type_data_names_not_equal() -> void:
		var params1: Dictionary[StringName, float] = {
			&"health": 100.0,
			&"speed": 50.0,
			&"size": 75.0,
		}
		var type_data1 := GenesTable.TypeData.new(params1)

		var params2: Dictionary[StringName, float] = {
			&"health": 100.0,
			&"speed": 50.0,
			&"strength": 75.0,
		}
		var type_data2 := GenesTable.TypeData.new(params2)
		assert_false(type_data1.is_equal(type_data2))


	func test_different_type_data_values_not_equal() -> void:
		var params1: Dictionary[StringName, float] = {
			&"health": 100.0,
			&"speed": 70.0,
			&"strength": 75.0,
		}
		var type_data1 := GenesTable.TypeData.new(params1)

		var params2: Dictionary[StringName, float] = {
			&"health": 100.0,
			&"speed": 50.0,
			&"strength": 75.0,
		}
		var type_data2 := GenesTable.TypeData.new(params2)
		assert_false(type_data1.is_equal(type_data2))


class TestTypeArr:
	extends GutTest

	func test_type_arr_creation() -> void:
		var type_arr := GenesTable.TypeArr.new()

		assert_eq(type_arr.size(), 0, "Новый массив должен быть пустым")
		assert_eq(type_arr.data.size(), 0)


	func test_type_arr_append() -> void:
		var type_arr := GenesTable.TypeArr.new()
		var params: Dictionary[StringName, float] = { &"health": 100.0 }

		type_arr.append(params)

		assert_eq(type_arr.size(), 1)
		assert_eq(type_arr.at(0)[&"health"], 100.0)


	func test_type_arr_set_at() -> void:
		var type_arr := GenesTable.TypeArr.new()
		type_arr.append({ &"health": 100.0 })

		var new_params: Dictionary[StringName, float] = {
			&"health": 200.0,
			&"speed": 50.0,
		}
		type_arr.set_at(0, new_params)

		assert_eq(type_arr.size(), 1)
		assert_eq(type_arr.at(0).size(), 2)
		assert_eq(type_arr.at(0)[&"health"], 200.0)
		assert_eq(type_arr.at(0)[&"speed"], 50.0)


	func test_type_arr_resize_larger() -> void:
		var type_arr := GenesTable.TypeArr.new()
		type_arr.append({ &"health": 100.0 })
		type_arr.append({ &"speed": 50.0 })

		type_arr.resize(5)

		assert_eq(type_arr.size(), 5)
		assert_eq(type_arr.at(0)[&"health"], 100.0)
		assert_eq(type_arr.at(1)[&"speed"], 50.0)
		assert_eq(type_arr.at(2).size(), 0, "Новый элемент должен быть пустым")
		assert_eq(type_arr.at(3).size(), 0)
		assert_eq(type_arr.at(4).size(), 0)


	func test_type_arr_resize_smaller() -> void:
		var type_arr := GenesTable.TypeArr.new()
		type_arr.append({ &"health": 100.0 })
		type_arr.append({ &"speed": 50.0 })
		type_arr.append({ &"strength": 75.0 })

		type_arr.resize(2)

		assert_eq(type_arr.size(), 2)
		assert_eq(type_arr.at(0)[&"health"], 100.0)
		assert_eq(type_arr.at(1)[&"speed"], 50.0)


	func test_type_arr_multiple_operations() -> void:
		var type_arr := GenesTable.TypeArr.new()

		# Добавляем несколько элементов
		for i in range(5):
			type_arr.append({ &"value": float(i) })

		assert_eq(type_arr.size(), 5)

		# Изменяем значение
		type_arr.set_at(2, { &"value": 99.0 })
		assert_eq(type_arr.at(2)[&"value"], 99.0)

		# Изменяем размер
		type_arr.resize(3)
		assert_eq(type_arr.size(), 3)

		# Проверяем оставшиеся значения
		assert_eq(type_arr.at(0)[&"value"], 0.0)
		assert_eq(type_arr.at(1)[&"value"], 1.0)
		assert_eq(type_arr.at(2)[&"value"], 99.0)


	func test_same_type_arr_equal() -> void:
		var type_arr1 := GenesTable.TypeArr.new()
		type_arr1.append({ &"health": 100.0 })
		type_arr1.append({ &"speed": 50.0 })
		type_arr1.append({ &"strength": 75.0 })

		var type_arr2 := GenesTable.TypeArr.new()
		type_arr2.append({ &"health": 100.0 })
		type_arr2.append({ &"speed": 50.0 })
		type_arr2.append({ &"strength": 75.0 })

		assert_true(type_arr1.is_equal(type_arr2))


	func test_different_type_arr_not_equal() -> void:
		var type_arr1 := GenesTable.TypeArr.new()
		type_arr1.append({ &"health": 100.0 })
		type_arr1.append({ &"speed": 50.0 })
		type_arr1.append({ &"strength": 75.0 })

		var type_arr2 := GenesTable.TypeArr.new()

		assert_false(type_arr1.is_equal(type_arr2))


	func test_type_arr_size_not_equal() -> void:
		var type_arr1 := GenesTable.TypeArr.new()
		type_arr1.append({ &"health": 100.0 })
		type_arr1.append({ &"speed": 50.0 })
		type_arr1.append({ &"strength": 75.0 })

		var type_arr2 := GenesTable.TypeArr.new()
		type_arr1.append({ &"health": 100.0 })
		type_arr1.append({ &"speed": 50.0 })

		assert_false(type_arr1.is_equal(type_arr2))


	func test_type_arr_names_not_equal() -> void:
		var type_arr1 := GenesTable.TypeArr.new()
		type_arr1.append({ &"health": 100.0 })
		type_arr1.append({ &"speed": 50.0 })
		type_arr1.append({ &"strength": 75.0 })

		var type_arr2 := GenesTable.TypeArr.new()
		type_arr1.append({ &"health": 100.0 })
		type_arr1.append({ &"speed": 50.0 })
		type_arr1.append({ &"size": 75.0 }) # другое имя

		assert_false(type_arr1.is_equal(type_arr2))


	func test_type_arr_values_not_equal() -> void:
		var type_arr1 := GenesTable.TypeArr.new()
		type_arr1.append({ &"health": 100.0 })
		type_arr1.append({ &"speed": 50.0 })
		type_arr1.append({ &"strength": 75.0 })

		var type_arr2 := GenesTable.TypeArr.new()
		type_arr1.append({ &"health": 100.0 })
		type_arr1.append({ &"speed": 80.0 }) # другое значение
		type_arr1.append({ &"strength": 75.0 })

		assert_false(type_arr1.is_equal(type_arr2))


class TestGenesTable:
	extends GutTest

	func test_creation_empty() -> void:
		var genes_table := GenesTable.new([])

		assert_eq(genes_table.get_types_amount(), 0, "Пустая таблица должна быть пустой")
		assert_eq(genes_table.data.size(), 0, "Пустая таблица должна быть пустой")


	func test_creation_single_gene() -> void:
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]
		var table := GenesTable.new(genes)

		assert_true(table.has_type(TEST_TYPE_1))
		assert_eq(table.get_types_amount(), 1)
		assert_eq(table.get_type_arr_size(TEST_TYPE_1), 1)
		assert_eq(table.get_type_data(TEST_TYPE_1, 0)[&"health"], 100.0)


	func test_creation_multiple_genes_same_type_same_index() -> void:
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_1, &"speed", 0, 50.0),
			Gene.new(TEST_TYPE_1, &"strength", 0, 75.0),
		]
		var table := GenesTable.new(genes)

		assert_eq(table.get_type_arr_size(TEST_TYPE_1), 1)
		assert_eq(table.get_types_amount(), 1)

		var params: Dictionary[StringName, float] = table.get_type_data(TEST_TYPE_1, 0)
		assert_eq(params.size(), 3)
		assert_eq(params[&"health"], 100.0)
		assert_eq(params[&"speed"], 50.0)
		assert_eq(params[&"strength"], 75.0)


	func test_creation_multiple_indices() -> void:
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_1, &"health", 1, 200.0),
			Gene.new(TEST_TYPE_1, &"speed", 1, 50.0),
			Gene.new(TEST_TYPE_1, &"strength", 2, 75.0),
		]
		var table := GenesTable.new(genes)

		assert_eq(table.get_type_arr_size(TEST_TYPE_1), 3)
		assert_eq(table.get_types_amount(), 1)
		assert_eq(table.get_type_data(TEST_TYPE_1, 0)[&"health"], 100.0)
		assert_eq(table.get_type_data(TEST_TYPE_1, 1)[&"health"], 200.0)
		assert_eq(table.get_type_data(TEST_TYPE_1, 1)[&"speed"], 50.0)
		assert_eq(table.get_type_data(TEST_TYPE_1, 2)[&"strength"], 75.0)


	func test_creation_duplicate_genes_ignored() -> void:
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_1, &"health", 0, 200.0), # дубликат
		]
		var table := GenesTable.new(genes)

		assert_eq(table.get_types_amount(), 1)
		assert_eq(table.get_type_arr_size(TEST_TYPE_1), 1)


	func test_creation_multiple_types() -> void:
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"length", 0, 50.0),
			Gene.new(TEST_TYPE_3, &"radius", 0, 25.0),
		]
		var table := GenesTable.new(genes)

		assert_true(table.has_type(TEST_TYPE_1))
		assert_true(table.has_type(TEST_TYPE_2))
		assert_true(table.has_type(TEST_TYPE_3))
		assert_eq(table.data.size(), 3)
		assert_eq(table.get_types_amount(), 3)

	# ===== Методы доступа =====


	func test_has_type() -> void:
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]
		var table := GenesTable.new(genes)

		assert_true(table.has_type(TEST_TYPE_1))
		assert_false(table.has_type(TEST_TYPE_2))


	func test_get_all_type_data() -> void:
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]
		var table := GenesTable.new(genes)

		var type_arr := table.get_all_type_data(TEST_TYPE_1)
		assert_not_null(type_arr)
		assert_eq(type_arr.size(), 1)

		var default_arr := table.get_all_type_data(TEST_TYPE_2, null)
		assert_null(default_arr)


	func test_get_all_type_data_or_assert() -> void:
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]
		var table := GenesTable.new(genes)

		var type_arr := table.get_all_type_data_or_assert(TEST_TYPE_1)
		assert_not_null(type_arr)
		assert_engine_error_count(0)


	func test_set_all_type_data() -> void:
		var table := GenesTable.new([])
		var new_type_arr := GenesTable.TypeArr.new()
		new_type_arr.append({ &"health": 100.0 })

		table.set_all_type_data(TEST_TYPE_1, new_type_arr)

		assert_true(table.has_type(TEST_TYPE_1))
		assert_eq(table.get_type_arr_size(TEST_TYPE_1), 1)
		assert_eq(table.get_type_data(TEST_TYPE_1, 0)[&"health"], 100.0)


	func test_add_type_data() -> void:
		var table := GenesTable.new([])

		table.add_type_data(TEST_TYPE_1)

		assert_true(table.has_type(TEST_TYPE_1))
		assert_eq(table.get_type_arr_size(TEST_TYPE_1), 0)
		assert_engine_error_count(0)


	func test_get_type_arr_size() -> void:
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_1, &"health", 1, 200.0),
			Gene.new(TEST_TYPE_1, &"health", 2, 300.0),
		]
		var table := GenesTable.new(genes)

		assert_eq(table.get_type_arr_size(TEST_TYPE_1), 3)
		assert_eq(table.get_type_arr_size(TEST_TYPE_2), 0, "Отсутствующий тип возвращает 0")


	func test_get_all_types() -> void:
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"health", 1, 200.0),
			Gene.new(TEST_TYPE_3, &"health", 2, 300.0),
		]
		var table := GenesTable.new(genes)
		assert_eq(table.get_types_amount(), 3)

		var types: Array[StringName] = table.get_all_types()
		assert_has(types, TEST_TYPE_1)
		assert_has(types, TEST_TYPE_2)
		assert_has(types, TEST_TYPE_3)
		assert_eq(types.size(), 3)


	func test_has_type_with_index() -> void:
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_1, &"health", 2, 200.0),
		]
		var table := GenesTable.new(genes)

		assert_true(table.has_type_with_index(TEST_TYPE_1, 0))
		assert_true(table.has_type_with_index(TEST_TYPE_1, 2))
		assert_false(table.has_type_with_index(TEST_TYPE_1, 1))
		assert_false(table.has_type_with_index(TEST_TYPE_2, 0))


	func test_get_type_data() -> void:
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_1, &"speed", 0, 50.0),
		]
		var table := GenesTable.new(genes)

		var params: Dictionary[StringName, float] = table.get_type_data(TEST_TYPE_1, 0)
		assert_eq(params[&"health"], 100.0)
		assert_eq(params[&"speed"], 50.0)

		# Несуществующий индекс
		var default_params: Dictionary[StringName, float] = table.get_type_data(
			TEST_TYPE_1,
			1,
			{ &"default": 0.0 },
		)
		assert_eq(default_params[&"default"], 0.0)

		# Несуществующий тип
		var empty_params: Dictionary[StringName, float] = table.get_type_data(TEST_TYPE_2, 0)
		assert_eq(empty_params.size(), 0)


	func test_get_type_data_or_assert() -> void:
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]
		var table := GenesTable.new(genes)

		var params: Dictionary[StringName, float] = table.get_type_data_or_assert(
			TEST_TYPE_1,
			0,
		)
		assert_eq(params[&"health"], 100.0)
		assert_engine_error_count(0)


	func test_set_type_data() -> void:
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]
		var table := GenesTable.new(genes)

		var new_params: Dictionary[StringName, float] = { &"health": 200.0, &"mana": 50.0 }
		table.set_type_data(TEST_TYPE_1, 0, new_params)

		var params := table.get_type_data(TEST_TYPE_1, 0)
		assert_eq(params[&"health"], 200.0)
		assert_eq(params[&"mana"], 50.0)


	func test_append_type_data() -> void:
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]
		var table := GenesTable.new(genes)

		table.append_type_data(TEST_TYPE_1, { &"speed": 50.0 })

		assert_eq(table.get_type_arr_size(TEST_TYPE_1), 2)
		assert_eq(table.get_type_data(TEST_TYPE_1, 0)[&"health"], 100.0)
		assert_eq(table.get_type_data(TEST_TYPE_1, 1)[&"speed"], 50.0)


	func test_resize_type_data() -> void:
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
		]
		var table := GenesTable.new(genes)

		table.resize_type_data(TEST_TYPE_1, 3)

		assert_eq(table.get_type_arr_size(TEST_TYPE_1), 3)
		assert_eq(table.get_type_data(TEST_TYPE_1, 0)[&"health"], 100.0)
		assert_eq(table.get_type_data(TEST_TYPE_1, 1).size(), 0)
		assert_eq(table.get_type_data(TEST_TYPE_1, 2).size(), 0)


	func test_into_array_of_genes() -> void:
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"health", 1, 200.0),
			Gene.new(TEST_TYPE_3, &"health", 2, 300.0),
		]
		var table := GenesTable.new(genes)
		var got_genes: Array[Gene] = table.into_array_of_genes()
		assert_eq(got_genes.size(), 3)

		var has_gene1 := false
		var has_gene2 := false
		var has_gene3 := false
		for i in range(3):
			var gene: Gene = got_genes[i]
			if gene.type == TEST_TYPE_1 \
					and gene.name == &"health" \
					and gene.index == 0 \
					and gene.value == 100.0:
				assert_false(has_gene1, "дубликат гена 1")
				has_gene1 = true
			if gene.type == TEST_TYPE_2 \
					and gene.name == &"health" \
					and gene.index == 1 \
					and gene.value == 200.0:
				assert_false(has_gene2, "дубликат гена 2")
				has_gene2 = true
			if gene.type == TEST_TYPE_3 \
					and gene.name == &"health" \
					and gene.index == 2 \
					and gene.value == 300.0:
				assert_false(has_gene3, "дубликат гена 3")
				has_gene3 = true
		assert_true(has_gene1, "нет гена 1")
		assert_true(has_gene2, "нет гена 2")
		assert_true(has_gene3, "нет гена 3")


	func test_duplicate_is_equal() -> void:
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"health", 1, 200.0),
			Gene.new(TEST_TYPE_3, &"health", 2, 300.0),
		]
		var table := GenesTable.new(genes)
		var table_dup: GenesTable = table.duplicate()

		assert_eq(table.get_types_amount(), table_dup.get_types_amount())
		assert_eq_deep(table.get_all_types(), table_dup.get_all_types())
		assert_true(table.is_equal(table_dup))


	func test_duplicate_is_not_reference() -> void:
		var genes: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"health", 1, 200.0),
			Gene.new(TEST_TYPE_3, &"health", 2, 300.0),
		]
		var table := GenesTable.new(genes)
		var table_dup: GenesTable = table.duplicate()

		assert_true(table.is_equal(table_dup))

		table.set_type_data(TEST_TYPE_1, 0, { &"size": 100.0 })
		assert_eq_deep(table_dup.get_type_data(TEST_TYPE_1, 0), { &"health": 100.0 })

		table.get_all_type_data_or_assert(TEST_TYPE_3).at(2)[&"health"] = 150.0
		assert_eq_deep(table_dup.get_type_data(TEST_TYPE_3, 2), { &"health": 300.0 })


	func test_same_data_equal() -> void:
		var genes1: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"health", 1, 200.0),
			Gene.new(TEST_TYPE_3, &"health", 2, 300.0),
		]
		var table1 := GenesTable.new(genes1)

		var genes2: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"health", 1, 200.0),
			Gene.new(TEST_TYPE_3, &"health", 2, 300.0),
		]
		var table2 := GenesTable.new(genes2)

		assert_true(table1.is_equal(table2))


	func test_different_data_not_equal() -> void:
		var genes1: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"health", 1, 200.0),
			Gene.new(TEST_TYPE_3, &"health", 2, 300.0),
		]
		var table1 := GenesTable.new(genes1)
		var table2 := GenesTable.new([])

		assert_false(table1.is_equal(table2))


	func test_data_size_not_equal() -> void:
		var genes1: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"health", 1, 200.0),
			Gene.new(TEST_TYPE_3, &"health", 2, 300.0),
		]
		var table1 := GenesTable.new(genes1)

		var genes2: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"health", 1, 200.0),
		]
		var table2 := GenesTable.new(genes2)

		assert_false(table1.is_equal(table2))


	func test_data_types_not_equal() -> void:
		var genes1: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"health", 1, 200.0),
			Gene.new(TEST_TYPE_3, &"health", 2, 300.0),
		]
		var table1 := GenesTable.new(genes1)

		var genes2: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"health", 1, 200.0),
			Gene.new(TEST_TYPE_2, &"health", 2, 300.0),
		]
		var table2 := GenesTable.new(genes2)

		assert_false(table1.is_equal(table2))


	func test_data_names_not_equal() -> void:
		var genes1: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"health", 1, 200.0),
			Gene.new(TEST_TYPE_3, &"health", 2, 300.0),
		]
		var table1 := GenesTable.new(genes1)

		var genes2: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"health", 1, 200.0),
			Gene.new(TEST_TYPE_3, &"size", 2, 300.0),
		]
		var table2 := GenesTable.new(genes2)

		assert_false(table1.is_equal(table2))


	func test_data_values_not_equal() -> void:
		var genes1: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"health", 1, 200.0),
			Gene.new(TEST_TYPE_3, &"health", 2, 300.0),
		]
		var table1 := GenesTable.new(genes1)

		var genes2: Array[Gene] = [
			Gene.new(TEST_TYPE_1, &"health", 0, 100.0),
			Gene.new(TEST_TYPE_2, &"health", 1, 200.0),
			Gene.new(TEST_TYPE_3, &"health", 2, 500.0),
		]
		var table2 := GenesTable.new(genes2)

		assert_false(table1.is_equal(table2))
