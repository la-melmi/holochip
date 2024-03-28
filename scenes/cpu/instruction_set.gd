extends RefCounted


var X := ArgumentType.new( 0x0f00, 8, &"X" )
var Y := ArgumentType.new( 0x00f0, 4, &"Y" )
var N := ArgumentType.new( 0x000f, 0, &"N" )
var NN := ArgumentType.new( 0x00ff, 0, &"NN" )
var NNN := ArgumentType.new( 0x0fff, 0, &"NNN" )


var INSTRUCTION_SET = [
	
	#region Simple instructions
	Instruction.new(
		&"CLS", # Clear
		&"00E0",
		0xffff,
		0x00E0,
		[],
		func CLS(cpu: CHIPDecoder):
			for x in cpu.display.width:
				for y in cpu.display.height:
					cpu.display.clear_pixel(x, y)
					),
	
	Instruction.new(
		&"RET", # Return
		&"00EE",
		0xffff,
		0x00EE,
		[],
		func RET(cpu: CHIPDecoder):
			cpu.PC = cpu.stack.pop_back()
			),
	
	Instruction.new(
		&"JP_ADDR", # Jump
		&"1NNN",
		0xf000,
		0x1000,
		[ NNN ],
		func JP_ADDR(cpu: CHIPDecoder, nnn: int):
			cpu.PC = nnn
			),
	
	Instruction.new(
		&"CALL_ADDR", # Call
		&"2NNN",
		0xf000,
		0x2000,
		[ NNN ],
		func CALL_ADDR(cpu: CHIPDecoder, nnn: int):
			cpu.stack.append(cpu.PC)
			cpu.PC = nnn
			),
	
	Instruction.new(
		&"SE_VX_NN", # Skip next if Vx == NN
		&"3XNN",
		0xf000,
		0x3000,
		[ X, NN ],
		func SE_VX_NN(cpu: CHIPDecoder, x: int, nn: int):
			if cpu.V[x] == nn:
				cpu.PC += 2
			),
	
	Instruction.new(
		&"SNE_VX_NN", # Skip next if Vx != NN
		&"4XNN",
		0xf000,
		0x4000,
		[ X, NN ],
		func SNE_VX_NN(cpu: CHIPDecoder, x: int, nn: int):
			if cpu.V[x] != nn:
				cpu.PC += 2
			),
	
	Instruction.new(
		&"SE_VX_VY", # Skip next if Vx == Vy
		&"5XY0",
		0xf00f,
		0x5000,
		[ X, Y ],
		func SE_VX_VY(cpu: CHIPDecoder, x: int, y: int):
			if cpu.V[x] == cpu.V[y]:
				cpu.PC += 2
			),
	
	Instruction.new(
		&"LD_VX_NN", # Vx = NN
		&"6XNN",
		0xf000,
		0x6000,
		[ X, NN ],
		func LD_VX_NN(cpu: CHIPDecoder, x: int, nn: int):
			cpu.V[x] = nn
			),
	
	Instruction.new(
		&"ADD_VX_NN", # Vx += NN
		&"7XNN",
		0xf000,
		0x7000,
		[ X, NN ],
		func ADD_VX_NN(cpu: CHIPDecoder, x: int, nn: int):
			cpu.V[x] += nn
			),
	#endregion
	
	#region Logic and arithmetic
	Instruction.new(
		&"LD_VX_VY", # Vx = Vy
		&"8XY0",
		0xf00f,
		0x8000,
		[ X, Y ],
		func LD_VX_VY(cpu: CHIPDecoder, x: int, y: int):
			cpu.V[x] = cpu.V[y]
			),
	
	Instruction.new(
		&"OR_VX_VY", # Vx |= Vy
		&"8XY1",
		0xf00f,
		0x8001,
		[ X, Y ],
		func OR_VX_VY(cpu: CHIPDecoder, x: int, y: int):
			cpu.V[x] |= cpu.V[y]
			cpu.V[0xF] = 0
			),
	
	Instruction.new(
		&"AND_VX_VY", # Vx &= Vy
		&"8XY2",
		0xf00f,
		0x8002,
		[ X, Y ],
		func AND_VX_VY(cpu: CHIPDecoder, x: int, y: int):
			cpu.V[x] &= cpu.V[y]
			cpu.V[0xF] = 0
			),
	
	Instruction.new(
		&"XOR_VX_VY", # Vx ^= Vy
		&"8XY3",
		0xf00f,
		0x8003,
		[ X, Y ],
		func XOR_VX_VY(cpu: CHIPDecoder, x: int, y: int):
			cpu.V[x] ^= cpu.V[y]
			cpu.V[0xF] = 0
			),
	
	Instruction.new(
		&"ADD_VX_VY", # Vx += Vy
		&"8XY4",
		0xf00f,
		0x8004,
		[ X, Y ],
		func ADD_VX_VY(cpu: CHIPDecoder, x: int, y: int):
			var result: int = cpu.V[x] + cpu.V[y]
			cpu.V[x] = result
			if result > 255:
				cpu.V[0xF] = 1
			else:
				cpu.V[0xF] = 0
			),
	
	Instruction.new(
		&"SUB_VX_VY", # Vx -= Vy
		&"8XY5",
		0xf00f,
		0x8005,
		[ X, Y ],
		func SUB_VX_VY(cpu: CHIPDecoder, x: int, y: int):
			var result: int = cpu.V[x] - cpu.V[y]
			cpu.V[x] = result
			cpu.V[0xF] = int(result >= 0)
			),
	
	Instruction.new(
		&"SHR_VX_VY", # Vx >>= Vy
		&"8XY6",
		0xf00f,
		0x8006,
		[ X, Y ],
		func SHR_VX_VY(cpu: CHIPDecoder, x: int, y: int):
			cpu.V[x] = cpu.V[y]
			var carry: int = cpu.V[x] & 1
			cpu.V[x] >>= 1
			cpu.V[0xF] = carry
			),
	
	Instruction.new(
		&"SUBN_VX_VY", # Vx = Vy - Vx
		&"8XY7",
		0xf00f,
		0x8007,
		[ X, Y ],
		func SUBN_VX_VY(cpu: CHIPDecoder, x: int, y: int):
			var result: int = cpu.V[y] - cpu.V[x]
			cpu.V[x] = result
			cpu.V[0xF] = int(result >= 0)
			),
	
	Instruction.new(
		&"SHL_VX_VY", # Vx <<= Vy
		&"8XYE",
		0xf00f,
		0x800E,
		[ X, Y ],
		func SHL_VX_VY(cpu: CHIPDecoder, x: int, y: int):
			cpu.V[x] = cpu.V[y]
			var carry := (cpu.V[x] & 0x80) >> 7
			cpu.V[x] <<= 1
			cpu.V[0xF] = carry
			),
	#endregion
	
	#region Misc instructions
	Instruction.new(
		&"SNE_VX_VY", # Skip next if Vx != Vy
		&"9XY0",
		0xf00f,
		0x9000,
		[ X, Y ],
		func SNE_VX_VY(cpu: CHIPDecoder, x: int, y: int):
			if cpu.V[x] != cpu.V[y]:
				cpu.PC += 2
				),
	
	Instruction.new(
		&"LD_I_ADDR", # Set I to point to ADDR
		&"ANNN",
		0xf000,
		0xA000,
		[ NNN ],
		func LD_I_ADDR(cpu: CHIPDecoder, nnn: int):
			cpu.I = nnn
			),
	
	Instruction.new(
		&"JP_V0_ADDR", # Jump to ADDR + V0
		&"BNNN",
		0xf000,
		0xB000,
		[ NNN ],
		func JP_V0_ADDR(cpu: CHIPDecoder, nnn: int):
			cpu.PC = nnn + cpu.V[0]
			),
	
	Instruction.new(
		&"RND_VX_NN", # Vx = randi() & NN
		&"CXNN",
		0xf000,
		0xC000,
		[ X, NN ],
		func RND_VX_NN(cpu: CHIPDecoder, x: int, nn: int):
			cpu.V[x] = randi() & nn
			),
	
	Instruction.new(
		&"DRW_VX_VY_N", # Draw N-byte sprite at mem pointer I at (Vx, Vy)
		&"DXYN",
		0xf000,
		0xD000,
		[ X, Y, N ],
		func DRW_VX_VY_N(cpu: CHIPDecoder, x: int, y: int, n: int):
			if cpu.legacy and not cpu.interrupts.poll_interrupt(cpu.interrupts.INTERRUPT_VBLANK):
				cpu.PC -= 2
				return
			
			cpu.V[0xF] = 0
			
			var _x: int = cpu.V[x] % cpu.display.width
			var _y: int = cpu.V[y] % cpu.display.height
			
			for row in n:
				var sprite: int = cpu.ram.read(row + cpu.I)
				
				for col in 8:
					if (sprite & 0x80) > 0:
						if cpu.display.set_pixel(_x + col, _y + row):
							cpu.V[0xF] = 1
					
					if (_x + col + 1) >= cpu.display.width: break
					sprite <<= 1
				
				if (_y + row + 1) >= cpu.display.height: break
			),
	
	Instruction.new(
		&"SKP_VX", # Skip next if key Vx is pressed
		&"EX9E",
		0xf0ff,
		0xe09e,
		[ X ],
		func SKP_VX(cpu: CHIPDecoder, x: int):
			if cpu.keypad.is_key_pressed( cpu.V[x] ):
				cpu.PC += 2
			),
	
	Instruction.new(
		&"SKNP_VX", # Skip next if key Vx is not pressed
		&"EXA1",
		0xf0ff,
		0xe0a1,
		[ X ],
		func SKNP_VX(cpu: CHIPDecoder, x: int):
			if not cpu.keypad.is_key_pressed( cpu.V[x] ):
				cpu.PC += 2
			),
	#endregion
	
	#region 0xF000
	Instruction.new(
		&"LD_VX_DT", # Vx = DT
		&"FX07",
		0xf0ff,
		0xf007,
		[ X ],
		func LD_VX_DT(cpu: CHIPDecoder, x: int):
			cpu.V[x] = cpu.DT
			),
	
	Instruction.new(
		&"LD_VX_K", # Wait for key press, store key in Vx
		&"FX0A",
		0xf0ff,
		0xf00a,
		[ X ],
		func LD_VX_K(cpu: CHIPDecoder, x: int):
			if not cpu.interrupts.poll_interrupt(cpu.interrupts.INTERRUPT_KEY):
				cpu.PC -= 2
				return
			else:
				cpu.V[x] = cpu.interrupts.poll_interrupt(cpu.interrupts.INTERRUPT_KEY)
			),
	
	Instruction.new(
		&"LD_DT_VX", # DT = Vx
		&"FX15",
		0xf0ff,
		0xf015,
		[ X ],
		func LD_DT_VX(cpu: CHIPDecoder, x: int):
			cpu.DT = cpu.V[x]
			),
	
	Instruction.new(
		&"LD_ST_VX", # ST = Vx
		&"FX18",
		0xf0ff,
		0xf018,
		[ X ],
		func LD_ST_VX(cpu: CHIPDecoder, x: int):
			cpu.ST = cpu.V[x]
			),
	
	Instruction.new(
		&"ADD_I_VX", # I += Vx
		&"FX1E",
		0xf0ff,
		0xf01e,
		[ X ],
		func ADD_I_VX(cpu: CHIPDecoder, x: int):
			cpu.I += cpu.V[x]
			if cpu.I >= 0x1000: # This overflow is a weird undefined quirk
				cpu.V[0xF] = 1
			),
	
	Instruction.new(
		&"LD_F_VX", # I = location of font character corresponding to digit in Vx
		&"FX29",
		0xf0ff,
		0xf029,
		[ X ],
		func LD_F_VX(cpu: CHIPDecoder, x: int):
			cpu.I = 0x50 + (cpu.V[x] * 5)
			),
	
	Instruction.new(
		&"LD_B_VX", # Break num in Vx into decimal digits, placed in memory locations I, I+1, I+2
		&"FX33",
		0xf0ff,
		0xf033,
		[ X ],
		func LD_B_VX(cpu: CHIPDecoder, x: int):
			var num := cpu.V[x]
			cpu.ram.write(cpu.I, num / 100)
			cpu.ram.write(cpu.I + 1, (num / 10) % 10)
			cpu.ram.write(cpu.I + 2, num % 10)
			),
	
	Instruction.new(
		&"LD_I_VX", # Store registers V0-Vx in memory starting at pointer I
		&"FX55",
		0xf0ff,
		0xf055,
		[ X ],
		func LD_I_VX(cpu: CHIPDecoder, x: int):
			for i in x + 1:
				if cpu.legacy:
					cpu.ram.write(cpu.I, cpu.V[i])
					cpu.I += 1
				else:
					cpu.ram.write(cpu.I + i, cpu.V[i])
			),
	
	Instruction.new(
		&"LD_VX_I", # Read registers V0-Vx from memory starting at pointer I
		&"FX65",
		0xf0ff,
		0xf065,
		[ X ],
		func LD_VX_I(cpu: CHIPDecoder, x: int):
			for i in x + 1:
				if cpu.legacy:
					cpu.V[i] = cpu.ram.read(cpu.I)
					cpu.I += 1
				else:
					cpu.V[i] = cpu.ram.read(cpu.I + i)
			),
	#endregion
]


