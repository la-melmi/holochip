extends Object

const INSTRUCTION_SET := [
	{
		id = &"CLS", # Clear
		name = &"00E0",
		mask = 0xffff,
		pattern = 0x00E0,
		arguments = [],
	},
	{
		id = &"RET", # Return
		name = &"00EE",
		mask = 0xffff,
		pattern = 0x00EE,
		arguments = [],
	},
	{
		id = &"JP_ADDR", # Jump
		name = &"1NNN",
		mask = 0xf000,
		pattern = 0x1000,
		arguments = [
			{ mask = 0x0fff, shift = 0, type = &"NNN" }
		],
	},
	{
		id = &"CALL_ADDR", # Call
		name = &"2NNN",
		mask = 0xf000,
		pattern = 0x2000,
		arguments = [
			{ mask = 0x0fff, shift = 0, type = &"NNN" }
		],
	},
	{
		id = &"SE_VX_NN", # Skip next if Vx == NN
		name = &"3XNN",
		mask = 0xf000,
		pattern = 0x3000,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" },
			{ mask = 0x00ff, shift = 0, type = &"NN" }
		],
	},
	{
		id = &"SNE_VX_NN", # Skip next if Vx != NN
		name = &"4XNN",
		mask = 0xf000,
		pattern = 0x4000,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" },
			{ mask = 0x00ff, shift = 0, type = &"NN" }
		],
	},
	{
		id = &"SE_VX_VY", # Skip next if Vx == Vy
		name = &"5XY0",
		mask = 0xf00f,
		pattern = 0x5000,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" },
			{ mask = 0x00f0, shift = 4, type = &"Y" }
		],
	},
	{
		id = &"LD_VX_NN", # Vx = NN
		name = &"6XNN",
		mask = 0xf000,
		pattern = 0x6000,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" },
			{ mask = 0x00ff, shift = 0, type = &"NN" }
		],
	},
	{
		id = &"ADD_VX_NN", # Vx += NN
		name = &"7XNN",
		mask = 0xf000,
		pattern = 0x7000,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" },
			{ mask = 0x00ff, shift = 0, type = &"NN" }
		],
	},
	{
		id = &"LD_VX_VY", # Vx = Vy
		name = &"8XY0",
		mask = 0xf00f,
		pattern = 0x8000,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" },
			{ mask = 0x00f0, shift = 4, type = &"Y" }
		],
	},
	{
		id = &"OR_VX_VY", # Vx |= Vy
		name = &"8XY1",
		mask = 0xf00f,
		pattern = 0x8001,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" },
			{ mask = 0x00f0, shift = 4, type = &"Y" }
		],
	},
	{
		id = &"AND_VX_VY", # Vx &= Vy
		name = &"8XY2",
		mask = 0xf00f,
		pattern = 0x8002,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" },
			{ mask = 0x00f0, shift = 4, type = &"Y" }
		],
	},
	{
		id = &"XOR_VX_VY", # Vx ^= Vy
		name = &"8XY3",
		mask = 0xf00f,
		pattern = 0x8003,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" },
			{ mask = 0x00f0, shift = 4, type = &"Y" }
		],
	},
	{
		id = &"ADD_VX_VY", # Vx += Vy
		name = &"8XY4",
		mask = 0xf00f,
		pattern = 0x8004,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" },
			{ mask = 0x00f0, shift = 4, type = &"Y" }
		],
	},
	{
		id = &"SUB_VX_VY", # Vx -= Vy
		name = &"8XY5",
		mask = 0xf00f,
		pattern = 0x8005,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" },
			{ mask = 0x00f0, shift = 4, type = &"Y" }
		],
	},
	{
		id = &"SHR_VX_VY", # Vx >>= Vy
		name = &"8XY6",
		mask = 0xf00f,
		pattern = 0x8006,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" },
			{ mask = 0x00f0, shift = 4, type = &"Y" }
		],
	},
	{
		id = &"SUBN_VX_VY", # Vx = Vy - Vx
		name = &"8XY7",
		mask = 0xf00f,
		pattern = 0x8007,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" },
			{ mask = 0x00f0, shift = 4, type = &"Y" }
		],
	},
	{
		id = &"SHL_VX_VY", # Vx <<= Vy
		name = &"8XYE",
		mask = 0xf00f,
		pattern = 0x800E,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" },
			{ mask = 0x00f0, shift = 4, type = &"Y" }
		],
	},
	{
		id = &"SNE_VX_VY", # Skip next if Vx != Vy
		name = &"9XY0",
		mask = 0xf00f,
		pattern = 0x9000,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" },
			{ mask = 0x00f0, shift = 4, type = &"Y" }
		],
	},
	{
		id = &"LD_I_ADDR", # Set I to point to ADDR
		name = &"ANNN",
		mask = 0xf000,
		pattern = 0xA000,
		arguments = [
			{ mask = 0x0fff, shift = 0, type = &"NNN" }
		],
	},
	{
		id = &"JP_V0_ADDR", # Jump to ADDR + V0
		name = &"BNNN",
		mask = 0xf000,
		pattern = 0xB000,
		arguments = [
			{ mask = 0x0fff, shift = 0, type = &"NNN" }
		],
	},
	{
		id = &"RND_VX_NN", # Vx = randi() & NN
		name = &"CXNN",
		mask = 0xf000,
		pattern = 0xC000,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" },
			{ mask = 0x00ff, shift = 0, type = &"NN" }
		],
	},
	{
		id = &"DRW_VX_VY_N", # Draw N-byte sprite at mem pointer I at (Vx, Vy)
		name = &"DXYN",
		mask = 0xf000,
		pattern = 0xD000,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" },
			{ mask = 0x00f0, shift = 4, type = &"Y" },
			{ mask = 0x000f, shift = 0, type = &"N" }
		],
	},
	{
		id = &"SKP_VX", # Skip next if key Vx is pressed
		name = &"EX9E",
		mask = 0xf0ff,
		pattern = 0xe09e,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" }
		],
	},
	{
		id = &"SKNP_VX", # Skip next if key Vx is not pressed
		name = &"EXA1",
		mask = 0xf0ff,
		pattern = 0xe0a1,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" }
		],
	},
	
	## 0xF000
	{
		id = &"LD_VX_DT", # Vx = DT
		name = &"FX07",
		mask = 0xf0ff,
		pattern = 0xf007,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" }
		],
	},
	{
		id = &"LD_VX_K", # Wait for key press, store key in Vx
		name = &"FX0A",
		mask = 0xf0ff,
		pattern = 0xf00a,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" }
		],
	},
	{
		id = &"LD_DT_VX", # DT = Vx
		name = &"FX15",
		mask = 0xf0ff,
		pattern = 0xf015,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" }
		],
	},
	{
		id = &"LD_VX_ST", # Vx = ST
		name = &"FX18",
		mask = 0xf0ff,
		pattern = 0xf018,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" }
		],
	},
	{
		id = &"ADD_I_VX", # I += Vx
		name = &"FX1E",
		mask = 0xf0ff,
		pattern = 0xf01e,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" }
		],
	},
	{
		id = &"LD_F_Vx", # I = location of font character corresponding to digit in Vx
		name = &"FX29",
		mask = 0xf0ff,
		pattern = 0xf029,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" }
		],
	},
	{
		id = &"LD_B_VX", # Break num in Vx into decimal digits, placed in memory locations I, I+1, I+2
		name = &"FX33",
		mask = 0xf0ff,
		pattern = 0xf033,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" }
		],
	},
	{
		id = &"LD_I_VX", # Store registers V0-Vx in memory starting at pointer I
		name = &"FX55",
		mask = 0xf0ff,
		pattern = 0xf055,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" }
		],
	},
	{
		id = &"LD_VX_I", # Read registers V0-Vx from memory starting at pointer I
		name = &"FX65",
		mask = 0xf0ff,
		pattern = 0xf065,
		arguments = [
			{ mask = 0x0f00, shift = 8, type = &"X" }
		],
	},
]


func filter_instructions(instruction: Dictionary, opcode: int) -> bool:
	return (opcode & instruction.mask) == instruction.pattern

func map_args(opcode: int, args: Array) -> Dictionary:
	var result := {}
	
	for arg in args:
		result[arg.type] = (opcode & arg.mask) >> arg.shift
		
	return result


func find(opcode: int) -> Dictionary:
	var matches := INSTRUCTION_SET.filter(filter_instructions.bind(opcode))
	
	if matches.size() > 1:
		push_error("Too many matches for 0x%X" % opcode)
		for m in matches:
			push_error("Opcode: %X matched %s (Pattern 0x%x, mask 0x%x)" % [opcode, m.name, m.pattern, m.mask])
		push_error("Returning first match: %s" % matches[0].name)
		return matches[0]
	
	elif matches.size() == 0:
		push_error("No matches for opcode: 0x%X" % opcode)
		return {id = &"INVALID", name = "%X" % opcode, arguments = []}
	
	else:
		return matches[0]

func disassemble(opcode) -> Array:
	var instruction := find(opcode)
	var args := map_args(opcode, instruction.arguments)
	
	return [instruction.name, args]
