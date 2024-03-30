extends Control


signal chip_ready

@export_file("*.ch8", "*.sc8", "*.bin") var rom: String
@export var chip_scene: PackedScene

@onready var stack_viewer: Window = $StackViewer
@onready var memory_inspector: Window = $MemoryInspector
@onready var register_inspector: Window = $RegisterInspector

@onready var main_container: VBoxContainer = $VBoxContainer
@onready var menu_bar: MenuBar = $VBoxContainer/EmulatorMenu

var chip: CHIP8

func _ready() -> void:
	init_chip()

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

func init_chip() -> void:
	if chip:
		chip.clock.stop()
		main_container.remove_child(chip)
		chip.queue_free()
	
	chip = chip_scene.instantiate()
	chip.rom = rom
	menu_bar.chip = chip
	chip.size_flags_vertical = SIZE_EXPAND_FILL
	
	main_container.add_child(chip)
	chip_ready.emit()
