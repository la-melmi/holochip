extends PanelContainer


signal memory_selected(node: PanelContainer)
signal unselect_all_memory
signal odd_address_selected(new_address: int)

var byte: int:
	set(value):
		byte = value
		update_label()

var active: bool:
	set(state):
		active = state
		if active: make_active()
		else: make_inactive()

var selected: bool = false:
	set(state):
		if state and addr % 2 == 1: # Alig 
			odd_address_selected.emit(addr - 1)
			return
		selected = state
		$Selection.visible = state
		if selected: memory_selected.emit(self)

var addr: int

func _ready() -> void:
	self["theme_override_styles/panel"] = self["theme_override_styles/panel"].duplicate()
	selected = false

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		selected = true
	if event.is_action_pressed("right_click"):
		selected = false
		unselect_all_memory.emit()

func update_label() -> void:
	$Label.text = HexTools.to_hex(byte, 2)


func make_active() -> void:
	self["theme_override_styles/panel"].bg_color.r = 0.8

func make_inactive() -> void:
	self["theme_override_styles/panel"].bg_color.r = 0.173
