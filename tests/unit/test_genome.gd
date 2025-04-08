extends GutTest


class TestInitAndGetAllParams:
	extends GutTest

	func test_one_false_boolean_init() -> void:
		var params: Array[bool] = [false]
		var genome := Genome.new(params)
		assert_eq_deep(genome.get_all_params(), params)

	func test_one_true_boolean_init() -> void:
		var params: Array[bool] = [true]
		var genome := Genome.new(params)
		assert_eq_deep(genome.get_all_params(), params)

	func test_multiple_boolean_init() -> void:
		var params: Array[bool] = [true, false, false, true, false, true]
		var genome := Genome.new(params)
		assert_eq_deep(genome.get_all_params(), params)

	func test_one_min_int_init() -> void:
		var params: Array[int] = [Numeric.INT_MIN]
		var genome := Genome.new(params)
		assert_eq_deep(genome.get_all_params(), params)

	func test_one_max_int_init() -> void:
		var params: Array[int] = [Numeric.INT_MAX]
		var genome := Genome.new(params)
		assert_eq_deep(genome.get_all_params(), params)

	func test_one_zero_int_init() -> void:
		var params: Array[int] = [0]
		var genome := Genome.new(params)
		assert_eq_deep(genome.get_all_params(), params)

	func test_multiple_int_init() -> void:
		var params: Array[int] = [Numeric.INT_MIN, -1, 0, 1, Numeric.INT_MAX]
		var genome := Genome.new(params)
		assert_eq_deep(genome.get_all_params(), params)

	func test_one_min_float_init() -> void:
		var params: Array[float] = [Numeric.FLOAT_MIN]
		var genome := Genome.new(params)
		assert_eq_deep(genome.get_all_params(), params)

	func test_one_max_float_init() -> void:
		var params: Array[float] = [Numeric.FLOAT_MAX]
		var genome := Genome.new(params)
		assert_eq_deep(genome.get_all_params(), params)

	func test_one_zero_float_init() -> void:
		var params: Array[float] = [0.0]
		var genome := Genome.new(params)
		assert_eq_deep(genome.get_all_params(), params)

	func test_multiple_float_init() -> void:
		var params: Array[float] = [Numeric.FLOAT_MIN, -1., 0., 1., Numeric.FLOAT_MAX]
		var genome := Genome.new(params)
		assert_eq_deep(genome.get_all_params(), params)

	func test_multiple_mixed_types_init() -> void:
		var params: Array = [3.14, false, 5, -3.5, true, -42]
		# Все булевы переменные перемещаются в конец в неизменном порядке.
		var res_params: Array = [3.14, 5, -3.5, -42, false, true]
		var genome := Genome.new(params)
		assert_eq_deep(genome.get_all_params(), res_params)


class TestInitAndGetAllBytes:
	extends GutTest

	func test_one_boolean_init() -> void:
		var params: Array[bool] = [true]
		var genome := Genome.new(params)

		var bytes := PackedByteArray([1])
		assert_eq_deep(genome.get_all_bytes(), bytes)

	func test_multiple_boolean_init() -> void:
		var params: Array[bool] = [true, false, false, true, false, true]
		var genome := Genome.new(params)

		var bytes := PackedByteArray([41])
		assert_eq_deep(genome.get_all_bytes(), bytes)

	func test_one_min_int_init() -> void:
		var params: Array[int] = [Numeric.INT_MIN]
		var genome := Genome.new(params)

		var bytes := PackedByteArray([0, 0, 0, 0, 0, 0, 0, 128])
		assert_eq_deep(genome.get_all_bytes(), bytes)

	func test_one_max_int_init() -> void:
		var params: Array[int] = [Numeric.INT_MAX]
		var genome := Genome.new(params)

		var bytes := PackedByteArray([255, 255, 255, 255, 255, 255, 255, 127])
		assert_eq_deep(genome.get_all_bytes(), bytes)

	func test_one_min_float_init() -> void:
		var params: Array[float] = [Numeric.FLOAT_MIN]
		var genome := Genome.new(params)

		var bytes := PackedByteArray([174, 130, 202, 87, 252, 255, 239, 255])
		assert_eq_deep(genome.get_all_bytes(), bytes)

	func test_one_max_float_init() -> void:
		var params: Array[float] = [Numeric.FLOAT_MAX]
		var genome := Genome.new(params)

		var bytes := PackedByteArray([174, 130, 202, 87, 252, 255, 239, 127])
		assert_eq_deep(genome.get_all_bytes(), bytes)


