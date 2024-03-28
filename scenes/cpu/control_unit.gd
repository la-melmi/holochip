class_name CHIPDecoder
extends Node


@export var legacy: bool = true
@export var instruction_set: Script
@export var display: CHIPDisplay
@export var clock: Clock
@export var keypad: CHIPKeypad
@export var interrupts: InterruptController

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


var instruction: Object

func step() -> void:
	var opcode: int = fetch()
	PC += 2
	
	if (not instruction) or (opcode != instruction.opcode):
		instruction = decode(opcode)
	
	execute(instruction)

func fetch() -> int:
	return ram.read_16(PC)

func decode(opcode: int) -> Object:
	return _isa.disassemble(opcode)

func execute(_instruction: Object) -> void:
	if interrupts.poll_interrupt(interrupts.INTERRUPT_DEBUG):
		pass
	
	_instruction.exec.call(self)
