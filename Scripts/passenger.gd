extends CharacterBody2D

signal passenger_picked_up(passenger)

func _ready():
	# Connect the Area2D's body_entered and body_exited signals
	$Area2D.body_entered.connect(_on_area_2d_body_entered)
	$Area2D.body_exited.connect(_on_area_2d_body_exited)

func _on_area_2d_body_entered(body):
	if body.is_in_group("Car"):
		body.can_pickup_passenger = true
		body.nearby_passenger = self
		print("PASSENGER: Car can now pickup passenger")

func _on_area_2d_body_exited(body):
	if body.is_in_group("Car"):
		body.can_pickup_passenger = false
		body.nearby_passenger = null
		print("PASSENGER: Car left pickup area")

func pickup():
	emit_signal("passenger_picked_up", self)
	queue_free() # Remove passenger from scene after pickup
