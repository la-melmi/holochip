extends Control


@onready var stack_trace: Window = $StackTrace
@onready var memory_inspector: Window = $MemoryInspector
@onready var chip: CHIP8 = $"CHIP-8"

func _process(_delta) -> void:
	chip.control_unit.mutex.lock()
	stack_trace.stack = chip.control_unit.stack
	memory_inspector.PC = chip.control_unit.PC
	chip.control_unit.mutex.unlock()
