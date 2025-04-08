extends Node2D


func _ready() -> void:
	print(TYPE_BOOL)
	print(typeof(false))


func bytes_to_binary(bytes: PackedByteArray) -> String:
	var res := ""
	for byte in bytes:
		for i in range(8):
			res += str(Numeric.get_bit_from_int(byte, i))
		res += " "
	return res
