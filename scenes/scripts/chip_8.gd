extends Node

@export_file("*.ch8") var rom: String

## Whether to use legacy or modern behavior
@export var legacy: bool = true

## Clock speed to run at, in Hz
@export var clock_speed: float = INF
@export var ram: RAM
@onready var display: CHIPDisplay = $Display
@onready var keypad: CHIPKeypad = $Keypad

var stack: Array[int]

#region Register definitions
var V := PackedByteArray()

var I: int:
	set(value): I = value % 65536

var PC: int = 0x200:
	set(value): PC = value % 65536

var SP: int:
	set(value): SP = value % 256

var DT: int:
	set(value): DT = value % 256

var ST: int:
	set(value): ST = value % 256
#endregion

@export var paused: bool

func _input(event):
	if event.is_action_pressed("ui_accept"):
		paused = not paused

func _ready() -> void:
	V.resize(16)
	
	if rom:
		import_rom(rom)

func import_rom(path: String):
	var file := FileAccess.open(path, FileAccess.READ)
	var import_pointer: int = 0x200
	
	while file.get_position() < file.get_length():
		ram.write(import_pointer, file.get_8())
		import_pointer += 1

#region Process loops
func _physics_process(_delta) -> void:
	DT = max(DT - 1, 0)
	ST = max(DT - 1, 0)
	
	if ST == 0:
		pass

var clock: float

## Set clock interval to 0, a non-number if the clock speed is set to match the framerate
## Otherwise, the clock interval will be the inverse of the clock speed, unless the clock speed is 0
## in which case the clock interval is INF to prevent it from ever ticking
@onready var clock_interval: float = ( 1.0 if clock_speed == INF else (1.0/clock_speed) if clock_speed else INF )
func _process(delta) -> void:
	if paused: return
	
	if clock_speed == INF:
		clock = clock_interval
	else:
		clock += delta
	
	while clock >= clock_interval:
		clock -= clock_interval
		var instruction: int = fetch()
		decode(instruction)
#endregion

#region Fetch/Decode
func fetch() -> int:
	var first_byte: int = ram.read(PC)
	var second_byte: int = ram.read(PC + 1)
	PC += 2
	return (first_byte*256) | second_byte

