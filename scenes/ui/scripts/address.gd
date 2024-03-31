extends Control


signal clicked(address: int)

var address: int:
	set(addr):
		address = addr
		update_address()

var fake: bool:
	set(state):
		fake = state
		update_fake()

func _gui_input(event: InputEvent) -> void:
	if not fake and event.is_action_pressed("click"):
		clicked.emit(address)

func update_address() -> void:
	$Label.text = HexTools.to_hex(address, 4)

func update_fake() -> void:
	if fake:
		modulate.a = 0.5
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		modulate.a = 1.0
		mouse_filter = Control.MOUSE_FILTER_STOP
