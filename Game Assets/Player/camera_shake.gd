extends Camera2D

var shake_amplitude = 10.0
var shake_duration = 0.5


func _process(_delta) -> void:
	if $ShakeTimer.is_stopped():
		position = Vector2(0,0)
	else:
		var random_offset = Vector2(
			randf_range(-shake_amplitude, shake_amplitude),
			randf_range(-shake_amplitude, shake_amplitude)
		)	 
		position += random_offset
func shake():
	$ShakeTimer.start(shake_duration)

func _on_shake_timer_timeout() -> void:
	position = Vector2(0,0)
