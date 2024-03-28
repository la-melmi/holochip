extends InterruptController


enum {
	INTERRUPT_VBLANK,
	INTERRUPT_KEY,
	INTERRUPT_DEBUG,
	INTERRUPT_RESIZE,
}

func _input(event):
	if event.is_action_pressed("debug"):
		interrupt(INTERRUPT_DEBUG)

func _ready() -> void:
	_interrupts.resize(4)

func _on_display_refreshed() -> void:
	interrupt(INTERRUPT_VBLANK)

func _on_keypad_key_pressed(key: int):
	interrupt(INTERRUPT_KEY, key)

func _on_display_buffer_resized() -> void:
	interrupt(INTERRUPT_RESIZE)
