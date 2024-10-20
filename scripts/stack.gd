extends Node3D

@onready var cheese_scene: PackedScene = preload("res://objects/cheese.tscn")
@onready var lettuce_scene: PackedScene = preload("res://objects/lettuce.tscn")
@onready var spawn_timer = $Timer
@onready var hbox_container: HBoxContainer = $CanvasLayer/order/HBoxContainer  # Reference to the HBoxContainer node
@onready var won_label = $CanvasLayer/won  # Reference to the won label
@onready var restart_timer = $CanvasLayer/won/restart  # Reference to the Timer node 

# Hearts
@onready var heart = $CanvasLayer/hearts/heart
@onready var heart_2 = $CanvasLayer/hearts/heart2
@onready var heart_3 = $CanvasLayer/hearts/heart3
# Reference to the game over label
@onready var game_over = $"CanvasLayer/game over"

# Top bread object
@onready var bread_scene: PackedScene = preload("res://objects/bread_top.tscn")
var bread_instance: Node3D = null
var bread_target_position: Vector3
var bread_spawned = false

#particles
@onready var sparkles = $CanvasLayer/sparkles
@onready var sparkle_timer = $CanvasLayer/sparkles/Timer

#countdown text
@onready var countdown = $CanvasLayer/countdown
@onready var animation = $CanvasLayer/countdown/animation

var ingredients = []
var cheese_queue = []
var cheese_click_index: int = 0
var fall_index: int = 0  # Index for tracking fallen ingredients
var player_sequence = []  # To store the sequence of ingredient types landed by the player
var hearts_left: int = 3  # Number of tries (hearts) the player has left

# Variables for swipe detection
var is_swiping: bool = false
var start_position: Vector2 = Vector2.ZERO
var swipe_threshold: float = 50  # Adjust this threshold as needed

func _ready():
	won_label.visible = false
	game_over.visible = false
	sparkles.visible = false
	spawn_timer.stop()
	ingredients = [cheese_scene, lettuce_scene]
	spawn_timer.connect("timeout", Callable(self, "_spawn_ingredient"))

	restart_timer.connect("timeout", Callable(self, "_on_restart_timeout"))
	restart_timer.wait_time = 3  # Set timer to 4 seconds
	set_process(true)  # Enable the _process function
	
	# Show countdown and play animation
	countdown.visible = true
	animation.play("countdown")  # Ensure "countdown_animation" is the name of your animation
	
	await(get_tree().create_timer(4)).timeout
	
	# Hide countdown after animation and start the game
	countdown.visible = false
	spawn_timer.start()

func _spawn_ingredient():
	var ingredient_scene: PackedScene = ingredients[randi() % ingredients.size()]
	var ingredient_instance: Node = ingredient_scene.instantiate()
	ingredient_instance.global_transform.origin = Vector3(0, 9.06, 0)
	add_child(ingredient_instance)
	if ingredient_instance == cheese_scene.instantiate():
		ingredient_instance.ingredient_type = "cheese"
	elif ingredient_instance == lettuce_scene.instantiate():
		ingredient_instance.ingredient_type = "lettuce"
	print("Spawned ingredient: ", ingredient_instance.ingredient_type)
	
	if ingredient_instance.has_method("set_queue_index"):
		ingredient_instance.set_queue_index(cheese_queue.size())
		cheese_queue.append(ingredient_instance)
	ingredient_instance.connect("ingredient_landed", Callable(self, "_on_ingredient_landed"))

func _input(event):
	# Check if the ingredient at the current index is still valid before accessing its properties
	while cheese_click_index < cheese_queue.size():
		var ingredient = cheese_queue[cheese_click_index]
		if not is_instance_valid(ingredient):
			cheese_queue.remove_at(cheese_click_index)  # Remove invalid (freed) ingredient from the queue
		elif ingredient.has_collided:
			cheese_click_index += 1
		else:
			break
	
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				# Start of a potential swipe or click
				is_swiping = true
				start_position = mouse_event.position
			else:
				# End of a potential swipe or click
				is_swiping = false
				var end_position = mouse_event.position
				var distance = end_position.distance_to(start_position)

				if distance < swipe_threshold:
					# Treat as a single click
					if cheese_click_index < cheese_queue.size():
						cheese_queue[cheese_click_index].speed_up()
						cheese_click_index += 1
						print("Clicked ingredient to fall")


	elif event is InputEventMouseMotion and is_swiping:
		var motion_event = event as InputEventMouseMotion
		var current_position = motion_event.position
		var distance = current_position.x - start_position.x

		# Detect a right swipe
		if distance > swipe_threshold:  # Adjust the threshold as needed
			is_swiping = false
			if cheese_click_index < cheese_queue.size():
				var ingredient = cheese_queue[cheese_click_index]
				ingredient.move_right()
				ingredient.disable_collider()  # Disable the collider
				ingredient.disable_area_3d()
				cheese_click_index += 1
				print("Swiped ingredient to the right")

		# Detect a left swipe
		elif distance < -swipe_threshold:  # Adjust the threshold as needed
			is_swiping = false
			if cheese_click_index < cheese_queue.size():
				var ingredient = cheese_queue[cheese_click_index]
				ingredient.move_left()
				ingredient.disable_collider()  # Disable the collider
				ingredient.disable_area_3d()
				cheese_click_index += 1
				print("Swiped ingredient to the left")



