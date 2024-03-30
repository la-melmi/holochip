extends Window


signal address_clicked(address: int)

@export var address_scene: PackedScene

@onready var stack_container: VBoxContainer = $VBoxContainer

@export var stack: Array[int]:
	set(new):
		stack = new
		if is_node_ready(): update_stack()

func _ready() -> void:
	update_stack()

func update_stack() -> void:
	clear()
	
	for i in stack.size():
		var addr := stack[-i-1] # Iterate backwards
		
		var item := address_scene.instantiate()
		item.address = addr
		stack_container.add_child(item)


func clear() -> void:
	for child in stack_container.get_children():
		stack_container.remove_child(child)
		child.queue_free()
