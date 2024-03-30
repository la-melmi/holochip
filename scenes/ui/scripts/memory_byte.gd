extends PanelContainer


var byte: int:
	set(value):
		byte = value
		update_label()

var active: bool:
	set(state):
		active = state
		if active: make_active()
		else: make_inactive()

func _ready() -> void:
	self["theme_override_styles/panel"] = self["theme_override_styles/panel"].duplicate()

func update_label() -> void:
	$Label.text = HexTools.to_hex(byte, 2)


func make_active() -> void:
	self["theme_override_styles/panel"].bg_color.r = 0.8

func make_inactive() -> void:
	self["theme_override_styles/panel"].bg_color.r = 0.173
