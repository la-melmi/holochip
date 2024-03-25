class_name CHIPKeypad
extends Node


signal key_pressed(key: int)

func _input(event) -> void:
	if event.is_action_released("keypad_0"):
		key_pressed.emit(0x0)
	elif event.is_action_released("keypad_1"):
		key_pressed.emit(0x1)
	elif event.is_action_released("keypad_2"):
		key_pressed.emit(0x2)
	elif event.is_action_released("keypad_3"):
		key_pressed.emit(0x3)
	elif event.is_action_released("keypad_4"):
		key_pressed.emit(0x4)
	elif event.is_action_released("keypad_5"):
		key_pressed.emit(0x5)
	elif event.is_action_released("keypad_6"):
		key_pressed.emit(0x6)
	elif event.is_action_released("keypad_7"):
		key_pressed.emit(0x7)
	elif event.is_action_released("keypad_8"):
		key_pressed.emit(0x8)
	elif event.is_action_released("keypad_9"):
		key_pressed.emit(0x9)
	elif event.is_action_released("keypad_A"):
		key_pressed.emit(0xA)
	elif event.is_action_released("keypad_B"):
		key_pressed.emit(0xB)
	elif event.is_action_released("keypad_C"):
		key_pressed.emit(0xC)
	elif event.is_action_released("keypad_D"):
		key_pressed.emit(0xD)
	elif event.is_action_released("keypad_E"):
		key_pressed.emit(0xE)
	elif event.is_action_released("keypad_F"):
		key_pressed.emit(0xF)

func is_key_pressed(key: int) -> bool:
	match key:
		0x0:
			return Input.is_action_pressed("keypad_0")
		0x1:
			return Input.is_action_pressed("keypad_1")
		0x2:
			return Input.is_action_pressed("keypad_2")
		0x3:
			return Input.is_action_pressed("keypad_3")
		0x4:
			return Input.is_action_pressed("keypad_4")
		0x5:
			return Input.is_action_pressed("keypad_5")
		0x6:
			return Input.is_action_pressed("keypad_6")
		0x7:
			return Input.is_action_pressed("keypad_7")
		0x8:
			return Input.is_action_pressed("keypad_8")
		0x9:
			return Input.is_action_pressed("keypad_9")
		0xA:
			return Input.is_action_pressed("keypad_A")
		0xB:
			return Input.is_action_pressed("keypad_B")
		0xC:
			return Input.is_action_pressed("keypad_C")
		0xD:
			return Input.is_action_pressed("keypad_D")
		0xE:
			return Input.is_action_pressed("keypad_E")
		0xF:
			return Input.is_action_pressed("keypad_F")
	return false
