extends Node3D

var cheese = preload("res://objects/cheese.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("respawn"):
		destroy()
		respawn()


func destroy():
	if self.get_child_count() > 0:
		self.get_child(0).queue_free()
		
func respawn():
	var cheese_instance = cheese.instantiate()
	self.add_child(cheese_instance)
