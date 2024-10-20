extends Timer

var cheese_scene = preload("res://objects/cheese.tscn")

func _ready():
	wait_time = 0.3  # Set wait time to 0.8 seconds
	start()  # Start the timer immediately

func _on_timeout():
	var new_cheese = cheese_scene.instantiate()  # Instantiate a new cheese instance
	new_cheese.global_transform.origin = Vector3(0, 6.064, 0)  # Set the position
	get_parent().add_child(new_cheese)  # Add cheese as a child of the parent node
