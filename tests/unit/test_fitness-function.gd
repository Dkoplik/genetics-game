extends GutTest


class TestInit:
	extends GutTest

	func test_empty_init() -> void:
		var ff := FitnessFunction.new()
		assert_eq(ff.get_summands_array(), PackedStringArray())
		assert_eq(ff.calculate({}), null)

	func test_constant_init() -> void:
		var ff := FitnessFunction.new("5", [])
		assert_eq(ff.get_summands_array(), ["5"] as PackedStringArray)
		assert_eq(ff.calculate({}), 5)

	func test_single_summand_init() -> void:
		var ff := FitnessFunction.new("x", ["x"])
		assert_eq(ff.get_summands_array(), ["x"] as PackedStringArray)
		assert_eq(ff.calculate({"x": 5}), 5)

	func test_multiple_summands_init() -> void:
		var ff := FitnessFunction.new(["x", "y"], ["x", "y"])
		assert_eq_deep(ff.get_summands_array(), ["x", "y"] as PackedStringArray)
		assert_eq(ff.calculate({"x": 2, "y": 3}), 5)


class TestAddSummand:
	extends GutTest

	func test_add_constant() -> void:
		var ff := FitnessFunction.new()
		var error: Error = ff.add_summand("5", [])
		assert_eq(error, Error.OK)
		assert_true(ff.contains("5"))
		assert_eq(ff.calculate({}), 5)

	func test_add_first_summand() -> void:
		var ff := FitnessFunction.new()
		var error: Error = ff.add_summand("x", ["x"])
		assert_eq(error, Error.OK)
		assert_true(ff.contains("x"))
		assert_eq(ff.calculate({"x": 5}), 5)

	func test_add_second_summand() -> void:
		var ff := FitnessFunction.new()
		ff.add_summand("x", ["x"])
		var error: Error = ff.add_summand("y", ["y"])
		assert_eq(error, Error.OK)
		assert_true(ff.contains("y"))
		assert_eq(ff.calculate({"x": 2, "y": 3}), 5)

	func test_add_summand_invalid_syntax() -> void:
		var ff := FitnessFunction.new()
		var error: Error = ff.add_summand("x + ", ["x"])
		assert_ne(error, Error.OK)

	func test_add_summand_with_unused_variable() -> void:
		var ff := FitnessFunction.new()
		ff.add_summand("x", ["x", "y"])
		assert_eq(ff.calculate({"x": 1, "y": 0}), 1)
		assert_eq(ff.calculate({"x": 1}), 1)


class TestRemoveSummand:
	extends GutTest

	func test_remove_only_summand() -> void:
		var ff := FitnessFunction.new()
		ff.add_summand("x", ["x"])
		var error: Error = ff.remove_summand("x", ["x"])
		assert_eq(error, Error.OK)
		assert_false(ff.contains("x"))
		assert_null(ff.calculate({"x": 5}))

	func test_remove_middle_summand() -> void:
		var ff := FitnessFunction.new()
		ff.add_summand("a", ["a"])
		ff.add_summand("b", ["b"])
		ff.add_summand("c", ["c"])
		ff.remove_summand("b", ["b"])
		assert_true(ff.contains("a") and ff.contains("c"))
		assert_eq(ff.calculate({"a": 1, "c": 3}), 4)

	func test_remove_summand_removes_unused_variable() -> void:
		var ff := FitnessFunction.new()
		ff.add_summand("x", ["x"])
		ff.add_summand("y", ["y"])
		ff.remove_summand("y", ["y"])
		assert_eq(ff.calculate({"x": 5}), 5)

	func test_remove_summand_keeps_used_variable() -> void:
		var ff := FitnessFunction.new()
		ff.add_summand("x", ["x"])
		ff.add_summand("x*y", ["x", "y"])
		assert_eq(ff.calculate({"x": 2, "y": 3}), 8)
		ff.remove_summand("x", ["x"])
		assert_eq(ff.calculate({"x": 2, "y": 3}), 6)


class TestContains:
	extends GutTest

	func test_contains_existing_summand() -> void:
		var ff := FitnessFunction.new()
		ff.add_summand("x", ["x"])
		assert_true(ff.contains("x"))

	func test_contains_non_existing_summand() -> void:
		var ff := FitnessFunction.new()
		assert_false(ff.contains("x"))

	func test_contains_partial_match() -> void:
		var ff := FitnessFunction.new()
		ff.add_summand("xy", ["x", "y"])
		assert_false(ff.contains("x"))


class TestGetSummandsArray:
	extends GutTest

	func test_empty_function() -> void:
		var ff := FitnessFunction.new()
		assert_eq(ff.get_summands_array(), PackedStringArray())

	func test_single_summand() -> void:
		var ff := FitnessFunction.new("x", ["x"])
		assert_eq(ff.get_summands_array(), ["x"] as PackedStringArray)

	func test_multiple_summands() -> void:
		var ff := FitnessFunction.new(["x", "y", "z"], ["x", "y", "z"])
		var summands = ff.get_summands_array()
		assert_true(summands.has("x") and summands.has("y") and summands.has("z"))


class TestCalculate:
	extends GutTest

	func test_calculate_valid_expression() -> void:
		var ff := FitnessFunction.new()
		ff.add_summand("x + y", ["x", "y"])
		assert_eq(ff.calculate({"x": 2, "y": 3}), 5)

	func test_calculate_execution_error() -> void:
		var ff := FitnessFunction.new()
		ff.add_summand("1 / x", ["x"])
		assert_null(ff.calculate({"x": 0}))

	func test_calculate_variable_order() -> void:
		var ff := FitnessFunction.new()
		ff.add_summand("a + 2*b", ["a", "b"])
		assert_eq(ff.calculate({"b": 3, "a": 2}), 8)


class TestDuplicate:
	extends GutTest

	func test_duplicate_empty() -> void:
		var ff := FitnessFunction.new()
		var ff2 := ff.duplicate()
		ff.add_summand("x + y", ["x", "y"])
		assert_eq_deep(ff2.get_summands_array(), [] as PackedStringArray)
		assert_eq(ff.calculate({"x": 2, "y": 3}), 5)
		assert_eq(ff2.calculate({"x": 2, "y": 3}), null)

	func test_duplicate_not_empty() -> void:
		var ff := FitnessFunction.new(["a", "2*b"], ["a", "b"])
		var ff2 := ff.duplicate()
		assert_eq(ff.calculate({"b": 3, "a": 2}), 8)
		assert_eq(ff2.calculate({"b": 3, "a": 2}), 8)
		ff2.remove_summand("a", ["a"])
		assert_eq(ff.calculate({"b": 3, "a": 2}), 8)
		assert_eq(ff2.calculate({"b": 3, "a": 2}), 6)
