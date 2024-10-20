extends Node3D

@export var squish_force = 10.0  # The force applied to squish the sandwich

func _ready():
	# Optionally, you can hide the squish node if it should not be visible
	# visible = false
	pass

func apply_squish():
	# Apply squishing force to the ingredients
	for ingredient in get_tree().get_nodes_in_group("ingredients"):
		if is_instance_valid(ingredient):
			var body = ingredient as RigidBody3D
			if body:
				# Apply a downward force to squish the ingredient
				body.apply_central_impulse(Vector3(0, -squish_force, 0))
