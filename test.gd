extends Node2D


func _ready() -> void:
	var bytes: PackedByteArray = var_to_bytes(true)
	bytes.set(4, 16)
	print(bytes_to_binary(bytes))
	print(bytes.decode_var(0))

	bytes = var_to_bytes(false)
	print(bytes_to_binary(bytes))


func bytes_to_binary(bytes: PackedByteArray) -> String:
	var res := ""
	for byte in bytes:
		for i in range(7, -1, -1):
			var bit: int = (byte >> i) & 1
			res += "0" if bit == 0 else "1"
		res += " "
	return res