class TestSetGetParam:
	extends GutTest

	func test_set_get_one_boolean() -> void:
		var params: Array[bool] = [false]
		var genome := Genome.new(params)

		assert_eq(genome.get_param(0), false)
		genome.set_param(0, true)
		assert_eq(genome.get_param(0), true)

	func test_set_get_multiple_boolean() -> void:
		var params: Array[bool] = [true, false, false, true, false, false]
		var genome := Genome.new(params)

		assert_eq(genome.get_param(0), true)
		genome.set_param(0, false)
		assert_eq(genome.get_param(0), false)

		assert_eq(genome.get_param(5), false)
		genome.set_param(5, true)
		assert_eq(genome.get_param(5), true)

	func test_set_get_min_int() -> void:
		var params: Array[int] = [Numeric.INT_MIN]
		var genome := Genome.new(params)

		assert_eq(genome.get_param(0), Numeric.INT_MIN)
		genome.set_param(0, 42)
		assert_eq(genome.get_param(0), 42)

	func test_set_get_max_int() -> void:
		var params: Array[int] = [Numeric.INT_MAX]
		var genome := Genome.new(params)

		assert_eq(genome.get_param(0), Numeric.INT_MAX)
		genome.set_param(0, 42)
		assert_eq(genome.get_param(0), 42)

	func test_set_get_multiple_int() -> void:
		var params: Array[int] = [Numeric.INT_MIN, -1, 0, 1, Numeric.INT_MAX]
		var genome := Genome.new(params)

		assert_eq(genome.get_param(0), Numeric.INT_MIN)
		genome.set_param(0, 42)
		assert_eq(genome.get_param(0), 42)

		assert_eq(genome.get_param(4), Numeric.INT_MAX)
		genome.set_param(4, 42)
		assert_eq(genome.get_param(4), 42)

	func test_set_get_min_float() -> void:
		var params: Array[float] = [Numeric.FLOAT_MIN]
		var genome := Genome.new(params)

		assert_almost_eq(genome.get_param(0), Numeric.FLOAT_MIN, Numeric.EPS)
		genome.set_param(0, 3.14)
		assert_almost_eq(genome.get_param(0), 3.14, Numeric.EPS)

	func test_set_get_max_float() -> void:
		var params: Array[float] = [Numeric.FLOAT_MAX]
		var genome := Genome.new(params)

		assert_almost_eq(genome.get_param(0), Numeric.FLOAT_MAX, Numeric.EPS)
		genome.set_param(0, 3.14)
		assert_almost_eq(genome.get_param(0), 3.14, Numeric.EPS)

	func test_set_get_multiple_float() -> void:
		var params: Array[float] = [Numeric.FLOAT_MIN, -1., 0., 1., Numeric.FLOAT_MAX]
		var genome := Genome.new(params)

		assert_almost_eq(genome.get_param(0), Numeric.FLOAT_MIN, Numeric.EPS)
		genome.set_param(0, 3.14)
		assert_almost_eq(genome.get_param(0), 3.14, Numeric.EPS)

		assert_almost_eq(genome.get_param(4), Numeric.FLOAT_MAX, Numeric.EPS)
		genome.set_param(4, 3.14)
		assert_almost_eq(genome.get_param(4), 3.14, Numeric.EPS)


