extends RigidBody3D

@export var ingredient_type = "" # Will be set to "cheese" or "lettuce"
@export var initial_fall_speed = 1.5 # Initial fall speed
@export var max_fall_speed = 150.0 # Maximum fall speed
@export var speed_increase_rate = 1.5 # The rate at which the fall speed increases per second
@export var swipe_speed = 10.0
@export var boosted_speed = 13.0
var current_fall_speed: float
var is_boosted = false
var queue_index: int = -1
@onready var collision_shape_3d = $CollisionShape3D
@onready var area_3d = $Area3D  # Assuming Area3D is a child node
var has_collided = false

signal ingredient_landed(ingredient)

func _ready():
	set_gravity_scale(0)
	current_fall_speed = initial_fall_speed
	set_process(true)

func _integrate_forces(state):
	var velocity = state.get_linear_velocity()
	if !is_boosted:
		velocity.y = -current_fall_speed
	else:
		velocity.y = -boosted_speed
	state.set_linear_velocity(velocity)

	if global_transform.origin.y < -10:
		queue_free()

func _process(delta):
	if !is_boosted:
		current_fall_speed = min(current_fall_speed + speed_increase_rate * delta, max_fall_speed)

func speed_up():
	is_boosted = true

func set_queue_index(index):
	queue_index = index

func move_right():
	if !has_collided:
		var velocity = linear_velocity
		velocity.x = swipe_speed
		linear_velocity = velocity

func move_left():
	if !has_collided:
		var velocity = linear_velocity
		velocity.x = -swipe_speed
		linear_velocity = velocity

func disable_collider():
	if collision_shape_3d:
		collision_shape_3d.disabled = true
		
# Function to disable Area3D
func disable_area_3d():
	if area_3d:
		area_3d.monitoring = false  # Stop detecting overlaps
		area_3d.set_collision_layer(0)  # Disable the collision layer

func _on_area_3d_area_entered(area):
	if !has_collided:
		has_collided = true
		disable_collider()
		print("Collision detected with ingredient: ", ingredient_type)
		emit_signal("ingredient_landed", self)
