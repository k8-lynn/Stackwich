extends RayCast3D

var active_ingredients = []

func _ready():
	set_physics_process(true)
	print("RayCast3D ready")

func _physics_process(delta):
	if is_colliding():
		var collider = get_collider()
		if collider is RigidBody3D and collider.has_method("speed_up"):
			if !active_ingredients.has(collider):
				active_ingredients.append(collider)
				print("Ingredient added to active list:", collider.name)
			update_active_ingredient(collider)
			print("Colliding with:", collider.name)
	else:
		active_ingredients.clear()
		print("No collision detected")

func update_active_ingredient(collider):
	if is_closer(collider):
		print("Active ingredient updated to:", collider.name)

func is_closer(new_collider):
	if active_ingredients.size() == 0:
		return true

	var closest_distance = global_transform.origin.distance_to(active_ingredients[0].global_transform.origin)
	var new_distance = global_transform.origin.distance_to(new_collider.global_transform.origin)

	return new_distance < closest_distance


