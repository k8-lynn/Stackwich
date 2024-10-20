extends HBoxContainer

var cheese_icon = preload("res://prettiness/cheese_icon.png")
var lettuce_icon = preload("res://prettiness/lettuce_icon.png")

var generated_sequence = []  # To store the sequence of ingredient types
var icon_nodes = []  # To store the TextureRect nodes for easy access
@export var initial_move_speed = 20.0  # Initial speed at which the container moves to the left
@export var max_move_speed = 100.0  # Maximum speed at which the container moves to the left
@export var speed_increase_rate = 15.0  # The rate at which the move speed increases per second

var current_move_speed: float
var initial_position: Vector2  # To store the initial position of the container

# Variable to track the delay time
var delay_time: float = 4.0
var elapsed_time: float = 0.0
var is_delayed: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()  # Ensure randomness is initialized
	assign_random_icons()
	set_process(true)  # Enable processing
	initial_position = position  # Store the initial position
	current_move_speed = initial_move_speed

func assign_random_icons():
	# Clear existing TextureRect nodes
	for child in get_children():
		remove_child(child)
		child.queue_free()

	# Clear the generated sequence and icon nodes
	generated_sequence.clear()
	icon_nodes.clear()
	
	# Define the number of ingredients 
	var num_ingredients = randi() % 3 + 17
	
	var icons = [cheese_icon, lettuce_icon]
	for i in range(num_ingredients):
		var texture_rect = TextureRect.new()
		var random_icon = icons[randi() % icons.size()]
		texture_rect.texture = random_icon
		
		add_child(texture_rect)
		icon_nodes.append(texture_rect)
		
		if random_icon == cheese_icon:
			generated_sequence.append("cheese")
		else:
			generated_sequence.append("lettuce")

	print("Generated sequence: ", generated_sequence)

func _process(delta):
	if is_delayed:
		elapsed_time += delta
		if elapsed_time >= delay_time:
			is_delayed = false
	else:
		move_left(delta)
		remove_out_of_screen()
		increase_move_speed(delta)

func move_left(delta):
	# Ensure consistent movement speed
	var move_amount = current_move_speed * delta
	position.x -= move_amount

func increase_move_speed(delta):
	current_move_speed = min(current_move_speed + speed_increase_rate * delta, max_move_speed)

func remove_out_of_screen():
	var screen_left = -size.x  # Adjust if needed
	for child in get_children():
		if child is TextureRect and child.global_position.x + child.size.x < screen_left:
			remove_child(child)
			child.queue_free()

func reset_position():
	position = initial_position
	current_move_speed = initial_move_speed

func darken_icon(index):
	if index >= 0 and index < icon_nodes.size():
		var icon = icon_nodes[index]
		if is_instance_valid(icon):
			var original_color = icon.modulate
			icon.modulate = original_color.darkened(0.3)