func invalid_exec(cpu: CHIPDecoder):
	push_error("Invalid opcode at 0x%X (%d)" % [cpu.PC - 2, cpu.PC - 2])

var INVALID_INSTRUCTION := Instruction.new( &"INVALID", &"", 0, 0, [], invalid_exec )

func filter_instructions(instruction: Instruction, opcode: int) -> bool:
	return (opcode & instruction.mask) == instruction.pattern


func find(opcode: int) -> Instruction:
	var matches := INSTRUCTION_SET.filter(filter_instructions.bind(opcode))
	
	if matches.size() > 1:
		push_error("Too many matches for 0x%X" % opcode)
		for m in matches:
			push_warning("Opcode: %X matched %s (Pattern 0x%x, mask 0x%x)" % [opcode, m.name, m.pattern, m.mask])
		push_warning("Returning first match: %s" % matches[0].name)
		return matches[0]
	
	elif matches.size() == 0:
		push_error("No matches for opcode: 0x%X" % opcode)
		var invalid := INVALID_INSTRUCTION.duplicate()
		invalid.name = "%X" % opcode
		return invalid
	
	else:
		return matches[0]

func disassemble(opcode) -> Opcode:
	var instruction := find(opcode)
	var op := Opcode.new(opcode, instruction)
	
	return op


