class_name RegisterDisplay
extends PanelContainer


signal selected(address: int)

@export var nibbles: int = 2
@export var selectable: bool

var byte: int:
	set(value):
		byte = value
		if is_node_ready(): update_label()

func _ready() -> void:
	update_label()
	if selectable:
		mouse_filter = Control.MOUSE_FILTER_PASS

func _gui_input(event: InputEvent) -> void:
	if selectable and event.is_action_pressed("click"):
		selected.emit(byte)

func update_label() -> void:
	$Value.text = HexTools.to_hex(byte, nibbles)


func _on_mouse_entered() -> void:
	self_modulate.a = 0.5

func _on_mouse_exited() -> void:
	self_modulate.a = 1.0
