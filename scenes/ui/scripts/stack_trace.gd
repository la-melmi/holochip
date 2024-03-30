extends Window


signal address_clicked(address: int)

@export var address_scene: PackedScene

@onready var stack_container: VBoxContainer = $ScrollContainer/VBoxContainer

@export var stack: Array[int]:
	set(new):
		stack = new
		if is_node_ready(): update_stack()

func _ready() -> void:
	update_stack()

func update_stack() -> void:
	clear()
	
	title = "Depth: %d" % stack.size()
	
	for i in stack.size():
		var addr := stack[-i-1] # Iterate backwards
		
		var item := address_scene.instantiate()
		item.address = addr
		item.clicked.connect(_on_address_clicked)
		stack_container.add_child(item)
	
	for i in 16 - stack.size():
		var item := address_scene.instantiate()
		item.address = 0
		item.fake = true
		stack_container.add_child(item)

func clear() -> void:
	for child in stack_container.get_children():
		stack_container.remove_child(child)
		child.queue_free()

func toggle() -> void:
	visible = not visible

func _on_address_clicked(address: int) -> void:
	address_clicked.emit(address)
