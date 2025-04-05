extends GutTest


class TestInitAndGetParam:
	extends GutTest

	func test_one_boolean_init():
		var genome := Genome.new([false])
		assert_eq(genome.get_param(0), false)

		genome = Genome.new([true])
		assert_eq(genome.get_param(0), true)

	func test_several_boolean_init():
		var params: Array[bool] = [true, false, false, true, false, true]
		var genome := Genome.new(params)
		for i in range(len(params)):
			var err_msg := "{0}-ый параметр не совпал".format([i])
			assert_eq(genome.get_param(i), params[i], err_msg)

	func test_one_int_init():
		var params: Array[int] = [Numeric.INT_MIN, -1, 0, 1, Numeric.INT_MAX]
		for i in range(len(params)):
			var genome := Genome.new([params[i]])
			assert_eq(genome.get_param(i), params[i])

	func test_several_int_init():
		var params: Array[int] = [Numeric.INT_MIN, -1, 0, 1, Numeric.INT_MAX]
		var genome := Genome.new(params)
		for i in range(len(params)):
			var err_msg := "{0}-ый параметр не совпал".format([i])
			assert_eq(genome.get_param(i), params[i], err_msg)

	func test_one_float_init():
		var params: Array[float] = [Numeric.FLOAT_MIN, -1., 0., 1., Numeric.FLOAT_MAX]
		for i in range(len(params)):
			var genome := Genome.new([params[i]])
			assert_almost_eq(genome.get_param(i), params[i], Numeric.EPS)

	func test_several_float_init():
		var params: Array[float] = [Numeric.FLOAT_MIN, -1., 0., 1., Numeric.FLOAT_MAX]
		var genome := Genome.new(params)
		for i in range(len(params)):
			var err_msg := "{0}-ый параметр не совпал".format([i])
			assert_almost_eq(genome.get_param(i), params[i], Numeric.EPS, err_msg)

	func test_mixed_init():
		var params: Array = [3.14, false, 5, -3.5, true, -42]
		var genome := Genome.new(params)
		for i in range(len(params)):
			var got: Variant = genome.get_param(i)
			var expected: Variant = params[i]
			var err_msg := "{0}-ый параметр не совпал".format([i])
			if typeof(got) == TYPE_FLOAT:
				assert_almost_eq(got, expected, Numeric.EPS, err_msg)


class TestSetGetParam:
	extends GutTest

	var genome: Genome

	func before_each():
		genome = Genome.new([true, 3.14, 10, false, -9.5, -5])

	func test_setget_bool():
		assert_eq(genome.get_param(0), true)
		genome.set_param(0, false)
		assert_eq(genome.get_param(0), false)
		assert_eq(genome.get_param(3), false)

	func test_setget_int():
		assert_eq(genome.get_param(2), 10)
		genome.set_param(2, -42)
		assert_eq(genome.get_param(2), -42)
		assert_eq(genome.get_param(5), -5)

	func test_setget_float():
		assert_almost_eq(genome.get_param(1), 3.14, Numeric.EPS)
		genome.set_param(1, 12.32)
		assert_almost_eq(genome.get_param(1), 12.32, Numeric.EPS)
		assert_almost_eq(genome.get_param(4), -9.5, Numeric.EPS)


class TestSetGetByte:
	extends GutTest

	var genome: Genome

	func before_each():
		genome = Genome.new([true, 3.14, 10])

	func test_setget_bool():
		assert_eq(genome.get_byte(0), 1)
		genome.set_byte(0, 0)
		assert_eq(genome.get_byte(0), 0)
		assert_eq(genome.get_byte(3), 0)

	func test_setget_int():
		assert_eq(genome.get_byte(15), 0)
		genome.set_byte(15, 4)
		assert_eq(genome.get_byte(15), 4)
		assert_eq(genome.get_byte(16), 10)
		assert_eq(genome.get_param(2), 1034)

	func test_setget_float():
		assert_eq(genome.get_byte(1), 64)
		genome.set_byte(1, 192)
		assert_eq(genome.get_byte(1), 192)
		assert_eq(genome.get_byte(8), 31)
		assert_almost_eq(genome.get_param(1), -3.14, Numeric.EPS)


class TestSetGetBit:
	extends GutTest

	var genome: Genome

	func before_each():
		genome = Genome.new([true, 3.14, 10])

	func test_setget_bool():
		assert_eq(genome.get_bit(0), 1)
		genome.set_bit(0, 0)
		assert_eq(genome.get_bit(0), 0)

	func test_setget_int():
		assert_eq(genome.get_bit(65), 0)
		genome.set_bit(65, 1)
		assert_eq(genome.get_bit(65), 1)
		assert_eq(genome.get_param(2), 9223372036854775818)

	func test_setget_float():
		assert_eq(genome.get_bit(1), 0)
		genome.set_bit(1, 1)
		assert_eq(genome.get_bit(1), 0)
		assert_almost_eq(genome.get_param(1), -3.14, Numeric.EPS)
