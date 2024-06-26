class_name Clock
extends Node

## Clock speed in Hz
@export var clockspeed: float:
	set(speed):
		clockspeed = speed
		_tick_interval = int(1000000.0 / speed)
		_cycles_per_frame = int(speed / 60.0)

@export var paused: bool = false

@export var interrupt_controller: InterruptController

## Track whether the clock is currently running. If this is set to false, thread will finish
## after next clock tick.
var running: bool

## The duration of a single tick in microseconds
var _tick_interval: int

## Number of cycles that should occur between frame refreshes
var _cycles_per_frame: int

## Cycles that have elapsed since the last frame refresh
var _cycles_elapsed: int

## The time in usec that the last clock tick occured at
var _last_tick: int

## The thread [method loop] runs in
var thread: Thread

## Semaphore representing requests for clock cycles to be processed
var semaphore: Semaphore

## Because signals don't work in threads, we use this array of Callables. These callbacks
## are called at the rate determined by [member clockspeed]
var clock_pulse: Array[Callable]

## Because signals don't work in threads, we use this array of Callables. These callbacks
## are called at 60 Hz.
var timer_pulse: Array[Callable]

## When set to true, will step a single tick forward and then be set false.
var step: bool

## When set to true, will step until a timer tick occurs and then be set false.
var frame_step: bool

func _ready() -> void:
	clockspeed = clockspeed

func _process(_delta) -> void:
	if running:
		var time := Time.get_ticks_usec()
		
		if paused:
			# If we're paused, don't count intervening time
			_last_tick = time
			return
		
		while (time - _last_tick) >= _tick_interval:
			_last_tick += _tick_interval
			#semaphore.post()
			await tick()


## Start a thread to handle [method loop]
func start() -> void:	
	# Reset the clock
	_last_tick = Time.get_ticks_usec()
	await get_tree().process_frame
	running = true

## Handle stopping and cleaning up the loop worker thread
func stop() -> void:
	running = false

## Progress the clock by one cycle. Returns true if this was a refresh tick.
func tick() -> bool:
	_cycles_elapsed += 1
	_cycles_elapsed %= _cycles_per_frame
	
	var refresh := (_cycles_elapsed == 0)
	
	if refresh:
		for callback in timer_pulse:
			await callback.call()
	
	for callback in clock_pulse:
		await callback.call()
	
	interrupt_controller.acknowledge()
	
	return refresh
