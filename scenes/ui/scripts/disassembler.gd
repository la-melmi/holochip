class_name Disassembler
extends Window


@export var instruction_scene: PackedScene
@export var ram: RAM

@onready var container: BoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer
@onready var octo_mode: CheckButton = $VBoxContainer/OctoMode
@onready var scroll: ScrollContainer = $VBoxContainer/ScrollContainer

var chip: CHIP8
var snap_pc: bool
var refreshed: bool

var PC: int:
	set(value):
		update_PC(PC, value)
		PC = value

func _ready() -> void:
	ram.written.connect(_on_ram_written)
	
	generate_instructions()

func _process(_delta) -> void:
	if snap_pc:
		@warning_ignore("integer_division")
		scroll.ensure_control_visible(container.get_child(PC / 2))

func _on_chip_ready(new_chip: CHIP8) -> void:
	chip = new_chip
	
	if visible:
		refresh_instructions()

func generate_instructions() -> void:
	refreshed = false
	for i in ram.memory.size() / 2.0:
		var addr := i * 2
		
		var instruction := instruction_scene.instantiate()
		instruction.addr = addr
		octo_mode.toggled.connect(instruction.update_asm)
		container.add_child(instruction)

func refresh_instructions() -> void:
	refreshed = true
	for i in ram.memory.size() / 2.0:
		var instruction := container.get_child(int(i))
		instruction.ram = ram
		instruction.isa = chip.control_unit._isa
		instruction.cache = chip.control_unit.instruction_cache
		instruction.update_code()

func _on_ram_written(address: int) -> void:
	@warning_ignore("integer_division")
	container.get_child( address / 2 ).update_code()


func update_PC(old: int, new: int) -> void:
	@warning_ignore("integer_division")
	container.get_child(old / 2).active = false
	@warning_ignore("integer_division")
	container.get_child(new / 2).active = true


func _on_snap_pc_toggled(toggled_on: bool):
	snap_pc = toggled_on

func toggle() -> void:
	visible = not visible


func _on_visibility_changed():
	if visible and not refreshed:
		refresh_instructions()


func _on_address_entered(address: int):
	if address < ram.memory.size() and address >= 0:
		@warning_ignore("integer_division")
		scroll.ensure_control_visible( container.get_child( address / 2 ) )
