extends RigidBody3D

# Constants
const INITIAL_GRAVITY = Vector3(0, -0.5, 0)  # Even slower initial gravity
const FAST_GRAVITY = Vector3(0, -20.0, 0)    # Fast gravity when clicked

var initialGravitySet = false  # Flag to track if initial gravity is set
var fastFall = false  # Flag to track if fast falling is enabled
var can_be_clicked = false  # Flag to track if this cheese can be clicked

signal cheese_fell  # Signal to notify when the cheese falls fast

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(false)  # Disable physics process until falling starts

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if initialGravitySet:
		if fastFall:
			# Apply fast gravity
			linear_velocity += FAST_GRAVITY * delta
		else:
			# Apply initial slow gravity
			linear_velocity += INITIAL_GRAVITY * delta

# Handle mouse input
func _input(event):
	if can_be_clicked and event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			if not initialGravitySet:
				set_initial_gravity()
			enable_fast_fall()

# Set initial slow falling speed
func set_initial_gravity():
	initialGravitySet = true
	set_physics_process(true)  # Enable physics process to update falling

# Enable fast falling speed
func enable_fast_fall():
	fastFall = true
	emit_signal("cheese_fell")  # Emit signal when the cheese falls fast
