class_name CHIPDecoder
extends Node


@export var legacy: bool = true
@export var instruction_set: Script
@export var display: CHIPDisplay
@export var clock: Clock
@export var keypad: CHIPKeypad
@export var interrupts: InterruptController

@export var ram: RAM

@onready var _isa = instruction_set.new()

var stack: Array[int]
var mutex := Mutex.new()

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

func _ready() -> void:
	assert(_isa.get("INSTRUCTION_SET"), "Invalid instruction set provided.")
	
	V.resize(16)
	
	clock.callbacks.append(step)
	clock.timer_callbacks.append(timer_tick)


func timer_tick() -> void:
	mutex.lock()
	DT = max(DT - 1, 0)
	ST = max(ST - 1, 0)
	mutex.unlock()

func step() -> void:
	var opcode: int = fetch()
	PC += 2
	var instruction: Array = decode(opcode)
	
	#print(instruction[0])
	execute(instruction)


const X := &"X"
const Y := &"Y"
const N := &"N"
const NN := &"NN"
const NNN := &"NNN"

func fetch() -> int:
	return ram.read_16(PC)

func decode(opcode) -> Array:
	return _isa.disassemble(opcode)

func execute(instruction) -> void:
	var opcode: StringName = instruction[0]
	var args = instruction[1]
	
	if interrupts.poll_interrupt(interrupts.INTERRUPT_DEBUG):
		pass
	
	match opcode:
		
		&"00E0": # Clear screen
			for x in display.width:
				for y in display.height:
					display.clear_pixel(x, y)
		
		&"00EE": # Return from subroutine
			PC = stack.pop_back()
		
		&"1NNN": # Jump
			PC = args.NNN
		
		&"2NNN": # Call subroutine
			stack.append(PC)
			PC = args.NNN
		
		&"3XNN": # Skip if Vx == NN
			if V[args.X] == args.NN:
				PC += 2
		
		&"4XNN": # Skip if Vx != NN
			if V[args.X] != args.NN:
				PC += 2
		
		&"5XY0": # Skip if Vx == Vy
			if V[args.X] == args.Y:
				PC += 2
		
		&"6XNN": # Set
			V[args.X] = args.NN
		
		&"7XNN": # Add
			V[args.X] += args.NN
		
		#region Logic and arithmetic (8XY.)
		&"8XY0": # Set
			V[args.X] = V[args.Y]
		
		&"8XY1": # Bitwise OR
			V[args.X] = V[args.X] | V[args.Y]
			V[0xF] = 0
		
		&"8XY2": # Bitwise AND
			V[args.X] = V[args.X] & V[args.Y]
			V[0xF] = 0
		
		&"8XY3": # Bitwise XOR
			V[args.X] = V[args.X] ^ V[args.Y]
			V[0xF] = 0
		
		&"8XY4": # Add
			var result := V[args.X] + V[args.Y]
			V[args.X] = result
			if result > 255:
				V[0xF] = 1
			else:
				V[0xF] = 0
		
		&"8XY5": # Subtract X - Y
			var result: int = V[args.X] - V[args.Y]
			V[args.X] = result
			V[0xF] = int(result >= 0)
		
		&"8XY6":
			V[args.X] = V[args.Y]
			var carry := V[args.X] & 1
			V[args.X] >>= 1
			V[0xF] = carry
		
		&"8XY7": # Subtract Y - X
			var result: int = V[args.Y] - V[args.X]
			V[args.X] = result
			V[0xF] = int(result >= 0)
		
		&"8XYE":
			V[args.X] = V[args.Y]
			var carry := (V[args.X] & 0x80) >> 7
			V[args.X] <<= 1
			V[0xF] = carry
		#endregion
		
		&"9XY0": # Skip if Vx != Vy
			if V[args.X] != V[args.Y]:
				PC += 2
		
		&"ANNN": # Set Index
			I = args.NNN
		
		&"BNNN": # Jump with offset
			PC = args.NNN + V[0]
		
		&"CXNN": # Random
			V[args.X] = randi() & args.NN
		
		&"DXYN": # Draw
			if legacy and not interrupts.poll_interrupt(interrupts.INTERRUPT_VBLANK):
				PC -= 2
				return
			
			V[0xF] = 0
			
			var x: int = V[args.X] % display.width
			var y: int = V[args.Y] % display.height
			
			for row in args.N:
				var sprite: int = ram.read(row + I)
				
				for col in 8:
					if (sprite & 0x80) > 0:
						if display.set_pixel(x + col, y + row):
							V[0xF] = 1
					
					if (x + col + 1) >= display.width: break
					sprite <<= 1
				
				if (y + row + 1) >= display.height: break
		
		
		&"EX9E": # skip if key
			if keypad.is_key_pressed(V[args.X]):
				PC += 2
		&"EXA1": # Skip if not key
			if not keypad.is_key_pressed(V[args.X]):
				PC += 2
		
		&"FX0A":
			if not interrupts.poll_interrupt(interrupts.INTERRUPT_KEY):
				PC -= 2
				return
			else:
				V[args.X] = interrupts.poll_interrupt(interrupts.INTERRUPT_KEY)
		
		&"FX07": # Set Vx to value of delay timer
			V[args.X] = DT
		&"FX15": # Set delay timer to value of Vx
			DT = V[args.X]
		&"FX18": # Set sound timer to value of Vx
			ST = V[args.X]
		&"FX1E": # Add to index
			I += V[args.X]
			if I >= 0x1000: # This overflow is a weird undefined quirk
				V[0xF] = 1
		&"FX29": # Get font character
			I = 0x50 + (V[args.X] * 5)
		&"FX33": # Binary to decimal conversion
			var num := V[args.X]
			ram.write(I, num / 100)
			ram.write(I + 1, (num / 10) % 10)
			ram.write(I + 2, num % 10)
		&"FX55": # Store in memory
			for i in args.X + 1:
				if legacy:
					ram.write(I, V[i])
					I += 1
				else:
					ram.write(I + i, V[i])
		&"FX65": # Load from memory
			for i in args.X + 1:
				if legacy:
					V[i] = ram.read(I)
					I += 1
				else:
					V[i] = ram.read(I + i)
		
		_:
			push_error("Invalid opcode at 0x%X" % PC)
			pass
