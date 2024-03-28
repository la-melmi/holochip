extends AudioStreamPlayer

@export var control_unit: CHIPDecoder

#@onready var sample_hz: float = stream.mix_rate
#@export var pulse_hz: float = 440.0
#
#var playback: AudioStreamGeneratorPlayback
#
#func _ready() -> void:
	#play()
	#fill_buffer()
#
#func fill_buffer() -> void:
	#playback = get_stream_playback()
	#var phase := 0.0
	#var increment := pulse_hz / sample_hz
	#var frames_available := playback.get_frames_available()
	#
	#for i in range(frames_available):
		#playback.push_frame(Vector2.ONE * sin(phase * TAU))
		#phase = fmod(phase + increment, 1.0)

func _process(_delta) -> void:
	control_unit.mutex.lock()
	var ST := control_unit.ST
	control_unit.mutex.unlock()
	if ST > 0:
		play()
		#fill_buffer()
	else:
		stop()
