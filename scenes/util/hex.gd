class_name HexTools
extends Object


static func to_hex(hex: int, nibbles: int = 4, capitalize: bool = true) -> String:
	var ret := ""
	var fmt := "%X" if capitalize else "%x"
	
	for i in nibbles - 1:
		var nib := i * 4
		ret = ( fmt % ( (hex & (0xF << nib)) >> nib ) ) + ret
	
	var most_nib := (nibbles - 1) * 4
	ret = ( fmt % ( hex >> most_nib ) ) + ret
	
	return ret
