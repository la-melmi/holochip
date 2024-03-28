class_name InterruptController
extends Node

var mutex := Mutex.new()

var _interrupts: Array[Interrupt]

func interrupt(index: int, msg: Variant = true) -> void:
	mutex.lock()
	_interrupts[index].send(msg)
	mutex.unlock()

func acknowledge() -> void:
	mutex.lock()
	for i in _interrupts.size():
		_interrupts[i].clear()
	mutex.unlock()

func poll_interrupt(index: int) -> Variant:
	mutex.lock()
	var state = _interrupts[index].poll()
	mutex.unlock()
	return state

func poll_all_interrupts() -> Array[Variant]:
	var states = []
	mutex.lock()
	for flag in _interrupts:
		states.append(flag.poll())
	mutex.unlock()
	return states

func wait_for(index: int) -> Variant:
	return _interrupts[index].wait()


func create_interrupts(num: int) -> void:
	_interrupts = []
	
	for i in num:
		_interrupts.append( Interrupt.new() )
