class_name InstructionDisplay
extends HBoxContainer


signal address_clicked(address: int)

const INVALID := &"INVALID"

var active: bool:
	set(state):
		active = state
		$Pointer.modulate.a = float(active)
		$PanelContainer.self_modulate.a = float(active)

var addr: int
var isa: RefCounted
var ram: RAM
var cache: Dictionary

var octo_mode: bool
var instruction: RefCounted

func _ready() -> void:
	active = active
	$PanelContainer/HBoxContainer/Address.address = addr


func update_code() -> void:
	if not ram: return
	var opcode := ram.read_16(addr)
	
	if opcode in cache:
		instruction = cache[opcode]
	else:
		instruction = isa.disassemble(opcode, false)
		cache[opcode] = instruction
	
	$PanelContainer/HBoxContainer/HBoxContainer/BoxContainer/Opcode.text = HexTools.to_hex(instruction.opcode, 4)
	update_asm(octo_mode)

func update_asm(octo: bool):
	octo_mode = octo
	
	var asm: String = instruction.octo if octo_mode else instruction.asm
	
	$PanelContainer/HBoxContainer/HBoxContainer/BoxContainer2/Instruction.text = asm


func _on_address_clicked(address: int) -> void:
	address_clicked.emit(address)
