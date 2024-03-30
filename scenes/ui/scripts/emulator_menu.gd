extends MenuBar


signal memory_opened
signal stack_opened
signal registers_opened

enum {
	DEBUG_MEMORY,
	DEBUG_STACK,
	DEBUG_REGISTERS,
}

@export var chip: CHIP8

@onready var options: PopupMenu = $Options
@onready var system: PopupMenu = $Options/System

func _ready() -> void:
	options.add_submenu_item("System", "System")
	setup.call_deferred()

func setup() -> void:
	system.set_item_checked( chip.quirks.system, true )

func _on_debug_id_pressed(id: int):
	match id:
		DEBUG_MEMORY:
			memory_opened.emit()
		DEBUG_STACK:
			stack_opened.emit()
		DEBUG_REGISTERS:
			registers_opened.emit()

func _on_system_index_pressed(index: int):
	for i in system.item_count:
		system.set_item_checked(i, false)
	
	system.set_item_checked(index, true)
	chip.quirks.system = index as QuirkHandler.System
