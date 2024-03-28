class_name Interrupt
extends RefCounted

var _mutex: Mutex
var _semaphore: Semaphore

var msg: Variant

func _init() -> void:
	_mutex = Mutex.new()
	_semaphore = Semaphore.new()


func send(_msg: Variant) -> void:
	_semaphore.try_wait()
	
	_mutex.lock()
	msg = _msg
	_mutex.unlock()
	
	_semaphore.post()

func poll() -> Variant:
	var active: bool = _semaphore.try_wait()
	
	if active:
		_semaphore.post()
		return msg
	
	return null


func clear() -> bool:
	return _semaphore.try_wait()

func wait() -> Variant:
	_semaphore.wait()
	
	_mutex.lock()
	var _msg = msg
	_mutex.unlock()
	
	return _msg
