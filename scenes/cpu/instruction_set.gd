extends RefCounted


var X := ArgumentType.new( 0x0f00, 8, &"X" )
var Y := ArgumentType.new( 0x00f0, 4, &"Y" )
var N := ArgumentType.new( 0x000f, 0, &"N" )
var NN := ArgumentType.new( 0x00ff, 0, &"NN" )
var NNN := ArgumentType.new( 0x0fff, 0, &"NNN" )


var INSTRUCTION_SET = [
	
	#region Simple instructions
	Instruction.new(
		&"HALT", # Halt execution, but don't exit.
		&"0000",
		"0x0000",
		"0x0000",
		0xffff,
		0x0000,
		[],
		func HALT(cpu: CHIPDecoder):
			cpu.clock.running = false
			cpu.clock.stop.call_deferred()
			),
	
	Instruction.new(
		&"SCROLL_DOWN_N", # Scroll down by 0-15 pixels
		&"00CN",
		"SCD 0x%X",
		"scroll-down 0x%X",
		0xfff0,
		0x00C0,
		[ N ],
		func SCROLL_DOWN_N(cpu: CHIPDecoder, n: int):
			cpu.display.scroll(0, n)
			),
	
	Instruction.new(
		&"SCROLL_UP_N", # Scroll up by 0-15 pixels
		&"00DN",
		"SCU 0x%X",
		"scroll-up 0x%X",
		0xfff0,
		0x00D0,
		[ N ],
		func SCROLL_UP_N(cpu: CHIPDecoder, n: int):
			cpu.display.scroll(0, -n)
			),
	
	Instruction.new(
		&"CLS", # Clear
		&"00E0",
		"CLS",
		"clear",
		0xffff,
		0x00E0,
		[],
		func CLS(cpu: CHIPDecoder):
			cpu.display.clear()
			),
	
	Instruction.new(
		&"RET", # Return
		&"00EE",
		"RET",
		"return",
		0xffff,
		0x00EE,
		[],
		func RET(cpu: CHIPDecoder):
			cpu.PC = cpu.stack.pop_back()
			),
	
	Instruction.new(
		&"SCROLL_RIGHT", # Scroll right by 4 pixels
		&"00FB",
		"SCR",
		"scroll-right",
		0xffff,
		0x00FB,
		[],
		func SCROLL_RIGHT(cpu: CHIPDecoder):
			cpu.display.scroll(4, 0)
			),
	
	Instruction.new(
		&"SCROLL_LEFT", # Scroll left by 4 pixels
		&"00FC",
		"SCL",
		"scroll-left",
		0xffff,
		0x00FC,
		[],
		func SCROLL_LEFT(cpu: CHIPDecoder):
			cpu.display.scroll(-4, 0)
			),
	
	Instruction.new(
		&"EXIT", # Immediately exit
		&"00FD",
		"EXIT",
		"exit",
		0xffff,
		0x00FD,
		[],
		func EXIT(cpu: CHIPDecoder):
			cpu.clock.stop.call_deferred()
			cpu.exit.call_deferred()
			),
	
	Instruction.new(
		&"LORES", # Disable hires mode and return to lores 64x32
		&"00FE",
		"LOW",
		"lores",
		0xffff,
		0x00FE,
		[],
		func LORES(cpu: CHIPDecoder):
			cpu.display.resize.call_deferred(64, 32)
			cpu.interrupts.block_until(cpu.interrupts.INTERRUPT_RESIZE)
			),
	
	Instruction.new(
		&"HIRES", # Enable hires mode
		&"00FF",
		"HIGH",
		"hires",
		0xffff,
		0x00FF,
		[],
		func HIRES(cpu: CHIPDecoder):
			cpu.display.resize.call_deferred(128, 64)
			await cpu.interrupts.block_until(cpu.interrupts.INTERRUPT_RESIZE)
			),
	
	Instruction.new(
		&"CLS_64", # Legacy 64x64 clearscreen
		&"0230",
		"CLS 64",
		"clear 64",
		0xffff,
		0x0230,
		[],
		func CLS_64(cpu: CHIPDecoder):
			cpu.display.clear()
			),
	
	Instruction.new(
		&"JP_ADDR", # Jump
		&"1NNN",
		"JP 0x%X",
		"jump 0x%X",
		0xf000,
		0x1000,
		[ NNN ],
		func JP_ADDR(cpu: CHIPDecoder, nnn: int):
			if cpu.PC == 0x202 and nnn == 0x260:
				# Init legacy 64x64 hires mode
				cpu.display.resize.call_deferred(64, 64)
				cpu.interrupts.block_until(cpu.interrupts.INTERRUPT_RESIZE)
				cpu.PC = 0x2C0
			else:
				cpu.PC = nnn
			),
	
	Instruction.new(
		&"CALL_ADDR", # Call
		&"2NNN",
		"CALL 0x%X",
		":call 0x%X",
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
		"SE V%X, 0x%X",
		"if v%x != 0x%X then",
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
		"SNE V%X, 0x%X",
		"if v%x == 0x%X then",
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
		"SE V%X, V%X",
		"if v%x != v%x then",
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
		"LD V%X, 0x%X",
		"v%x := 0x%X",
		0xf000,
		0x6000,
		[ X, NN ],
		func LD_VX_NN(cpu: CHIPDecoder, x: int, nn: int):
			cpu.V[x] = nn
			),
	
	Instruction.new(
		&"ADD_VX_NN", # Vx += NN
		&"7XNN",
		"ADD V%X, 0x%X",
		"v%x += 0x%X",
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
		"LD V%X, V%X",
		"v%x := v%x",
		0xf00f,
		0x8000,
		[ X, Y ],
		func LD_VX_VY(cpu: CHIPDecoder, x: int, y: int):
			cpu.V[x] = cpu.V[y]
			),
	
	Instruction.new(
		&"OR_VX_VY", # Vx |= Vy
		&"8XY1",
		"OR V%X, V%X",
		"v%x |= v%x",
		0xf00f,
		0x8001,
		[ X, Y ],
		func OR_VX_VY(cpu: CHIPDecoder, x: int, y: int):
			cpu.V[x] |= cpu.V[y]
			if cpu.quirks.vf_reset: cpu.V[0xF] = 0
			),
	
	Instruction.new(
		&"AND_VX_VY", # Vx &= Vy
		&"8XY2",
		"AND V%X, V%X",
		"v%x &= v%x",
		0xf00f,
		0x8002,
		[ X, Y ],
		func AND_VX_VY(cpu: CHIPDecoder, x: int, y: int):
			cpu.V[x] &= cpu.V[y]
			if cpu.quirks.vf_reset: cpu.V[0xF] = 0
			),
	
	Instruction.new(
		&"XOR_VX_VY", # Vx ^= Vy
		&"8XY3",
		"XOR V%X, V%X",
		"v%x ^= v%x",
		0xf00f,
		0x8003,
		[ X, Y ],
		func XOR_VX_VY(cpu: CHIPDecoder, x: int, y: int):
			cpu.V[x] ^= cpu.V[y]
			if cpu.quirks.vf_reset: cpu.V[0xF] = 0
			),
	
	Instruction.new(
		&"ADD_VX_VY", # Vx += Vy
		&"8XY4",
		"ADD V%X, V%X",
		"v%x += v%x",
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
		"SUB V%X, V%X",
		"v%x -= v%x",
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
		"SHR V%X, V%X",
		"v%x >>= v%x",
		0xf00f,
		0x8006,
		[ X, Y ],
		func SHR_VX_VY(cpu: CHIPDecoder, x: int, y: int):
			if not cpu.quirks.shifting: cpu.V[x] = cpu.V[y]
			var carry: int = cpu.V[x] & 1
			cpu.V[x] >>= 1
			cpu.V[0xF] = carry
			),
	
	Instruction.new(
		&"SUBN_VX_VY", # Vx = Vy - Vx
		&"8XY7",
		"SUBN V%X, V%X",
		"v%x =- v%x",
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
		"SHL V%X, V%X",
		"v%x <<= v%x",
		0xf00f,
		0x800E,
		[ X, Y ],
		func SHL_VX_VY(cpu: CHIPDecoder, x: int, y: int):
			if not cpu.quirks.shifting: cpu.V[x] = cpu.V[y]
			var carry := (cpu.V[x] & 0x80) >> 7
			cpu.V[x] <<= 1
			cpu.V[0xF] = carry
			),
	#endregion
	
	#region Misc instructions
	Instruction.new(
		&"SNE_VX_VY", # Skip next if Vx != Vy
		&"9XY0",
		"SNE V%X, V%X",
		"if v%x == v%x then",
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
		"LD I, 0x%X",
		"i := 0x%X",
		0xf000,
		0xA000,
		[ NNN ],
		func LD_I_ADDR(cpu: CHIPDecoder, nnn: int):
			cpu.I = nnn
			),
	
	Instruction.new(
		&"JP_V0_ADDR", # Jump to ADDR + V0
		&"BNNN",
		"%X|JP V0, 0x%X",
		"%X|jump0 0x%X",
		0xf000,
		0xB000,
		[ X, NNN ],
		func JP_V0_ADDR(cpu: CHIPDecoder, x: int, nnn: int):
			cpu.PC = nnn + cpu.V[x if cpu.quirks.jumping else 0]
			),
	
	Instruction.new(
		&"RND_VX_NN", # Vx = randi() & NN
		&"CXNN",
		"RND V%X, 0x%X",
		"v%x := random 0x%X",
		0xf000,
		0xC000,
		[ X, NN ],
		func RND_VX_NN(cpu: CHIPDecoder, x: int, nn: int):
			cpu.V[x] = randi() & nn
			),
	
	Instruction.new(
		&"DRW_VX_VY_N", # Draw N-byte sprite at mem pointer I at (Vx, Vy)
		&"DXYN",
		"DRW V%X, V%X, 0x%X",
		"sprite v%x v%x 0x%X",
		0xf000,
		0xD000,
		[ X, Y, N ],
		func DRW_VX_VY_N(cpu: CHIPDecoder, x: int, y: int, n: int):
			if cpu.quirks.display_wait and not cpu.interrupts.poll_interrupt(cpu.interrupts.INTERRUPT_VBLANK):
				cpu.PC -= 2
				return
			
			cpu.V[0xF] = 0
			
			var _x: int = cpu.V[x] % cpu.display.width
			var _y: int = cpu.V[y] % cpu.display.height
			
			if n == 0: # Draw 16x16 SCHIP sprite
				for row in 16:
					var sprite: int = cpu.ram.read_16(row*2 + cpu.I)
					
					for col in 16:
						if (sprite & 0x8000) > 0:
							if cpu.display.set_pixel(
									(_x + col) % cpu.display.width,
									(_y + row) % cpu.display.height):
								cpu.V[0xF] = 1
						
						if cpu.quirks.clipping and (_x + col + 1) >= cpu.display.width: break
						sprite <<= 1
					
					if cpu.quirks.clipping and (_y + row + 1) >= cpu.display.height: break
				return
			
			for row in n:
				var sprite: int = cpu.ram.read(row + cpu.I)
				
				for col in 8:
					if (sprite & 0x80) > 0:
						if cpu.display.set_pixel(
								(_x + col) % cpu.display.width,
								(_y + row) % cpu.display.height):
							cpu.V[0xF] = 1
					
					if cpu.quirks.clipping and (_x + col + 1) >= cpu.display.width: break
					sprite <<= 1
				
				if cpu.quirks.clipping and (_y + row + 1) >= cpu.display.height: break
			),
	
	Instruction.new(
		&"SKP_VX", # Skip next if key Vx is pressed
		&"EX9E",
		"SKP V%X",
		"if v%x -key then",
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
		"SKNP V%X",
		"if v%x key then",
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
		"LD V%X, DT",
		"v%x := delay",
		0xf0ff,
		0xf007,
		[ X ],
		func LD_VX_DT(cpu: CHIPDecoder, x: int):
			cpu.V[x] = cpu.DT
			),
	
	Instruction.new(
		&"LD_VX_K", # Wait for key press, store key in Vx
		&"FX0A",
		"LD V%X, K",
		"v%x := key",
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
		"LD DT, V%X",
		"delay := v%x",
		0xf0ff,
		0xf015,
		[ X ],
		func LD_DT_VX(cpu: CHIPDecoder, x: int):
			cpu.DT = cpu.V[x]
			),
	
	Instruction.new(
		&"LD_ST_VX", # ST = Vx
		&"FX18",
		"LD ST, V%X",
		"buzzer := v%x",
		0xf0ff,
		0xf018,
		[ X ],
		func LD_ST_VX(cpu: CHIPDecoder, x: int):
			cpu.ST = cpu.V[x]
			),
	
	Instruction.new(
		&"ADD_I_VX", # I += Vx
		&"FX1E",
		"ADD I, V%X",
		"i += v%x",
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
		"LD F, V%X",
		"i := hex v%x",
		0xf0ff,
		0xf029,
		[ X ],
		func LD_F_VX(cpu: CHIPDecoder, x: int):
			cpu.I = (cpu.V[x] * 5)
			),
	
	Instruction.new(
		&"LD_B_VX", # Break num in Vx into decimal digits, placed in memory locations I, I+1, I+2
		&"FX33",
		"LD B, V%X",
		"bcd v%x",
		0xf0ff,
		0xf033,
		[ X ],
		func LD_B_VX(cpu: CHIPDecoder, x: int):
			var num := cpu.V[x]
			@warning_ignore("integer_division")
			cpu.ram.write(cpu.I, num / 100)
			@warning_ignore("integer_division")
			cpu.ram.write(cpu.I + 1, (num / 10) % 10)
			cpu.ram.write(cpu.I + 2, num % 10)
			),
	
	Instruction.new(
		&"LD_I_VX", # Store registers V0-Vx in memory starting at pointer I
		&"FX55",
		"LD I, V%X",
		"save v%x",
		0xf0ff,
		0xf055,
		[ X ],
		func LD_I_VX(cpu: CHIPDecoder, x: int):
			for i in x + 1:
				if cpu.quirks.memory:
					cpu.ram.write(cpu.I, cpu.V[i])
					cpu.I += 1
				else:
					cpu.ram.write(cpu.I + i, cpu.V[i])
			),
	
	Instruction.new(
		&"LD_VX_I", # Read registers V0-Vx from memory starting at pointer I
		&"FX65",
		"LD V%X, I",
		"load v%x",
		0xf0ff,
		0xf065,
		[ X ],
		func LD_VX_I(cpu: CHIPDecoder, x: int):
			for i in x + 1:
				if cpu.quirks.memory:
					cpu.V[i] = cpu.ram.read(cpu.I)
					cpu.I += 1
				else:
					cpu.V[i] = cpu.ram.read(cpu.I + i)
			),
	
	Instruction.new(
		&"SAVEFLAGS_VX", # Save V0-Vx to flag registers
		&"FX75",
		"LD R, V%X",
		"saveflags v%x",
		0xf0ff,
		0xf075,
		[ X ],
		func SAVEFLAGS_VX(cpu: CHIPDecoder, x: int):
			for i in x + 1:
				cpu.write_flag(i, cpu.V[i])
			),
	
	Instruction.new(
		&"LOADFLAGS_VX", # Restore V0-Vx from flag registers
		&"FX85",
		"LD V%X, R",
		"loadflags v%x",
		0xf0ff,
		0xf085,
		[ X ],
		func LOADFLAGS_VX(cpu: CHIPDecoder, x: int):
			for i in x + 1:
				cpu.V[i] = cpu.read_flag(i)
			),
	#endregion
]


