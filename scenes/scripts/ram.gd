class_name RAM
extends Resource

signal written(address: int)

@export var memory: PackedByteArray
var mutex := Mutex.new()

func read(address: int) -> int:
	mutex.lock()
	var byte: int = memory[address]
	mutex.unlock()
	
	return byte

func write(address: int, value: int) -> int:
	mutex.lock()
	memory[address] = value
	mutex.unlock()
	
	emit_written.call_deferred(address)
	
	return value


func read_16(address: int) -> int:
	mutex.lock()
	var ret: int = (memory[address] << 8) | memory[address + 1]
	mutex.unlock()
	
	return ret

func write_16(address: int, value: int) -> int:
	mutex.lock()
	var first_byte := value >> 8
	var second_byte := value & 0xFF
	memory[address] = first_byte
	memory[address + 1] = second_byte
	mutex.unlock()
	
	emit_written.call_deferred(address)
	emit_written.call_deferred(address + 1)
	
	return value


func emit_written(address: int) -> void:
	written.emit(address)
