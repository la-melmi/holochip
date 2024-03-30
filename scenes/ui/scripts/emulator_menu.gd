extends MenuBar


signal memory_opened
signal stack_opened
signal registers_opened

enum {
	DEBUG_MEMORY,
	DEBUG_STACK,
	DEBUG_REGISTERS,
}

func _on_debug_id_pressed(id: int):
	match id:
		DEBUG_MEMORY:
			memory_opened.emit()
		DEBUG_STACK:
			stack_opened.emit()
		DEBUG_REGISTERS:
			registers_opened.emit()