class Instruction:
	var id: StringName
	var name: StringName
	var mask: int
	var pattern: int
	var arguments: Array[ArgumentType]
	var exec: Callable
	
	func _init(_id: StringName, _name: StringName, _mask: int, _pattern: int, _args: Array[ArgumentType], _exec: Callable) -> void:
		id = _id
		name = _name
		mask = _mask
		pattern = _pattern
		arguments = _args
		exec = _exec
	
	func duplicate() -> Instruction:
		return Instruction.new(id, name, mask, pattern, arguments, exec)

class ArgumentType:
	var mask: int
	var shift: int
	var type: StringName
	
	func _init(_mask: int, _shift: int, _type: StringName) -> void:
		mask = _mask
		shift = _shift
		type = _type

class Opcode:
	var opcode: int
	var id: StringName
	var name: StringName
	var exec: Callable
	var args: Array
	var base: Instruction
	
	func _init(_opcode: int, instruction: Instruction):
		opcode = _opcode
		id = instruction.id
		name = instruction.name
		base = instruction
		args = map_args(opcode, instruction.arguments)
		exec = instruction.exec.bindv( args )
	
	func map_args(_opcode: int, _args: Array) -> Array[int]:
		var result: Array[int] = []
		
		for arg in _args:
			result.append( (_opcode & arg.mask) >> arg.shift )
			
		return result
