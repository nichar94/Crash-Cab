extends Node2D

# Reference to the timer and label nodes
@onready var timer = $countdownTimer
@onready var timer_label = $canvasLayer/TimerLabel  # Adjust if CanvasLayer has a different name

# Variable to track remaining time
var time_left = 60

func _ready():
	# Connect the timer signal if not connected in editor
	if not timer.timeout.is_connected(_on_timer_timeout):
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
	print("Timer timeout called, time_left: ", time_left)  # Debug line
	# Called every second when timer ticks
	time_left -= 1
	# Check if time is up
	if time_left <= 0:
		timer.stop()  # Stop timer to prevent negative time
		get_tree().change_scene_to_file("res://Scenes/DeathScreen.tscn")
	else:
		# Only update label if time isn't up
		update_timer_label()

func update_timer_label():
	# Update the label to show current time
	timer_label.text = "TIME: " + str(time_left)
