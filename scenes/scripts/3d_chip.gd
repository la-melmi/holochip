extends Node3D

@onready var display: CHIPDisplay = $"CHIP-8".display
@onready var cpu: Node = $"CHIP-8"

@export var mesh_instance: MeshInstance3D

func _ready() -> void:
	cpu.refreshed.connect(_on_chip_refresh)
	display.visible = false

func _on_chip_refresh() -> void:
	mesh_instance["surface_material_override/0"].albedo_texture = display.texture
