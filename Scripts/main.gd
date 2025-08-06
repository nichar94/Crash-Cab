extends Node2D

# Reference to the timer and label nodes
@onready var timer = $CountdownTimer
@onready var timer_label = $CanvasLayer/TimerLabel  # Adjust if CanvasLayer has a different name
@onready var score_label = $Control/ScoreLabel  # Add reference to score label

# Variable to track remaining time
var time_left = 60
var score = 0  # Add score variable

func _ready():
	# Reset score to 0 when entering the scene
	score = 0
	update_score_display()
	
	# Debug: Check if timer exists
	if timer == null:
		print("ERROR: Timer node not found! Check the node path.")
		return
	
	if timer_label == null:
		print("ERROR: Timer label not found! Check the node path.")
	
	# Connect the timer signal
	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)
		print("Timer signal connected successfully")
	else:
		print("Timer signal was already connected")
	
	# Set up the timer
	timer.wait_time = 1.0  # 1-second interval
	timer.one_shot = false  # Repeat timer
	timer.start()  # Start the timer
	print("Timer started with wait_time: ", timer.wait_time)
	
	# Update the label initially
	update_timer_label()

func _process(_delta):
	# Update label every frame for smooth display
	update_timer_label()

func _on_timer_timeout():
	print("Timer timeout called, time_left: ", time_left)  # Debug line
	# Called every second when timer ticks
	time_left -= 1
	# Check if time is up
	if time_left <= 0:
		if timer != null:
			timer.stop()  # Stop timer to prevent negative time
		get_tree().change_scene_to_file("res://Scenes/DeathScreen.tscn")
	else:
		# Only update label if time isn't up
		update_timer_label()

func update_timer_label():
	# Update the label to show current time (with null check)
	if timer_label != null:
		timer_label.text = "TIME: " + str(time_left)

func update_score_display():
	# Update the score label (with null check)
	if score_label != null:
		score_label.text = "SCORE: " + str(score)
