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

func _process(delta):
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

# NEW FUNCTION: Add time bonus
func add_time(seconds):
	time_left += seconds
	print("Added ", seconds, " seconds. New time: ", time_left)
	update_timer_label()  # Update display immediately
	show_time_bonus(seconds)  # Show visual feedback

# NEW FUNCTION: Show time bonus visual feedback
func show_time_bonus(seconds):
	# Create a new label for the bonus display
	var bonus_label = Label.new()
	bonus_label.text = "+" + str(seconds)
	bonus_label.add_theme_color_override("font_color", Color.GREEN)
	
	# Load your custom font and set font size
	var font = load("res://Fonts/Kenney Future Narrow.ttf")  # Replace with your font path
	bonus_label.add_theme_font_override("font", font)
	bonus_label.add_theme_font_size_override("font_size", 40)  # Change size as needed
	
	# Add it to the same parent as the timer label
	if timer_label != null and timer_label.get_parent() != null:
		timer_label.get_parent().add_child(bonus_label)
		
		# Position it next to the timer (adjust these values based on your timer position)
		bonus_label.position = timer_label.position + Vector2(150, -20)  # 100 pixels to the right
		
		# Create a tween for animation
		var tween = create_tween()
		tween.set_parallel(true)  # Allow multiple animations
		
		# Animate upward movement and fade out
		tween.tween_property(bonus_label, "position", bonus_label.position + Vector2(0, -30), 1.5)
		tween.tween_property(bonus_label, "modulate:a", 0.0, 1.5)
		
		# Remove the label after animation
		tween.tween_callback(bonus_label.queue_free).set_delay(1.5)
