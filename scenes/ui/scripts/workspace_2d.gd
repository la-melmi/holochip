extends Control


@onready var stack_viewer: Window = $StackViewer
@onready var memory_inspector: Window = $MemoryInspector
@onready var register_inspector: Window = $RegisterInspector
@onready var chip: CHIP8 = $"VBoxContainer/CHIP-8"

func _process(_delta) -> void:
	chip.control_unit.mutex.lock()
	stack_viewer.stack = chip.control_unit.stack
	memory_inspector.PC = chip.control_unit.PC
	register_inspector.V = chip.control_unit.V
	register_inspector.I = chip.control_unit.I
	register_inspector.PC = chip.control_unit.PC
	register_inspector.DT = chip.control_unit.DT
	register_inspector.ST = chip.control_unit.ST
	register_inspector.update_registers()
	chip.control_unit.mutex.unlock()
