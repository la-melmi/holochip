class_name Clock
extends Node


## Clock speed in Hz
@export var clockspeed: float:
	set(speed):
		clockspeed = speed
		_tick_interval = int(1000000.0 / speed)
		_cycles_per_frame = int(speed / 60.0)

@export var run_in_physics: bool

@export var paused: bool = false

@export var interrupt_controller: InterruptController

var _cycles_per_frame: int

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
	if thread:
		if thread.is_alive(): thread.wait_to_finish()

func start() -> void:
	if run_in_physics:
		running = true
	else:
		if thread: stop()
		
		thread = Thread.new()
		thread.start(loop)


func loop() -> void:
	running = true
	
	var last: int = 0
	var last_tick: int = 0
	var last_timer_tick: int = 0
	
	while running:
		if paused: continue
		
		var time := Time.get_ticks_usec()
		if time == last: continue
		
		if (time - last_timer_tick) >= _timer_interval:
			last_timer_tick = time
			for callback in timer_callbacks:
				await callback.call()
		
		var time_diff := time - last_tick
		if time_diff >= _tick_interval:
			if time_diff != _tick_interval:
				var time_loss := time_diff - _tick_interval
				if time_loss > 1000:
					push_warning("Time loss of %d usec!" % time_loss)
				elif time_loss < -1000:
					push_warning("Time gain of %d usec!" % -time_loss)
			last_tick = time
			
			for callback in callbacks:
				await callback.call()
			
			interrupt_controller.acknowledge()
		
		last = time


func _physics_process(_delta) -> void:
	if run_in_physics:
		for callback in timer_callbacks:
			await callback.call()
		
		for i in _cycles_per_frame:
			for callback in callbacks:
				callback.call()
			interrupt_controller.acknowledge()
