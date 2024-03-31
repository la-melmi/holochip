extends MenuBar

signal builtin_rom_dialog_opened
signal custom_rom_dialog_opened

signal memory_opened
signal stack_opened
signal registers_opened

signal vm_reset

enum {
	OPEN_BUILTIN,
	OPEN_CUSTOM,
}

enum {
	DEBUG_MEMORY,
	DEBUG_STACK,
	DEBUG_REGISTERS,
}

enum {
	VM_RESET,
	VM_PAUSED,
	VM_STEP,
	VM_FRAME_STEP,
}

enum {
	OPTIONS_LEGACY,
	OPTIONS_SYSTEM,
}

@onready var file: PopupMenu = $File
@onready var options: PopupMenu = $Options
@onready var system: PopupMenu = $Options/System
@onready var vm: PopupMenu = $VM

var chip: CHIP8

func _ready() -> void:
	file.add_submenu_item("Open ROM", "Open")
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


func _on_system_id_pressed(index: int):
	for i in system.item_count:
		system.set_item_checked(i, false)
	
	system.set_item_checked(index, true)
	chip.quirks.system = index as QuirkHandler.System

func _on_chip_ready() -> void:
	chip.quirks.legacy = options.is_item_checked( options.get_item_index(OPTIONS_LEGACY) )
	for i in system.item_count:
		if system.is_item_checked(i):
			chip.quirks.system = i as QuirkHandler.System
			break


func _on_vm_id_pressed(id: int):
	match id:
		VM_RESET:
			vm_reset.emit()
		VM_PAUSED:
			var index := vm.get_item_index(id)
			vm.toggle_item_checked(index)
			var paused := vm.is_item_checked(index)
			chip.clock.paused = paused
			if paused:
				vm.set_item_disabled( vm.get_item_index(VM_STEP), false )
				vm.set_item_disabled( vm.get_item_index(VM_FRAME_STEP), false )
			else:
				vm.set_item_disabled( vm.get_item_index(VM_STEP), true )
				vm.set_item_disabled( vm.get_item_index(VM_FRAME_STEP), true )
		VM_STEP:
			chip.clock.step = true
		VM_FRAME_STEP:
			chip.clock.frame_step = 2


func _on_options_id_pressed(id: int):
	match id:
		OPTIONS_LEGACY:
			var index := options.get_item_index(id)
			options.toggle_item_checked(index)
			chip.quirks.legacy = options.is_item_checked(index)


func _on_open_id_pressed(id: int):
	match id:
		OPEN_BUILTIN:
			builtin_rom_dialog_opened.emit()
		OPEN_CUSTOM:
			custom_rom_dialog_opened.emit()
