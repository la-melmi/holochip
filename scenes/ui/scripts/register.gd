class_name RegisterDisplay
extends PanelContainer


@export var nibbles: int = 2

var byte: int:
	set(value):
		byte = value
		if is_node_ready(): update_label()

func _ready() -> void:
	update_label()

func update_label() -> void:
	$Value.text = HexTools.to_hex(byte, nibbles)
