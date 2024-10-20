extends RigidBody3D

@export var bread_type = "" # set bread type (normal bread)
@export var fall_speed = 13.0

func _ready():
	# Disable default gravity to control fall manually
	gravity_scale = 0

func _integrate_forces(state):
	# Apply a downward force to simulate falling
	var gravity_force = Vector3(0, -fall_speed, 0)
	apply_central_force(gravity_force)
