class_name InterruptController
extends Node

var mutex := Mutex.new()

var _interrupts: Array[Variant]

func interrupt(index: int, msg: Variant = true) -> void:
	mutex.lock()
	_interrupts[index] = msg
	mutex.unlock()

func acknowledge() -> void:
	mutex.lock()
	for i in _interrupts.size():
		_interrupts[i] = false
	mutex.unlock()

func poll_interrupt(index: int) -> Variant:
	mutex.lock()
	var state = _interrupts[index]
	mutex.unlock()
	return state

func poll_all_interrupts() -> Array[Variant]:
	mutex.lock()
	var state := _interrupts.duplicate()
	mutex.unlock()
	return state


func block_until(index: int, allow_current: bool = false) -> Variant:
	while _interrupts[index] and allow_current: pass
	while not _interrupts[index]: pass
	return _interrupts[index]
