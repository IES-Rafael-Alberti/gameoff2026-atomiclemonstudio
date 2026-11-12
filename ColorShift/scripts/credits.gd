extends Control

func _ready() -> void:
	$CreditsTimer.start()


func _on_credits_timer_timeout() -> void:
	get_tree().quit()
