extends Window


@export var v_container: BoxContainer
@export var i_panel: RegisterDisplay
@export var pc_panel: RegisterDisplay
@export var dt_panel: RegisterDisplay
@export var st_panel: RegisterDisplay

var V: PackedByteArray
var I: int
var PC: int
var DT: int
var ST: int

func update_registers() -> void:
	for i in V.size():
		v_container.get_child(i).byte = V[i]
	
	i_panel.byte = I
	pc_panel.byte = PC
	dt_panel.byte = DT
	st_panel.byte = ST

func toggle() -> void:
	visible = not visible
