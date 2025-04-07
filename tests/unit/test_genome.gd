extends GutTest


class TestInitAndGetParam:
	extends GutTest

	var err_msg: String = "{0}-ый параметр не совпал"

	func test_one_false_boolean_init():
		var genome := Genome.new([false])
		assert_eq(genome.get_param(0), false)

	func test_one_true_boolean_init():
		var genome = Genome.new([true])
		assert_eq(genome.get_param(0), true)

	func test_multiple_boolean_init():
		var params: Array[bool] = [true, false, false, true, false, true]
		var genome := Genome.new(params)

		for i in range(len(params)):
			var got: Variant = genome.get_param(i)
			var expected: Variant = params[i]
			assert_eq(got, expected, err_msg.format([i]))

	func test_one_min_int_init():
		var genome := Genome.new([Numeric.INT_MIN])
		assert_eq(genome.get_param(0), Numeric.INT_MIN)

	func test_one_max_int_init():
		var genome := Genome.new([Numeric.INT_MAX])
		assert_eq(genome.get_param(0), Numeric.INT_MAX)

	func test_one_zero_int_init():
		var genome := Genome.new([0])
		assert_eq(genome.get_param(0), 0)

	func test_multiple_int_init():
		var params: Array[int] = [Numeric.INT_MIN, -1, 0, 1, Numeric.INT_MAX]
		var genome := Genome.new(params)

		for i in range(len(params)):
			var got: Variant = genome.get_param(i)
			var expected: Variant = params[i]
			assert_eq(got, expected, err_msg.format([i]))

	func test_one_min_float_init():
		var genome := Genome.new([Numeric.FLOAT_MIN])
		assert_almost_eq(genome.get_param(0), Numeric.FLOAT_MIN, Numeric.EPS)

	func test_one_max_float_init():
		var genome := Genome.new([Numeric.FLOAT_MAX])
		assert_almost_eq(genome.get_param(0), Numeric.FLOAT_MAX, Numeric.EPS)

	func test_one_zero_float_init():
		var genome := Genome.new([0.0])
		assert_almost_eq(genome.get_param(0), 0.0, Numeric.EPS)

	func test_multiple_float_init():
		var params: Array[float] = [Numeric.FLOAT_MIN, -1., 0., 1., Numeric.FLOAT_MAX]
		var genome := Genome.new(params)

		for i in range(len(params)):
			var got: Variant = genome.get_param(i)
			var expected: Variant = params[i]
			assert_almost_eq(got, expected, Numeric.EPS, err_msg.format([i]))

	func test_multiple_mixed_types_init():
		var params: Array = [3.14, false, 5, -3.5, true, -42]
		# Все булевы переменные перемещаются в конец в неизменном порядке.
		var res_params: Array = [3.14, 5, -3.5, -42, false, true]
		var genome := Genome.new(params)

		for i in range(len(params)):
			var got: Variant = genome.get_param(i)
			var expected: Variant = res_params[i]
			if typeof(got) == TYPE_FLOAT:
				assert_almost_eq(got, expected, Numeric.EPS, err_msg.format([i]))
			else:
				assert_eq(got, expected, err_msg.format([i]))


class TestSetGetParam:
	extends GutTest

	var genome: Genome

	func before_each():
		genome = Genome.new([true, 3.14, 10, false, -9.5, -5])

	func test_setget_bool():
		# Все булевы переменные перемещаются в конец в неизменном порядке.
		assert_eq(genome.get_param(4), true)
		genome.set_param(4, false)
		assert_eq(genome.get_param(4), false)

		assert_eq(genome.get_param(5), false)

	func test_setget_int():
		assert_eq(genome.get_param(1), 10)
		genome.set_param(1, -42)
		assert_eq(genome.get_param(1), -42)

		assert_eq(genome.get_param(3), -5)

	func test_setget_float():
		assert_almost_eq(genome.get_param(0), 3.14, Numeric.EPS)
		genome.set_param(0, 12.32)
		assert_almost_eq(genome.get_param(0), 12.32, Numeric.EPS)

		assert_almost_eq(genome.get_param(2), -9.5, Numeric.EPS)