class TestSetGetByte:
	extends GutTest

	var err_msg: String

	func test_set_get_byte_single_bool() -> void:
		var genome := Genome.new([true])  # 1000_0000
		err_msg = "Байтовое представление единственной булевой переменной не совпало"
		assert_eq(genome.get_byte(0), 1, err_msg)

		genome.set_byte(0, 2)  # 0100_0000
		err_msg = "Байт изменился некорректно или не изменился"
		assert_eq(genome.get_byte(0), 2, err_msg)

		err_msg = "Байтовое изменение булевого типа не совпало с реальным значением"
		assert_eq(genome.get_param(0), false, err_msg)

	func test_set_get_byte_eight_bools() -> void:
		var genome := Genome.new([true, false, true, true, false, false, true, true])
		err_msg = "Байтовое представление 8-ми булевых переменных не совпало"
		assert_eq(genome.get_byte(0), 205, err_msg)  # 1011_0011

		genome.set_byte(0, 90)  # 0101_1010
		err_msg = "Байт изменился некорректно или не изменился"
		assert_eq(genome.get_byte(0), 90, err_msg)

		var res: Array[bool] = [false, true, false, true, true, false, true, false]
		assert_eq_deep(genome.get_all_params(), res)

	func test_set_get_byte_nine_bools() -> void:
		var genome := Genome.new([true, false, true, true, false, false, true, true, true])
		err_msg = "Байтовое представление 8-ми первых булевых переменных не совпало"
		assert_eq(genome.get_byte(0), 205, err_msg)  # 1011_0011
		err_msg = "Байтовое представление 9-ой булевой переменной не совпало"
		assert_eq(genome.get_byte(1), 1, err_msg)  # 1000_0000

		genome.set_byte(1, 0)
		err_msg = "Байт изменился некорректно или не изменился"
		assert_eq(genome.get_byte(1), 0, err_msg)

		err_msg = "Изменился не тот байт"
		assert_eq(genome.get_byte(0), 205, err_msg)

		err_msg = "Байтовое изменение 9-ой булевой переменной не совпало с реальным значением"
		assert_eq(genome.get_param(8), false, err_msg)

	func test_set_get_byte_min_int() -> void:
		var genome := Genome.new([Numeric.INT_MIN])
		# 0        1        2        3        4        5        6        7
		# 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000001
		var byte_vals := PackedByteArray([0, 0, 0, 0, 0, 0, 0, 128])
		assert_eq_deep(genome.get_all_bytes(), byte_vals)

		genome.set_byte(7, 0)
		err_msg = "Байт изменился некорректно или не изменился"
		assert_eq(genome.get_byte(7), 0, err_msg)

		byte_vals[7] = 0
		assert_eq_deep(genome.get_all_bytes(), byte_vals)

		err_msg = "Байтовое изменение целого числа не совпало с реальным значением"
		assert_eq(genome.get_param(0), 0, err_msg)

	func test_set_get_byte_max_int() -> void:
		var genome := Genome.new([Numeric.INT_MAX])
		# 0        1        2        3        4        5        6        7
		# 11111111 11111111 11111111 11111111 11111111 11111111 11111111 11111110
		var byte_vals := PackedByteArray([255, 255, 255, 255, 255, 255, 255, 127])
		assert_eq_deep(genome.get_all_bytes(), byte_vals)

		genome.set_byte(0, 254)  # 0111_1111
		err_msg = "Байт изменился некорректно или не изменился"
		assert_eq(genome.get_byte(0), 254, err_msg)

		byte_vals[0] = 254
		assert_eq_deep(genome.get_all_bytes(), byte_vals)

		err_msg = "Байтовое изменение целого числа не совпало с реальным значением"
		assert_eq(genome.get_param(0), Numeric.INT_MAX - 1, err_msg)

	func test_set_get_byte_min_float() -> void:
		var genome := Genome.new([Numeric.FLOAT_MIN])
		# 0        1        2        3        4        5        6        7
		# 01110101 01000001 01010011 11101010 00111111 11111111 11110111 11111111
		var byte_vals := PackedByteArray([174, 130, 202, 87, 252, 255, 239, 255])
		assert_eq_deep(genome.get_all_bytes(), byte_vals)

		for i in range(8):
			genome.set_byte(i, 0)
			err_msg = "Байт не поменялся"
			assert_eq(genome.get_byte(i), 0, err_msg)

		err_msg = "Байтовое изменение вещественного числа не совпало с реальным значением"
		assert_almost_eq(genome.get_param(0), 0.0, Numeric.EPS, err_msg)

	func test_set_get_byte_max_float() -> void:
		var genome := Genome.new([Numeric.FLOAT_MAX])
		# 0        1        2        3        4        5        6        7
		# 01110101 01000001 01010011 11101010 00111111 11111111 11110111 11111110
		var byte_vals := PackedByteArray([174, 130, 202, 87, 252, 255, 239, 127])
		assert_eq_deep(genome.get_all_bytes(), byte_vals)

		for i in range(8):
			genome.set_byte(i, 0)
			err_msg = "Байт не поменялся"
			assert_eq(genome.get_byte(i), 0, err_msg)

		err_msg = "Байтовое изменение вещественного числа не совпало с реальным значением"
		assert_almost_eq(genome.get_param(0), 0.0, Numeric.EPS, err_msg)

	func test_set_get_byte_mutiple_types() -> void:
		var genome := Genome.new([true, Numeric.INT_MAX, false, Numeric.FLOAT_MIN])
		# Для целого
		# 0        1        2        3        4        5        6        7
		# 11111111 11111111 11111111 11111111 11111111 11111111 11111111 11111110
		# Для вещественного
		# 0        1        2        3        4        5        6        7
		# 01110101 01000001 01010011 11101010 00111111 11111111 11110111 11111111

		genome.set_byte(0, 254)  # 1111_1110
		err_msg = "Байт не поменялся"
		assert_eq(genome.get_byte(0), 254, err_msg)
		err_msg = "Байтовое изменение целого числа не совпало с реальным значением"
		assert_eq(genome.get_param(0), Numeric.INT_MAX - 1, err_msg)

		for i in range(8):
			genome.set_byte(8 + i, 0)
			err_msg = "Байт не поменялся"
			assert_eq(genome.get_byte(8 + i), 0, err_msg)
		err_msg = "Байтовое изменение вещественного числа не совпало с реальным значением"
		assert_almost_eq(genome.get_param(1), 0.0, Numeric.EPS, err_msg)

		genome.set_byte(8 + 8, 2)  # 0100_0000
		err_msg = "Изменение байта с булевыми переменными не совпало"
		assert_eq(genome.get_byte(8 + 8), 2, err_msg)
		err_msg = "Байтовое изменение булевых типов не совпало с реальным значением"
		assert_eq(genome.get_param(2), false, err_msg)
		assert_eq(genome.get_param(3), true, err_msg)


