extends Control


signal chip_ready(new_chip: CHIP8)

@export_file("*.ch8", "*.sc8", "*.bin") var rom: String
@export var chip_scene: PackedScene

@onready var stack_viewer: Window = $StackViewer
@onready var memory_inspector: Window = $MemoryInspector
@onready var register_inspector: Window = $RegisterInspector
@onready var disassembler: Window = $Disassembler

@onready var main_container: VBoxContainer = $VBoxContainer
@onready var menu_bar: MenuBar = $VBoxContainer/EmulatorMenu

var chip: CHIP8

func _ready() -> void:
	init_chip()

func _process(_delta) -> void:
	get_window().title = "HOLO-CHIP 2D (%d FPS)" % Engine.get_frames_per_second()
	chip.control_unit.mutex.lock()
	stack_viewer.stack = chip.control_unit.stack.duplicate()
	memory_inspector.PC = chip.control_unit.PC
	disassembler.PC = chip.control_unit.PC
	register_inspector.V = chip.control_unit.V.duplicate()
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
	chip.size_flags_vertical = SIZE_EXPAND_FILL
	
	main_container.add_child(chip)
	chip_ready.emit(chip)

func _on_rom_selected(path: String) -> void:
	rom = path
	init_chip()
