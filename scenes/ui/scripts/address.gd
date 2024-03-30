extends Control


var address: int:
	set(addr):
		address = addr
		update_address()

func update_address() -> void:
	$Label.text = "0x" + HexTools.to_hex(address, 4)
