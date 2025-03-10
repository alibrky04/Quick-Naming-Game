extends Panel

var minutes: int = 0
var seconds: int = 0

func _process(_delta: float) -> void:
	$Minutes.text = "Zaman: %02d:" % minutes
	$Seconds.text = "%02d" % (seconds % 60)
	
	if GameManager.lastItemGenerated == true:
		$SecondTimer.stop()
		$MinuteTimer.stop()

func _on_minute_timer_timeout() -> void:
	minutes += 1

func _on_second_timer_timeout() -> void:
	seconds += 1
