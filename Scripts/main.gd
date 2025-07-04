extends Node2D

# Reference to the Timer and Label nodes
@onready var timer = $CountdownTimer
@onready var timer_label = $CanvasLayer/TimerLabel  # Adjust if CanvasLayer has a different name

# Variable to track remaining time
var time_left = 60

func _ready():
	# Connect the timer signal if not connected in editor
	if not timer.is_connected("timeout", _on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)
	# Set up the timer
	timer.wait_time = 1.0  # 1-second interval
	timer.one_shot = false  # Repeat timer
	timer.start()  # Start the timer
	# Update the label initially
	update_timer_label()

func _process(delta):
	# Update label every frame for smooth display
	update_timer_label()

func _on_timer_timeout():
	# Called every second when timer ticks
	time_left -= 1
	# Check if time is up
	if time_left <= 0:
		timer.stop()  # Stop timer to prevent negative time
		get_tree().change_scene_to_file("res://Scenes/DeathScreen.tscn")
	else:
		update_timer_label()  # Only update label if time isn't up

func update_timer_label():
	# Update the label to show current time
	timer_label.text = "Time: " + str(time_left)
