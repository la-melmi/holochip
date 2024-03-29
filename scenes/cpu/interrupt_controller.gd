class_name InterruptController
extends Node

signal interrupt_sent(index: int)

@export var log_interrupts: bool

@export_group("Connected Nodes")
@export var clock: Clock

var mutex := Mutex.new()

var _interrupts: Array[Variant]

func interrupt(index: int, msg: Variant = true) -> void:
	mutex.lock()
	_interrupts[index] = msg
	interrupt_sent.emit(index)
	mutex.unlock()

func acknowledge() -> void:
	mutex.lock()
	for i in _interrupts.size():
		if log_interrupts and _interrupts[i]: print("Interrupt %d acknowledged." % i)
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
	if clock.running_mode == clock.Mode.THREAD:
		while _interrupts[index] and allow_current: pass
		while not _interrupts[index]: pass
		return _interrupts[index]
	
	else:
		var received: int = 0
		while received != index:
			received = await interrupt_sent
		return _interrupts[index]
