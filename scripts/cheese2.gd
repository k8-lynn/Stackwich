extends MeshInstance3D

const initial_slow_speed = 5.0
const acceleration_speed = 20.0

func _ready():
	# Apply initial slow fall
	$CheeseBody.apply_impulse(Vector3.DOWN * initial_slow_speed, Vector3.ZERO)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Speed up the cheese on left mouse button click
		$CheeseBody.apply_impulse(Vector3.DOWN * acceleration_speed, Vector3.ZERO)

func _on_CheeseBody_body_entered(body):
	if body.name == "bread":
		# Handle collision with bread
		queue_free()  # Destroy the cheese when it collides with bread