class TestSetGetByte:
	extends GutTest

	var err_msg: String

	func test_set_get_byte_single_bool():
		var genome := Genome.new([true])
		# Каждая булева переменная является 1 битом дополненная или объединённая
		# с другими до 1 байта. Биты булевых переменных идут слева направо.
		err_msg = "Байтовое представление единственной булевой переменной не совпало"
		assert_eq(genome.get_byte(0), 128, err_msg)
		
		genome.set_byte(0, 64) # Перенести True на следующий несуществующий bool
		err_msg = "Байт изменился некорректно"
		assert_eq(genome.get_byte(0), 64, err_msg)
		
		err_msg = "Байтовое изменение булевого типа не совпало с реальным значением"
		assert_eq(genome.get_param(0), false, err_msg)
	
	func test_set_get_byte_eight_bools():
		var genome := Genome.new([true, false, true, true, false, false, true, true])
		err_msg = "Байтовое представление 8-ми булевых переменных не совпало"
		assert_eq(genome.get_byte(0), 179, err_msg)
		
		genome.set_byte(0, 90) # 0101_1010
		err_msg = "Байт изменился некорректно"
		assert_eq(genome.get_byte(0), 90, err_msg)
		
		err_msg = "Байтовое изменение {0}-ой булевой переменной не совпало с реальным значением"
		var res: Array[bool] = [false, true, false, true, true, false, true, false]
		for i in range(len(res)):
			var got: Variant = genome.get_param(i)
			var expected: Variant = res[i]
			assert_eq(got, expected, err_msg.format(i))
	
	func test_set_get_byte_nine_bools():
		var genome := Genome.new([true, false, true, true, false, false, true, true, true])
		err_msg = "Байтовое представление 8-ми первых булевых переменных не совпало"
		assert_eq(genome.get_byte(0), 179, err_msg)
		err_msg = "Байтовое представление 9-ой булевой переменной не совпало"
		assert_eq(genome.get_byte(1), 128, err_msg)
		
		genome.set_byte(1, 0)
		err_msg = "Байт изменился некорректно"
		assert_eq(genome.get_byte(1), 0, err_msg)
		err_msg = "Изменился не тот байт"
		assert_eq(genome.get_byte(0), 179, err_msg)
		
		err_msg = "Байтовое изменение 9-ой булевой переменной не совпало с реальным значением"
		assert_eq(genome.get_param(8), false, err_msg)

	func test_set_get_byte_single_int():
		var genome := Genome.new([573])
		# 0        1        2        3        4        5        6        7
		# 00000000_00000000_00000000_00000000_00000000_00000000_00000010_00111101
		err_msg = "Последний байт (самый младший) целого числа не совпал"
		assert_eq(genome.get_byte(7), 61, err_msg)
		err_msg = "Предпоследний байт (почти самый младший) целого числа не совпал"
		assert_eq(genome.get_byte(6), 2, err_msg)
		err_msg = "{0} байт целого числа должен быть 0"
		for i in range(6):
			assert_eq(genome.get_byte(i), 0, err_msg.format(i))
		
		genome.set_byte(4, 128) # 1000_0000
		err_msg = "Изменение байта не совпало"
		assert_eq(genome.get_byte(4), 128, err_msg)
		
		err_msg = "Именён не тот байт"
		assert_eq(genome.get_byte(7), 61, err_msg)
		assert_eq(genome.get_byte(6), 2, err_msg)
		assert_eq(genome.get_byte(5), 0, err_msg)
		for i in range(4):
			assert_eq(genome.get_byte(i), 0, err_msg.format(i))
		
		err_msg = "Байтовое изменение целого числа не совпало с реальным значением"
		assert_eq(genome.get_param(0), 2147484221)

	func test_set_get_byte_single_float():
		var genome := Genome.new([345.893])
		# 0        1        2        3        4        5        6        7
		# 01000000_01110101_10011110_01001001_10111010_01011110_00110101_00111111
		err_msg = "{0} байт вещественного числа не совпал"
		var byte_vals: Array[int] = [64, 117, 158, 73, 186, 94, 53, 63]
		for i in range(8):
			var got: Variant = genome.get_byte(i)
			var expected: Variant = byte_vals[i]
			assert_eq(got, expected, err_msg.format(i))
		
		genome.set_byte(1, 245) # 1111_0101
		err_msg = "Изменение байта не совпало"
		assert_eq(genome.get_byte(1), 245, err_msg)
		
		err_msg = "Именён не тот байт"
		assert_eq(genome.get_byte(0), byte_vals[0], err_msg)
		for i in range(2, 8):
			var got: Variant = genome.get_byte(i)
			var expected: Variant = byte_vals[i]
			assert_eq(got, expected, err_msg.format(i))
		
		err_msg = "Байтовое изменение вещественного числа не совпало с реальным значением"
		assert_almost_eq(genome.get_param(0), 88548.608, Numeric.EPS)
	
	func test_set_get_byte_mutiple_types():
		var genome := Genome.new([true, 573, 345.893, false])
		# Для целого
		# 0        1        2        3        4        5        6        7
		# 00000000_00000000_00000000_00000000_00000000_00000000_00000010_00111101
		# Для вещественного
		# 0        1        2        3        4        5        6        7
		# 01000000_01110101_10011110_01001001_10111010_01011110_00110101_00111111
		
		genome.set_byte(0 + 4, 128) # 1000_0000
		err_msg = "Изменение байта целого числа не совпало"
		assert_eq(genome.get_byte(0 + 4), 128, err_msg)
		err_msg = "Байтовое изменение целого числа не совпало с реальным значением"
		assert_eq(genome.get_param(0), 2147484221)
		
		genome.set_byte(8 + 1, 245) # 1111_0101
		err_msg = "Изменение байта вещественного числа не совпало"
		assert_eq(genome.get_byte(8 + 1), 245, err_msg)
		err_msg = "Байтовое изменение вещественного числа не совпало с реальным значением"
		assert_almost_eq(genome.get_param(1), 88548.608, Numeric.EPS)

		genome.set_byte(2, 64) # 0100_0000
		err_msg = "Изменение байта с булевыми переменными не совпало"
		assert_eq(genome.get_byte(2), 64, err_msg)
		err_msg = "Байтовое изменение булевых типов не совпало с реальным значением"
		assert_eq(genome.get_param(2), false, err_msg)
		assert_eq(genome.get_param(3), true, err_msg)


