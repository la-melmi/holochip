extends Node3D

@onready var display: CHIPDisplay = $"CHIP-8".display
@onready var cpu: Node = $"CHIP-8"

@export var mesh_instance: MeshInstance3D
@export var voxel_scene: PackedScene

func _ready() -> void:
	cpu.refreshed.connect(_on_chip_refresh)
	display.visible = false
	mesh_instance["surface_material_override/0"].albedo_color = Color.BLACK
	
	prep_array()

func _on_chip_refresh() -> void:
	#mesh_instance["surface_material_override/0"].albedo_texture = display.texture
	for x in display.width:
		for y in display.height:
			if display.get_pixel(x, y):
				$VoxelArray.get_child( y + (x * display.height) ).visible = true
			else:
				$VoxelArray.get_child( y + (x * display.height) ).visible = false


func prep_array() -> void:
	for x in display.width:
		for y in display.height:
			var voxel: Node3D = voxel_scene.instantiate()
			voxel.position = Vector3(x, -y - 1, 0.0)
			voxel.position += voxel.scale / 2.0
			$VoxelArray.add_child(voxel)
		
