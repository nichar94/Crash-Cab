extends Node2D

@onready var sprite = $Sprite2D
var target_position: Vector2
var offset_distance: float = 60.0  # Distance from player center

func _ready():
	# Make sure the arrow is visible
	modulate = Color.WHITE

func update_target(target_pos: Vector2):
	target_position = target_pos
	
func _process(delta):
	if target_position != Vector2.ZERO:
		# Calculate direction to target
		var direction = (target_position - global_position).normalized()
		
		# Rotate arrow to point toward target
		rotation = direction.angle()
		
		# Position arrow at offset distance from player
		global_position = get_parent().global_position + (direction * offset_distance)

func show_arrow():
	visible = true
	
func hide_arrow():
	visible = false
