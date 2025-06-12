extends Node2D

# Reference to the Timer and Label nodes
@onready var timer = $CountdownTimer
@onready var timer_label = $CanvasLayer/TimerLabel  # Updated path to include CanvasLayer

# Variable to track remaining time
var time_left = 60

func _ready():
	# Start the timer with 1-second intervals
	timer.wait_time = 1.0
	timer.one_shot = false  # Ensure timer repeats
	timer.start()
	# Update the label to show the initial time
	update_timer_label()

func _process(_delta):
	# Update the label every frame to reflect timer's remaining time
	update_timer_label()
	
	# Check if time is up
	if time_left <= 0:
		# Go to the death screen
		get_tree().change_scene_to_file("res://DeathScreen.tscn")

func _on_CountdownTimer_timeout():
	# Called when the timer ticks
	time_left -= 1
	update_timer_label()

func update_timer_label():
	# Update the label to show the current time
	timer_label.text = "Time: " + str(time_left)