class TestSetGetBit:
	extends GutTest

	var err_msg: String

	func test_set_get_bit_single_bool() -> void:
		var genome := Genome.new([false])
		err_msg = "Битовое представление булевой переменной не совпало"
		assert_eq(genome.get_bit(0), 0, err_msg)

		genome.set_bit(0, 1)
		err_msg = "Бит изменился некорректно или не изменился"
		assert_eq(genome.get_bit(0), 1, err_msg)

		err_msg = "Изменён не тот бит"
		for i in range(1, 8):
			assert_eq(genome.get_bit(i), 0, err_msg)
		err_msg = "Битовой изменение булевой переменной не совпало с реальным значением"
		assert_eq(genome.get_param(0), true, err_msg)

	func test_set_get_bit_eight_bools() -> void:
		var genome := Genome.new([true, false, true, true, false, false, true, true])
		err_msg = "Битовое представление 8-ой булевой переменной не совпало"
		assert_eq(genome.get_bit(7), 1, err_msg)

		genome.set_bit(7, 0)
		err_msg = "Бит изменился некорректно или не изменился"
		assert_eq(genome.get_bit(7), 0, err_msg)

		var res: Array[bool] = [true, false, true, true, false, false, true, false]
		assert_eq_deep(genome.get_all_params(), res)

	func test_set_get_bit_nine_bools() -> void:
		var genome := Genome.new([true, false, true, true, false, false, true, true, true])
		err_msg = "Битовое представление булевых переменных не совпало в {0} бите"
		var vals: Array[int] = [1, 0, 1, 1, 0, 0, 1, 1, 1]
		for i in range(9):
			var got: Variant = genome.get_bit(i)
			var expected: Variant = vals[i]
			assert_eq(got, expected, err_msg.format([i]))

		genome.set_bit(8, 0)
		err_msg = "Бит изменился некорректно или не изменился"
		assert_eq(genome.get_bit(8), 0, err_msg)

		vals.pop_back()
		err_msg = "{0} бит не должен был меняться"
		for i in range(8):
			var got: Variant = genome.get_bit(i)
			var expected: Variant = vals[i]
			assert_eq(got, expected, err_msg.format([i]))

		err_msg = "Битовое изменение 9-ой булевой переменной не совпало с реальным значением"
		assert_eq(genome.get_param(8), false, err_msg)

	func test_set_get_bit_min_int() -> void:
		var genome := Genome.new([Numeric.INT_MIN])
		# 0        1        2        3        4        5        6        7
		# 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000001
		genome.set_bit(63, 0)
		err_msg = "Бит изменился некорректно или не изменился"
		assert_eq(genome.get_bit(63), 0, err_msg)

		err_msg = "Битовое изменение целого числа не совпало с реальным значением"
		assert_eq(genome.get_param(0), 0, err_msg)

	func test_set_get_bit_max_int() -> void:
		var genome := Genome.new([Numeric.INT_MAX])
		# 0        1        2        3        4        5        6        7
		# 11111111 11111111 11111111 11111111 11111111 11111111 11111111 11111110
		genome.set_bit(63, 1)
		err_msg = "Бит изменился некорректно или не изменился"
		assert_eq(genome.get_bit(63), 1, err_msg)

		err_msg = "Битовое изменение целого числа не совпало с реальным значением"
		assert_eq(genome.get_param(0), -1, err_msg)

	func test_set_get_bit_min_float() -> void:
		var genome := Genome.new([Numeric.FLOAT_MIN])
		# 0        1        2        3        4        5        6        7
		# 01110101 01000001 01010011 11101010 00111111 11111111 11110111 11111111
		genome.set_bit(63, 0)
		err_msg = "Бит изменился некорректно или не изменился"
		assert_eq(genome.get_bit(63), 0, err_msg)

		err_msg = "Битовое изменение вещественного числа не совпало с реальным значением"
		assert_almost_eq(genome.get_param(0), -Numeric.FLOAT_MIN, Numeric.EPS, err_msg)

	func test_set_get_bit_max_float() -> void:
		var genome := Genome.new([Numeric.FLOAT_MAX])
		# 0        1        2        3        4        5        6        7
		# 01110101 01000001 01010011 11101010 00111111 11111111 11110111 11111110
		genome.set_bit(63, 1)
		err_msg = "Бит изменился некорректно или не изменился"
		assert_eq(genome.get_bit(63), 1, err_msg)

		err_msg = "Битовое изменение вещественного числа не совпало с реальным значением"
		assert_almost_eq(genome.get_param(0), -Numeric.FLOAT_MAX, Numeric.EPS, err_msg)

	func test_set_get_bit_mutiple_types() -> void:
		var genome := Genome.new([true, Numeric.INT_MAX, false, Numeric.FLOAT_MIN])
		# Для целого
		# 0        1        2        3        4        5        6        7
		# 11111111 11111111 11111111 11111111 11111111 11111111 11111111 11111110
		# Для вещественного
		# 0        1        2        3        4        5        6        7
		# 01110101 01000001 01010011 11101010 00111111 11111111 11110111 11111111

		genome.set_bit(63, 1)
		err_msg = "Бит изменился некорректно или не изменился"
		assert_eq(genome.get_bit(63), 1, err_msg)
		err_msg = "Битовое изменение целого числа не совпало с реальным значением"
		assert_eq(genome.get_param(0), -1, err_msg)

		genome.set_bit(64 + 63, 0)
		err_msg = "Бит изменился некорректно или не изменился"
		assert_eq(genome.get_bit(64 + 63), 0, err_msg)
		err_msg = "Битовое изменение вещественного числа не совпало с реальным значением"
		assert_almost_eq(genome.get_param(1), -Numeric.FLOAT_MIN, Numeric.EPS, err_msg)

		genome.set_bit(2 * 64, 0)
		err_msg = "Бит изменился некорректно или не изменился"
		assert_eq(genome.get_bit(2 * 64), 0, err_msg)
		err_msg = "Битовое изменение булевых типов не совпало с реальным значением"
		assert_eq(genome.get_param(2), false, err_msg)