func calculate_stack_height() -> float:
	# Ingredient heights
	var ingredient_heights = {
		"cheese": 0.11,
		"lettuce": 0.32
	}
	
	var total_height: float = 0.0
	for ingredient in player_sequence:
		total_height += ingredient_heights.get(ingredient, 0)
	return total_height

func _on_ingredient_landed(ingredient):
	# Check if the landed ingredient matches the generated sequence
	if fall_index < hbox_container.generated_sequence.size():
		if ingredient.ingredient_type == hbox_container.generated_sequence[fall_index]:
			print("Correct")
			player_sequence.append(ingredient.ingredient_type)
			hbox_container.darken_icon(fall_index)  # Darken the correct icon
			fall_index += 1
			
			# Show particles for 2 seconds
			sparkles.visible = true
			sparkles.emitting = true
			sparkle_timer.start()
		else:
			print("Wrong")
			_lose_heart()
			ingredient.queue_free()  # Remove the incorrect ingredient

	# Inside your condition when the player wins
	if player_sequence.size() == hbox_container.generated_sequence.size():
		if player_sequence == hbox_container.generated_sequence:
			print("Player won!")
			spawn_timer.stop()
			_clear_unlanded_ingredients()  # Remove all unlanded ingredients
			won_label.visible = true

			if bread_spawned:
				bread_instance.queue_free()  # Ensure any existing bread instance is cleared

			bread_instance = bread_scene.instantiate()

			# Calculate the height based on the ingredient stack
			var stack_height = calculate_stack_height()

			# Set the initial bread position above the stack
			bread_instance.global_transform.origin = Vector3(0, stack_height + 9, 0)  # Adjusted to start above the stack

			# Determine compression based on stack height (or number of ingredients)
			var compression_factor: float = 0.1  # Base compression factor for small stacks

			if player_sequence.size() >= 10:  # Increase compression for larger stacks
				compression_factor = 0.23
			elif player_sequence.size() >= 5:  # Medium compression for medium-sized stacks
				compression_factor = 0.15
			
			# Calculate the compression amount
			var compression_amount = stack_height * compression_factor
			bread_target_position = Vector3(0, stack_height - compression_amount, 0)

			add_child(bread_instance)
			bread_spawned = true
			restart_timer.start()  # Start the timer for 4 seconds




func _clear_unlanded_ingredients():
	var valid_cheese_queue = []
	for i in range(cheese_queue.size() - 1, -1, -1):
		var ingredient = cheese_queue[i]
		if is_instance_valid(ingredient):
			if not ingredient.has_collided:  # Assuming there is a flag or method to check collision
				ingredient.queue_free()
			else:
				valid_cheese_queue.append(ingredient)
	cheese_queue = valid_cheese_queue

func _process(delta):
	if bread_instance:
		var direction = bread_target_position - bread_instance.global_transform.origin
		var distance = direction.length()
		var move_step = direction.normalized() * 5 * delta  # Adjust the speed as needed

		if distance > move_step.length():
			bread_instance.global_transform.origin += move_step
		else:
			bread_instance.global_transform.origin = bread_target_position
	if sparkles.emitting and sparkle_timer.time_left == 0:
		sparkles.emitting = false
		sparkles.visible = false

func _lose_heart():
	hearts_left -= 1
	if hearts_left == 2:
		heart_3.visible = false
	elif hearts_left == 1:
		heart_2.visible = false
	elif hearts_left == 0:
		heart.visible = false
		_game_over()

func _game_over():
	print("Game Over")
	game_over.visible = true
	restart_timer.start()  # Start the timer for 4 seconds to restart the game

func _on_restart_timeout():
	restart_timer.stop()  # Stop the timer to prevent it from running again
	_on_button_pressed()  # Call the button pressed function to restart the game

func _on_button_pressed():
	won_label.visible = false
	game_over.visible = false

	# Stop the timer to prevent new ingredients from spawning during restart
	spawn_timer.stop()
	hbox_container.reset_position()

	# Reset the delay time and state
	hbox_container.elapsed_time = 0.0
	hbox_container.is_delayed = true

	# Remove all existing ingredients safely
	for i in range(cheese_queue.size() - 1, -1, -1):
		var ingredient = cheese_queue[i]
		if is_instance_valid(ingredient):
			ingredient.queue_free()

	# Clear the hbox_container children
	for child in hbox_container.get_children():
		if is_instance_valid(child):
			child.queue_free()

	# Clear the queue and reset the click index and fall index
	cheese_queue.clear()
	cheese_click_index = 0
	fall_index = 0
	player_sequence.clear()

	# Reset hearts
	hearts_left = 3
	heart.visible = true
	heart_2.visible = true
	heart_3.visible = true

	# Remove the bread instance if it exists
	if bread_instance and is_instance_valid(bread_instance):
		bread_instance.queue_free()
		bread_instance = null

	# Reset bread_target_position and bread_spawned flag
	bread_target_position = Vector3.ZERO
	bread_spawned = false

	# Stop any ongoing timer to ensure the game doesn't restart again unintentionally
	restart_timer.stop()

	# Generate a new sequence of icons
	hbox_container.assign_random_icons()

	# Show countdown and restart the animation from the beginning
	countdown.visible = true
	animation.stop()  # Ensure the animation stops before restarting
	animation.play("countdown")  # Ensure "countdown_animation" is the name of your animation

	await(get_tree().create_timer(4)).timeout

	# Hide countdown after animation and start the game
	countdown.visible = false
	spawn_timer.start()

	print("Game restarted")
