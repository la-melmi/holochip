@tool
extends Label


func _ready() -> void:
	text = name
	renamed.connect(_on_renamed)

func _on_renamed() -> void:
	text = name
