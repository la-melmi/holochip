extends MeshInstance3D


var tween: Tween:
	set(new):
		if tween:
			tween.kill()
		tween = new

func _ready() -> void:
	self["surface_material_override/0"] = self["surface_material_override/0"].duplicate()

func fade_out() -> void:
	visible = false
	#tween = create_tween()
	#tween.tween_property(self["surface_material_override/0"], "albedo_color:a", 0.0, 0.05)

func fade_in() -> void:
	visible = true
	#tween = create_tween()
	#tween.tween_property(self["surface_material_override/0"], "albedo_color:a", 1.0, 0.05)
