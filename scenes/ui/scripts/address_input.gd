class_name AddressInput
extends TextEdit


signal address_entered(address: int)

var addr: int

func _ready() -> void:
	text_changed.connect(_on_text_changed)
	#set_overtype_mode_enabled(true)

func _on_text_changed() -> void:
	if "\n" in text and text.replace("\n", "").is_valid_hex_number():
			addr = text.replace("\n", "").hex_to_int()
			text = HexTools.to_hex(addr, 4)
			address_entered.emit(addr)
			return
	
	if text.length() > 4:
		text = text.left(4)
	
	if not text.is_valid_hex_number():
		if text.left(text.length() - 1).is_valid_hex_number():
			text = text.left(text.length() - 1)
		else:
			text = ""
