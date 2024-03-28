class_name CHIPDecoder
extends Node


@export var debug: bool
@export var legacy: bool = true
@export var instruction_set: Script

@export_group("Connected Nodes")
@export var display: CHIPDisplay
@export var clock: Clock
@export var keypad: CHIPKeypad
@export var interrupts: InterruptController
@export var quirks: QuirkHandler

@export_group("Resources")
@export var ram: RAM

@onready var _isa = instruction_set.new()

var stack: Array[int]
var mutex := Mutex.new()

#region Register definitions
var V := PackedByteArray()

var I: int:
	set(value): I = value % 65536

var PC: int = 0x200:
	set(value): PC = value % 65536

var SP: int:
	set(value): SP = value % 256

var DT: int:
	set(value): DT = value % 256

var ST: int:
	set(value): ST = value % 256
#endregion

func _ready() -> void:
	assert(_isa.get("INSTRUCTION_SET"), "Invalid instruction set provided.")
	
	V.resize(16)
	
	clock.callbacks.append(step)
	clock.timer_callbacks.append(timer_tick)


func timer_tick() -> void:
	mutex.lock()
	DT = max(DT - 1, 0)
	ST = max(ST - 1, 0)
	mutex.unlock()


var instruction_cache: Dictionary

func step() -> void:
	var opcode: int = fetch()
	PC += 2
	
	var instruction: Object
	if opcode in instruction_cache:
		instruction = instruction_cache[opcode]
	else:
		instruction = decode(opcode)
		instruction_cache[opcode] = instruction
	
	execute(instruction)

func fetch() -> int:
	return ram.read_16(PC)

func decode(opcode: int) -> Object:
	return _isa.disassemble(opcode)

func execute(_instruction: Object) -> void:
	if interrupts.poll_interrupt(interrupts.INTERRUPT_DEBUG):
		pass
	
	if debug: debug_print(_instruction)
	
	_instruction.exec.call(self)
	return


func debug_print(_instruction: Object) -> void:
	var string: String = "Executing %s(" % _instruction.id
	
	var parts: PackedStringArray = []
	for i in _instruction.args.size():
		parts.append("%s = %d" % [
			_instruction.base.arguments[i].type.to_lower(),
			_instruction.args[i],
			])
	
	string += ", ".join(parts)
	
	string += ") (%X)" % _instruction.opcode
	
	print(string)


var flag_register_path := "user://flag_registers.tres"

func get_flag_registers() -> FlagRegisters:
	if ResourceLoader.exists(flag_register_path):
		return load(flag_register_path)
	return FlagRegisters.new()

func read_flag(index: int) -> int:
	mutex.lock()
	var flags := get_flag_registers()
	var value := flags.registers[index]
	mutex.unlock()
	return value

func write_flag(index: int, value: int) -> void:
	mutex.lock()
	var flags := get_flag_registers()
	flags.registers[index] = value
	ResourceSaver.save(flags, flag_register_path)
	mutex.unlock()


# Cannot be called in thread
func exit() -> void:
	get_tree().quit()