func invalid_exec(cpu: CHIPDecoder):
	push_error("Invalid opcode at 0x%X (%d)" % [cpu.PC - 2, cpu.PC - 2])

var INVALID_INSTRUCTION := Instruction.new( &"INVALID", &"", "", "", 0, 0, [], invalid_exec )

func filter_instructions(instruction: Instruction, opcode: int) -> bool:
	return (opcode & instruction.mask) == instruction.pattern


func find(opcode: int, report_no_matches: bool = true) -> Instruction:
	var matches := INSTRUCTION_SET.filter(filter_instructions.bind(opcode))
	
	if matches.size() > 1:
		push_error("Too many matches for 0x%X" % opcode)
		for m in matches:
			push_warning("Opcode: %X matched %s (Pattern 0x%x, mask 0x%x)" % [opcode, m.name, m.pattern, m.mask])
		push_warning("Returning first match: %s" % matches[0].name)
		return matches[0]
	
	elif matches.size() == 0:
		if report_no_matches: push_error("No matches for opcode: 0x%X" % opcode)
		var invalid := INVALID_INSTRUCTION.duplicate()
		invalid.name = "%X" % opcode
		invalid.asm = "0x" + invalid.name
		invalid.octo = invalid.asm
		return invalid
	
	else:
		return matches[0]

