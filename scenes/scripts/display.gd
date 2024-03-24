class_name CHIPDisplay
extends TextureRect

@onready var framebuffer := BitMap.new()

@export var width: int
@export var height: int

func _ready() -> void:
	framebuffer.resize( Vector2i(width, height) )
	texture = ImageTexture.create_from_image(framebuffer.convert_to_image())

func get_pixel(x: int, y: int) -> bool:
	return framebuffer.get_bit(x, y)

func set_pixel(x: int, y: int, toggled_on: bool = true) -> bool:
	if not toggled_on: return false
	
	if get_pixel(x, y):
		framebuffer.set_bit(x, y, false)
		return true
	else:
		framebuffer.set_bit(x, y, true)
		return false

func clear_pixel(x: int, y: int) -> void:
	framebuffer.set_bit(x, y, false)

func refresh() -> void:
	texture.update(framebuffer.convert_to_image())
