class_name Clock
extends Node

enum Mode {
	IDLE,
	THREAD,
	PHYSICS,
}

## Clock speed in Hz
@export var clockspeed: float:
	set(speed):
		clockspeed = speed
		_tick_interval = int(1000000.0 / speed)
		_cycles_per_frame = int(speed / 60.0)

@export var running_mode: Mode

@export var paused: bool = false

@export var log_time_loss: bool

@export var interrupt_controller: InterruptController

var _cycles_per_frame: int

var _tick_interval: int
var _timer_interval := int(1000000.0 / 60.0)

var callbacks: Array[Callable]
var timer_callbacks: Array[Callable]
var running: bool
var step: bool

var frame_step: int

var drawn: bool

var thread: Thread

func _ready() -> void:
	clockspeed = clockspeed

func _exit_tree() -> void:
	stop()

func _input(event) -> void:
	if event.is_action_pressed("step"):
		step = true
	if event.is_action_pressed("pause"):
		paused = not paused
	if event.is_action_pressed("frame_step"):
		frame_step = 2
		print("woop")


func stop() -> void:
	running = false
	if thread:
		if thread.is_alive(): thread.wait_to_finish()

func start() -> void:
	if running_mode == Mode.THREAD:
		if thread: stop()
		
		thread = Thread.new()
		thread.start(loop)
	else:
		running = true


var last_tick: int = 0
var last_timer_tick: int = 0

func loop() -> void:
	running = true
	
	var last: int = 0
	
	while running:
		if not drawn: continue
		if paused and not (step or frame_step): continue
		
		var time := Time.get_ticks_usec()
		if time == last: continue
		
		if (time - last_timer_tick) >= _timer_interval:
			last_timer_tick = time
			for callback in timer_callbacks:
				callback.call()
		
		var time_diff := time - last_tick
		if time_diff >= _tick_interval:
			if log_time_loss and time_diff != _tick_interval:
				var time_loss := time_diff - _tick_interval
				if time_loss > 1000 and clockspeed != 0:
					push_warning("Time loss of %d usec!" % time_loss)
				elif time_loss < -1000 and clockspeed != 0:
					push_warning("Time gain of %d usec!" % -time_loss)
			last_tick = time
			
			for callback in callbacks:
				callback.call()
			
			interrupt_controller.acknowledge()
		
		last = time
		step = false

func _physics_process(_delta) -> void:
	if drawn and running and running_mode == Mode.PHYSICS and not paused:
		for callback in timer_callbacks:
			await callback.call()
		
		for i in _cycles_per_frame:
			for callback in callbacks:
				await callback.call()
			interrupt_controller.acknowledge()

func _process(_delta) -> void:
	if drawn and running and running_mode == Mode.IDLE:
		var time := Time.get_ticks_usec()
		
		if paused and not (step or frame_step):
			last_tick = time
			last_timer_tick = time
			return
		
		while (time - last_timer_tick) >= _timer_interval:
			last_timer_tick += _timer_interval
			for callback in timer_callbacks:
				await callback.call()
			if step: break
		
		while (time - last_tick) >= _tick_interval:
			if (time - last_timer_tick) >= _timer_interval:
				last_timer_tick += _timer_interval
				for callback in timer_callbacks:
					await callback.call()
			
			last_tick += _tick_interval
			for callback in callbacks:
				await callback.call()
			
			interrupt_controller.acknowledge()
			
			if step: break
		
		step = false
		if frame_step == 2: frame_step = 1

func _on_display_resized() -> void:
	drawn = true

func _on_display_refreshed():
	if frame_step == 1:
		frame_step = 0
