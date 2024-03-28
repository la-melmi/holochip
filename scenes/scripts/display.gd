class_name CHIPDisplay
extends TextureRect

signal refreshed

@onready var framebuffer := BitMap.new()
var mutex := Mutex.new()

@export var width: int
@export var height: int

func _ready() -> void:
	resize(64, 32)

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
	if visible:
		texture.update(framebuffer.convert_to_image())
	mutex.unlock()
	refreshed.emit()

func resize(w: int, h: int) -> void:
	mutex.lock()
	
	var aspect := float(w) / float(h)
	
	if aspect != float(width) / float(height):
		get_viewport().content_scale_size = Vector2i(960, 960) * aspect
	
	width = w
	height = h
	framebuffer.resize( Vector2i(width, height) )
	texture = ImageTexture.create_from_image(framebuffer.convert_to_image())
	mutex.unlock()

func resizev(dimensions: Vector2i) -> void:
	resize(dimensions.x, dimensions.y)

func clear() -> void:
	mutex.lock()
	framebuffer = BitMap.new()
	framebuffer.resize( Vector2i(width, height) )
	mutex.unlock()

func scroll(x_scroll: int, y_scroll: int) -> void:
	mutex.lock()
	
	var original := framebuffer.duplicate()
	clear()
	
	for x in width:
		for y in height:
			var new_x := x + x_scroll
			var new_y := y + y_scroll
			
			if new_x >= width or new_x < 0 or new_y >= height or new_y < 0:
				continue
			
			framebuffer.set_bit(new_x, new_y, original.get_bit(x, y))
	
	mutex.unlock()
