extends Window


@export var byte_scene: PackedScene
@export var ram: RAM

@onready var container: GridContainer = $ScrollContainer/GridContainer

var drawn: bool

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
		byte_display.memory_selected.connect(_on_memory_selected)
		byte_display.unselect_all_memory.connect(_on_unselect_all_memory)
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


func _on_visibility_changed() -> void:
	if not drawn:
		size.y = size.x
		drawn = true

func _on_memory_selected(selection: PanelContainer) -> void:
	grab_focus()
	$ScrollContainer.ensure_control_visible(selection)
	for byte in container.get_children():
		if byte != selection:
			byte.selected = false

func _on_unselect_all_memory() -> void:
	for byte in container.get_children():
		byte.selected = false


func toggle() -> void:
	visible = not visible


func _on_stack_viewer_address_clicked(address: int) -> void:
	print(address)
	container.get_child(address).selected = true
