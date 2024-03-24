class_name RAM
extends Resource

@export var memory: PackedByteArray

func read(address: int) -> int:
	return memory[address]

func write(address: int, value: int) -> int:
	memory[address] = value
	return value