func disassemble(opcode, report_no_matches: bool = true) -> Opcode:
	var instruction := find(opcode, report_no_matches)
	var op := Opcode.new(opcode, instruction)
	
	return op


class Instruction:
	var id: StringName
	var name: StringName
	var asm: String
	var octo: String
	var mask: int
	var pattern: int
	var arguments: Array[ArgumentType]
	var exec: Callable
	
	func _init(_id: StringName, _name: StringName, _asm: String, _octo: String, _mask: int, _pattern: int, _args: Array[ArgumentType], _exec: Callable) -> void:
		id = _id
		name = _name
		asm = _asm
		octo = _octo
		mask = _mask
		pattern = _pattern
		arguments = _args
		exec = _exec
	
	func duplicate() -> Instruction:
		return Instruction.new(id, name, asm, octo, mask, pattern, arguments, exec)

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
	var asm: String
	var octo: String
	
	func _init(_opcode: int, instruction: Instruction):
		opcode = _opcode
		id = instruction.id
		name = instruction.name
		base = instruction
		args = map_args(opcode, instruction.arguments)
		exec = instruction.exec.bindv( args )
		
		asm = instruction.asm % args
		if "|" in asm: asm = asm.split("|")[1]
		
		octo = instruction.octo % args
		if "|" in octo: octo = octo.split("|")[1]
	
	func map_args(_opcode: int, _args: Array) -> Array[int]:
		var result: Array[int] = []
		
		for arg in _args:
			result.append( (_opcode & arg.mask) >> arg.shift )
			
		return result
