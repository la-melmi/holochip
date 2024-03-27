extends Object


var X := ArgumentType.new( 0x0f00, 8, &"X" )
var Y := ArgumentType.new( 0x00f0, 4, &"Y" )
var N := ArgumentType.new( 0x000f, 0, &"N" )
var NN := ArgumentType.new( 0x00ff, 0, &"NN" )
var NNN := ArgumentType.new( 0x0fff, 0, &"NNN" )


var INSTRUCTION_SET = [
	Instruction.new(
		&"CLS", # Clear
		&"00E0",
		0xffff,
		0x00E0,
		[]
	),
	Instruction.new(
		&"RET", # Return
		&"00EE",
		0xffff,
		0x00EE,
		[],
	),
	Instruction.new(
		&"JP_ADDR", # Jump
		&"1NNN",
		0xf000,
		0x1000,
		[
			NNN
		],
	),
	Instruction.new(
		&"CALL_ADDR", # Call
		&"2NNN",
		0xf000,
		0x2000,
		[
			NNN
		],
	),
	Instruction.new(
		&"SE_VX_NN", # Skip next if Vx == NN
		&"3XNN",
		0xf000,
		0x3000,
		[
			X,
			NN
		],
	),
	Instruction.new(
		&"SNE_VX_NN", # Skip next if Vx != NN
		&"4XNN",
		0xf000,
		0x4000,
		[
			X,
			NN
		],
	),
	Instruction.new(
		&"SE_VX_VY", # Skip next if Vx == Vy
		&"5XY0",
		0xf00f,
		0x5000,
		[
			X,
			Y
		],
	),
	Instruction.new(
		&"LD_VX_NN", # Vx = NN
		&"6XNN",
		0xf000,
		0x6000,
		[
			X,
			NN
		],
	),
	Instruction.new(
		&"ADD_VX_NN", # Vx += NN
		&"7XNN",
		0xf000,
		0x7000,
		[
			X,
			NN
		],
	),
	Instruction.new(
		&"LD_VX_VY", # Vx = Vy
		&"8XY0",
		0xf00f,
		0x8000,
		[
			X,
			Y
		],
	),
	Instruction.new(
		&"OR_VX_VY", # Vx |= Vy
		&"8XY1",
		0xf00f,
		0x8001,
		[
			X,
			Y
		],
	),
	Instruction.new(
		&"AND_VX_VY", # Vx &= Vy
		&"8XY2",
		0xf00f,
		0x8002,
		[
			X,
			Y
		],
	),
	Instruction.new(
		&"XOR_VX_VY", # Vx ^= Vy
		&"8XY3",
		0xf00f,
		0x8003,
		[
			X,
			Y
		],
	),
	Instruction.new(
		&"ADD_VX_VY", # Vx += Vy
		&"8XY4",
		0xf00f,
		0x8004,
		[
			X,
			Y
		],
	),
	Instruction.new(
		&"SUB_VX_VY", # Vx -= Vy
		&"8XY5",
		0xf00f,
		0x8005,
		[
			X,
			Y
		],
	),
	Instruction.new(
		&"SHR_VX_VY", # Vx >>= Vy
		&"8XY6",
		0xf00f,
		0x8006,
		[
			X,
			Y
		],
	),
	Instruction.new(
		&"SUBN_VX_VY", # Vx = Vy - Vx
		&"8XY7",
		0xf00f,
		0x8007,
		[
			X,
			Y
		],
	),
	Instruction.new(
		&"SHL_VX_VY", # Vx <<= Vy
		&"8XYE",
		0xf00f,
		0x800E,
		[
			X,
			Y
		],
	),
	Instruction.new(
		&"SNE_VX_VY", # Skip next if Vx != Vy
		&"9XY0",
		0xf00f,
		0x9000,
		[
			X,
			Y
		],
	),
	Instruction.new(
		&"LD_I_ADDR", # Set I to point to ADDR
		&"ANNN",
		0xf000,
		0xA000,
		[
			NNN
		],
	),
	Instruction.new(
		&"JP_V0_ADDR", # Jump to ADDR + V0
		&"BNNN",
		0xf000,
		0xB000,
		[
			NNN
		],
	),
	Instruction.new(
		&"RND_VX_NN", # Vx = randi() & NN
		&"CXNN",
		0xf000,
		0xC000,
		[
			X,
			NN
		],
	),
	Instruction.new(
		&"DRW_VX_VY_N", # Draw N-byte sprite at mem pointer I at (Vx, Vy)
		&"DXYN",
		0xf000,
		0xD000,
		[
			X,
			Y,
			N
		],
	),
	Instruction.new(
		&"SKP_VX", # Skip next if key Vx is pressed
		&"EX9E",
		0xf0ff,
		0xe09e,
		[
			X
		],
	),
	Instruction.new(
		&"SKNP_VX", # Skip next if key Vx is not pressed
		&"EXA1",
		0xf0ff,
		0xe0a1,
		[
			X
		],
	),
	
	## 0xF000
	Instruction.new(
		&"LD_VX_DT", # Vx = DT
		&"FX07",
		0xf0ff,
		0xf007,
		[
			X
		],
	),
	Instruction.new(
		&"LD_VX_K", # Wait for key press, store key in Vx
		&"FX0A",
		0xf0ff,
		0xf00a,
		[
			X
		],
	),
	Instruction.new(
		&"LD_DT_VX", # DT = Vx
		&"FX15",
		0xf0ff,
		0xf015,
		[
			X
		],
	),
	Instruction.new(
		&"LD_VX_ST", # Vx = ST
		&"FX18",
		0xf0ff,
		0xf018,
		[
			X
		],
	),
	Instruction.new(
		&"ADD_I_VX", # I += Vx
		&"FX1E",
		0xf0ff,
		0xf01e,
		[
			X
		],
	),
	Instruction.new(
		&"LD_F_Vx", # I = location of font character corresponding to digit in Vx
		&"FX29",
		0xf0ff,
		0xf029,
		[
			X
		],
	),
	Instruction.new(
		&"LD_B_VX", # Break num in Vx into decimal digits, placed in memory locations I, I+1, I+2
		&"FX33",
		0xf0ff,
		0xf033,
		[
			X
		],
	),
	Instruction.new(
		&"LD_I_VX", # Store registers V0-Vx in memory starting at pointer I
		&"FX55",
		0xf0ff,
		0xf055,
		[
			X
		],
	),
	Instruction.new(
		&"LD_VX_I", # Read registers V0-Vx from memory starting at pointer I
		&"FX65",
		0xf0ff,
		0xf065,
		[
			X
		],
	),
]