func decode(instruction: int) -> void:
	var opcode: int = (instruction & 61440) >> 12
	
	#print("0x%X: 0x%X" % [PC, opcode])
	
	match opcode:
		0x0: # Multiple instructions
			match decode_NNN(instruction):
				0x0E0: # Clear screen
					for x in display.width:
						for y in display.height:
							display.clear_pixel(x, y)
					display.refresh()
				0x0EE: # Return from subroutine
					PC = stack.pop_back()
				_:
					push_error("0x%X: %X" % [PC, instruction])
		
		0x1: # Jump
			PC = decode_NNN(instruction)
		
		0x2: # Subroutine
			stack.append(PC)
			PC = decode_NNN(instruction)
		
		0x3: # Skip if Vx == NN
			if V[decode_X(instruction)] == decode_NN(instruction):
				PC += 2
		
		0x4: # Skip if Vx != NN
			if V[decode_X(instruction)] != decode_NN(instruction):
				PC += 2
		
		0x5: # Skip if Vx == Vy
			if V[decode_X(instruction)] == decode_Y(instruction):
				PC += 2
		
		0x6: # Set
			V[decode_X(instruction)] = decode_NN(instruction)
		
		0x7: # Add
			V[decode_X(instruction)] += decode_NN(instruction)
		
		0x8: # Logic and arithmetic
			var x: int = decode_X(instruction)
			var y: int = decode_Y(instruction)
			
			match decode_N(instruction):
				0x0: # Set
					V[x] = V[y]
				
				0x1: # Bitwise OR
					V[x] = V[x] | V[y]
				
				0x2: # Bitwise AND
					V[x] = V[x] & V[y]
				
				0x3: # Bitwise XOR
					V[x] = V[x] ^ V[y]
				
				0x4: # Add
					var result := V[x] + V[y]
					V[x] = result
					if result > 255:
						V[0xF] = 1
					else:
						V[0xF] = 0
				
				0x5: # Subtract X - Y
					var result: int = V[x] - V[y]
					V[x] = result
					V[0xF] = int(result >= 0)
				
				0x6:
					V[x] = V[y]
					var carry := V[x] & 1
					V[x] >>= 1
					V[0xF] = carry
				
				0x7: # Subtract Y - X
					var result: int = V[y] - V[x]
					V[x] = result
					V[0xF] = int(result >= 0)
				
				0xE:
					V[x] = V[y]
					var carry := (V[x] & 0x80) >> 7
					V[x] <<= 1
					V[0xF] = carry
				
				_:
					push_error("0x%X: %X" % [PC, instruction])
		
		0x9: # Skip if Vx != Vy
			if V[decode_X(instruction)] != V[decode_Y(instruction)]:
				PC += 2
		
		0xA: # Set Index
			I = decode_NNN(instruction)
		
		0xB: # Jump with offset
			PC = decode_NNN(instruction) + V[0]
		
		0xC: # Random
			V[decode_X(instruction)] = randi() & decode_NN(instruction)
		
		0xD: # Draw
			V[0xF] = 0
			
			var x: int = V[decode_X(instruction)] % display.width
			var y: int = V[decode_Y(instruction)] % display.height
			
			for row in decode_N(instruction):
				var sprite: int = ram.read(row + I)
				
				for col in 8:
					if (sprite & 0x80) > 0:
						if display.set_pixel(x + col, y + row):
							V[0xF] = 1
					
					if (x + col + 1) >= display.width: break
					sprite <<= 1
				
				if (y + row + 1) >= display.height: break
			
			display.refresh()
		
		0xF: # Multi instruction
			var x: int = decode_X(instruction)
			match decode_NN(instruction):
				0x07: # Set Vx to value of delay timer
					V[x] = DT
				0x15: # Set delay timer to value of Vx
					DT = V[x]
				0x18: # Set sound timer to value of Vx
					ST = V[x]
				0x1E:
					I += V[x]
					if I >= 0x1000:
						V[0xF] = 1
				0x33:
					var num := V[x]
					ram.write(I, num / 100)
					ram.write(I + 1, (num / 10) % 10)
					ram.write(I + 2, num % 10)
				0x55:
					for i in x + 1:
						if legacy:
							ram.write(I, V[i])
							I += 1
						else:
							ram.write(I + i, V[i])
				0x65:
					for i in x + 1:
						if legacy:
							V[I] = ram.read(I)
							I += 1
						else:
							V[i] = ram.read(I + i)
				_:
					push_error("0x%X: %X" % [PC, instruction])
		
		_:
			push_error("0x%X: %X" % [PC, instruction])

#endregion

#region Decoding helper functions
## Return the second nibble in the instruction
func decode_X(instruction: int) -> int:
	return (instruction & 3840) >> 8

## Return the third nibble in the instruction
func decode_Y(instruction: int) -> int:
	return (instruction & 240) >> 4

## Return the fourth nibble in the instruction
func decode_N(instruction: int) -> int:
	return instruction & 15

## Return the second byte (third and fourth nibbles).
func decode_NN(instruction: int) -> int:
	return instruction & 255

## Return the second, third, and fourth nibbles. A 12-bit immediate memory address.
func decode_NNN(instruction: int) -> int:
	return instruction & 4095

## Split a byte into an array of boolean bits
func split_byte(byte: int) -> Array[bool]:
	return [
		(byte & 0b10000000) != 0,
		(byte & 0b01000000) != 0,
		(byte & 0b00100000) != 0,
		(byte & 0b00010000) != 0,
		(byte & 0b00001000) != 0,
		(byte & 0b00000100) != 0,
		(byte & 0b00000010) != 0,
		(byte & 0b00000001) != 0,
	]
#endregion
