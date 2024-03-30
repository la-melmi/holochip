extends Control


@onready var stack_viewer: Window = $StackViewer
@onready var memory_inspector: Window = $MemoryInspector
@onready var chip: CHIP8 = $"VBoxContainer/CHIP-8"

func _process(_delta) -> void:
	chip.control_unit.mutex.lock()
	stack_viewer.stack = chip.control_unit.stack
	memory_inspector.PC = chip.control_unit.PC
	chip.control_unit.mutex.unlock()