var INVALID_INSTRUCTION := Instruction.new( &"INVALID", "", 0, 0, [] )

func filter_instructions(instruction: Instruction, opcode: int) -> bool:
	return (opcode & instruction.mask) == instruction.pattern

func map_args(opcode: int, args: Array) -> Arguments:
	var result := Arguments.new()
	
	for arg in args:
		result[arg.type] = (opcode & arg.mask) >> arg.shift
		
	return result


func find(opcode: int) -> Instruction:
	var matches := INSTRUCTION_SET.filter(filter_instructions.bind(opcode))
	
	if matches.size() > 1:
		push_error("Too many matches for 0x%X" % opcode)
		for m in matches:
			push_error("Opcode: %X matched %s (Pattern 0x%x, mask 0x%x)" % [opcode, m.name, m.pattern, m.mask])
		push_error("Returning first match: %s" % matches[0].name)
		return matches[0]
	
	elif matches.size() == 0:
		push_error("No matches for opcode: 0x%X" % opcode)
		var invalid := INVALID_INSTRUCTION.duplicate()
		invalid.name = "%X" % opcode
		return invalid
	
	else:
		return matches[0]

func disassemble(opcode) -> Array:
	var instruction := find(opcode)
	var args := map_args(opcode, instruction.arguments)
	
	return [instruction.name, args]


class Instruction:
	var id: StringName
	var name: StringName
	var mask: int
	var pattern: int
	var arguments: Array[ArgumentType]
	
	func _init(_id: StringName, _name: StringName, _mask: int, _pattern: int, _args: Array[ArgumentType]) -> void:
		id = _id
		name = _name
		mask = _mask
		pattern = _pattern
		arguments = _args
	
	func duplicate() -> Instruction:
		return Instruction.new(id, name, mask, pattern, arguments)

class ArgumentType:
	var mask: int
	var shift: int
	var type: StringName
	
	func _init(_mask: int, _shift: int, _type: StringName) -> void:
		mask = _mask
		shift = _shift
		type = _type

class Arguments:
	var X: int
	var Y: int
	var N: int
	var NN: int
	var NNN: int