class TestSetGetBit:
	extends GutTest

	var err_msg: String

	func test_set_get_bit_single_bool():
		var genome := Genome.new([false])
		err_msg = "Битовое представление булевой переменной не совпало"
		assert_eq(genome.get_bit(0), 0, err_msg)
		
		genome.set_bit(0, 1)
		err_msg = "Изменение бита с булевой переменной не совпало"
		assert_eq(genome.get_bit(0), 1, err_msg)
		
		err_msg = "Изменён не тот бит"
		for i in range(1, 8):
			assert_eq(genome.get_bit(i), 0, err_msg)
		err_msg = "Битовой изменение булевой переменной не совпало с реальным значением"
		assert_eq(genome.get_param(0), true, err_msg)
	
	func test_set_get_bit_eight_bools():
		var genome := Genome.new([true, false, true, true, false, false, true, true])
		err_msg = "Битовое представление 8-ой булевой переменной не совпало"
		assert_eq(genome.get_bit(7), 1, err_msg)
		
		genome.set_bit(7, 0)
		err_msg = "Изменение бита с булевой переменной не совпало"
		assert_eq(genome.get_bit(7), 0, err_msg)
		
		err_msg = "{0} бит не должен был меняться"
		var res: Array[bool] = [true, false, true, true, false, false, true]
		for i in range(len(res)):
			var got: Variant = genome.get_param(i)
			var expected: Variant = res[i]
			assert_eq(got, expected, err_msg.format(i))
	
	func test_set_get_bit_nine_bools():
		var genome := Genome.new([true, false, true, true, false, false, true, true, true])
		err_msg = "Битовое представление булевых переменных не совпало в {0} бите"
		var vals: Array[int] = [1, 0, 1, 1, 0, 0, 1, 1, 1]
		for i in range(9):
			var got: Variant = genome.get_bit(i)
			var expected: Variant = vals[i]
			assert_eq(got, expected, err_msg.format(i))
		
		genome.set_bit(8, 0)
		err_msg = "Бит изменился некорректно"
		assert_eq(genome.get_bit(8), 0, err_msg)
		
		vals.pop_front()
		err_msg = "{0} бит не должен был меняться"
		for i in range(8):
			var got: Variant = genome.get_bit(i)
			var expected: Variant = vals[i]
			assert_eq(got, expected, err_msg.format(i))
		
		err_msg = "Битовое изменение 9-ой булевой переменной не совпало с реальным значением"
		assert_eq(genome.get_param(8), false, err_msg)

	func test_set_get_bit_single_int():
		var genome := Genome.new([573])
		# 0        1        2        3        4        5        6        7
		# 00000000_00000000_00000000_00000000_00000000_00000000_00000010_00111101
		err_msg = "{0} бит целого числа должен быть 0"
		for i in range(54):
			assert_eq(genome.get_bit(i), 0, err_msg.format(i))
		
		var vals: Array[int] = [1, 0, 0, 0, 1, 1, 1, 1, 0, 1]
		err_msg = "{0} бит целого числа не совпал"
		for i in range(len(vals)):
			assert_eq(genome.get_bit(54 + i), vals[i], err_msg.format(54 + i))
		
		genome.set_bit(32, 1)
		err_msg = "Изменение бита не совпало"
		assert_eq(genome.get_bit(32), 1, err_msg)
		
		err_msg = "Битовое изменение целого числа не совпало с реальным значением"
		assert_eq(genome.get_param(0), 2147484221)

	func test_set_get_bit_single_float():
		var genome := Genome.new([345.893])
		# 0        1        2        3        4        5        6        7
		# 01000000_01110101_10011110_01001001_10111010_01011110_00110101_00111111
		err_msg = "{0} бит вещественного числа не совпал"
		var bit_vals: Array[int] = [
			0, 1, 0, 0, 0, 0, 0, 0,
			0, 1, 1, 1, 0, 1, 0, 1,
			1, 0, 0, 1, 1, 1, 1, 0,
			0, 1, 0, 0, 1, 0, 0, 1,
			1, 0, 1, 1, 1, 0, 1, 0,
			0, 1, 0, 1, 1, 1, 1, 0,
			0, 0, 1, 1, 0, 1, 0, 1,
			0, 0, 1, 1, 1, 1, 1, 1,
		]
		for i in range(len(bit_vals)):
			var got: Variant = genome.get_bit(i)
			var expected: Variant = bit_vals[i]
			assert_eq(got, expected, err_msg.format(i))
		
		genome.set_bit(8, 1)
		err_msg = "Изменение байта не совпало"
		assert_eq(genome.get_bit(8), 1, err_msg)
		
		err_msg = "{0} бит не должен был измениться"
		bit_vals[8] = 1
		for i in range(len(bit_vals)):
			var got: Variant = genome.get_bit(i)
			var expected: Variant = bit_vals[i]
			assert_eq(got, expected, err_msg.format(i))
		
		err_msg = "Битовое изменение вещественного числа не совпало с реальным значением"
		assert_almost_eq(genome.get_param(0), 88548.608, Numeric.EPS)
	
	func test_set_get_byte_mutiple_types():
		var genome := Genome.new([true, 573, 345.893, false])
		# Для целого
		# 0        1        2        3        4        5        6        7
		# 00000000_00000000_00000000_00000000_00000000_00000000_00000010_00111101
		# Для вещественного
		# 0        1        2        3        4        5        6        7
		# 01000000_01110101_10011110_01001001_10111010_01011110_00110101_00111111
		
		genome.set_bit(0 + 32, 1)
		err_msg = "Изменение бита целого числа не совпало"
		assert_eq(genome.get_bit(0 + 32), 1, err_msg)
		err_msg = "Битовое изменение целого числа не совпало с реальным значением"
		assert_eq(genome.get_param(0), 2147484221)
		
		genome.set_bit(64 + 8, 1)
		err_msg = "Изменение бита вещественного числа не совпало"
		assert_eq(genome.get_bit(648 + 8), 1, err_msg)
		err_msg = "Битовое изменение вещественного числа не совпало с реальным значением"
		assert_almost_eq(genome.get_param(1), 88548.608, Numeric.EPS)

		genome.set_bit(64 + 64, 0)
		err_msg = "Изменение бита с булевой переменной не совпало"
		assert_eq(genome.get_bit(64 + 64), 0, err_msg)
		err_msg = "Битовое изменение булевых типов не совпало с реальным значением"
		assert_eq(genome.get_param(2), false, err_msg)
		assert_eq(genome.get_param(3), false, err_msg)
