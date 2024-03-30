class_name CHIP8
extends Node


@export_group("Imports")
@export_file("*.ch8", "*.sc8", "*.bin") var rom: String
@export_file("*.bin") var font: String

@export_group("Connected Nodes")
@export var ram: RAM
@export var clock: Clock
@export var display: CHIPDisplay
@export var control_unit: CHIPDecoder
@onready var quirks: QuirkHandler = $Quirks

var started: bool = false

var default_font := PackedByteArray([
	0xF0, 0x90, 0x90, 0x90, 0xF0, # 0
	0x20, 0x60, 0x20, 0x20, 0x70, # 1
	0xF0, 0x10, 0xF0, 0x80, 0xF0, # 2
	0xF0, 0x10, 0xF0, 0x10, 0xF0, # 3
	0x90, 0x90, 0xF0, 0x10, 0x10, # 4
	0xF0, 0x80, 0xF0, 0x10, 0xF0, # 5
	0xF0, 0x80, 0xF0, 0x90, 0xF0, # 6
	0xF0, 0x10, 0x20, 0x40, 0x40, # 7
	0xF0, 0x90, 0xF0, 0x90, 0xF0, # 8
	0xF0, 0x90, 0xF0, 0x10, 0xF0, # 9
	0xF0, 0x90, 0xF0, 0x90, 0x90, # A
	0xE0, 0x90, 0xE0, 0x90, 0xE0, # B
	0xF0, 0x80, 0x80, 0x80, 0xF0, # C
	0xE0, 0x90, 0x90, 0x90, 0xE0, # D
	0xF0, 0x80, 0xF0, 0x80, 0xF0, # E
	0xF0, 0x80, 0xF0, 0x80, 0x80  # F
])


func _ready() -> void:
	start()


func import_bin(pointer: int, path: String) -> int:
	var file := FileAccess.open(path, FileAccess.READ)
	
	while file.get_position() < file.get_length():
		ram.write(pointer, file.get_8())
		pointer += 1
	
	return pointer


func start() -> void:
	if started: reset()
	
	if font:
		import_bin(0, font)
	else:
		var pointer := 0
		for byte in default_font:
			ram.write(pointer, byte)
			pointer += 1
	
	if rom:
		import_bin(0x200, rom)
	
	clock.start()
	started = true


func reset() -> void:
	clock.stop()
	
	ram.memory.fill(0)
	control_unit.V.fill(0)
	control_unit.I = 0
	control_unit.PC = 0x200
	control_unit.SP = 0
	control_unit.DT = 0
	control_unit.ST = 0
