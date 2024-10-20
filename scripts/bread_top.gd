extends Node3D

@export var bread_type = "" # Set bread type (normal bread)
@export var fall_speed = 13.0
@export var target_y_position = 1.0  # Set the target y position for the bread to stop

var reached_target = false

func _ready():
	set_process(true)  # Enable the _process function

func _process(delta):
	if not reached_target:
		# Apply a downward movement to simulate falling until it reaches the target position
		if global_transform.origin.y > target_y_position:
			global_transform.origin.y -= fall_speed * delta
		else:
			# Set the position to the target and stop the movement
			global_transform.origin.y = target_y_position
			reached_target = true
