class_name Clock
extends Node


## Clock speed in Hz
@export var clockspeed: float:
	set(speed):
		clockspeed = speed
		_tick_interval = int(1000000.0 / speed)

@export var paused: bool = false

var _tick_interval: int
var _timer_interval := int(1000000.0 / 60.0)

var callbacks: Array[Callable]
var timer_callbacks: Array[Callable]
var running: bool

var thread: Thread

func _ready() -> void:
	clockspeed = clockspeed

func _exit_tree() -> void:
	stop()


func stop() -> void:
	running = false
	if thread: thread.wait_to_finish()

func start() -> void:
	if thread: stop()
	
	thread = Thread.new()
	thread.start(loop)


func loop() -> void:
	running = true
	
	var last: int = 0
	var last_tick: int = 0
	
	while running:
		if paused: continue
		
		var time := Time.get_ticks_usec()
		if time == last: continue
		
		if time % _timer_interval == 0:
			for callback in timer_callbacks:
				callback.call()
		
		if time % _tick_interval == 0:
			if time - last_tick != _tick_interval:
				var time_loss := time - last_tick
				if time_loss >= 1000:
					push_warning("Time loss of %d usec!" % time_loss)
			last_tick = time
			
			for callback in callbacks:
				callback.call()
		
		last = time
