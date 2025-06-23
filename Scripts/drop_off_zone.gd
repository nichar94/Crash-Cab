extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)
	$SuccessLabel.hide()
	$SuccessTimer.timeout.connect(_on_success_timer_timeout)
	print("DropOffZone ready, signals connected") # Debug

func _on_body_entered(body):
	if body.is_in_group("Car"):
		print("Car entered DropOffZone, has_passenger: ", body.has_passenger) # Debug
		if body.has_passenger:
			body.drop_off_passenger()
			$SuccessLabel.show()
			$SuccessTimer.start()
			print("Drop-off successful, showing Success!") # Debug
		else:
			print("No passenger in car") # Debug

func _on_success_timer_timeout():
	$SuccessLabel.hide()
	print("Success message hidden after 2 seconds") # Debug
