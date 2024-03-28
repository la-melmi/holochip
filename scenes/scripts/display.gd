class_name CHIPDisplay
extends TextureRect

signal refreshed

@onready var framebuffer := BitMap.new()
var mutex := Mutex.new()

@export var width: int
@export var height: int

func _ready() -> void:
	framebuffer.resize( Vector2i(width, height) )
	texture = ImageTexture.create_from_image(framebuffer.convert_to_image())

func _physics_process(_delta):
	refresh()


func get_pixel(x: int, y: int) -> bool:
	mutex.lock()
	var pixel := framebuffer.get_bit(x, y)
	mutex.unlock()
	
	return pixel

func set_pixel(x: int, y: int, toggled_on: bool = true) -> bool:
	if not toggled_on: return false
	
	mutex.lock()
	if get_pixel(x, y):
		framebuffer.set_bit(x, y, false)
		mutex.unlock()
		return true
	else:
		framebuffer.set_bit(x, y, true)
		mutex.unlock()
		return false

func clear_pixel(x: int, y: int) -> void:
	mutex.lock()
	framebuffer.set_bit(x, y, false)
	mutex.unlock()

func refresh() -> void:
	mutex.lock()
	texture.update(framebuffer.convert_to_image())
	mutex.unlock()
	refreshed.emit()
