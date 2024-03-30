extends Window


@export var byte_scene: PackedScene
@export var ram: RAM

@onready var container: GridContainer = $ScrollContainer/GridContainer

var PC: int:
	set(new):
		if is_node_ready() and PC != new:
			update_PC(PC, new)
		PC = new

func _ready() -> void:
	generate_memory_grid()
	#ram.written.connect()
	fix_size.call_deferred()

func fix_size() -> void:
	size.y = size.x
	max_size.x = size.x

func generate_memory_grid() -> void:
	clear()
	
	ram.mutex.lock()
	
	for byte in ram.memory:
		var byte_display := byte_scene.instantiate()
		byte_display.byte = byte
		container.add_child(byte_display)
	
	ram.mutex.unlock()

func _on_ram_written(address: int) -> void:
	ram.mutex.lock()
	var byte := ram.memory[address]
	ram.mutex.unlock()
	
	container.get_child(address).byte = byte

func clear() -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func update_PC(old: int, new: int) -> void:
	container.get_child(old).active = false
	container.get_child(old + 1).active = false
	
	container.get_child(new).active = true
	container.get_child(new + 1).active = true
