extends Area3D

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))
	connect("area_exited", Callable(self, "_on_area_exited"))

func _on_area_entered(area):
	var collider = area.get_collider()
	if collider and collider is RigidBody3D:
		print("Colliding with:", collider.name)

func _on_area_exited(area):
	var collider = area.get_collider()
	if collider and collider is RigidBody3D:
		print("Exited collision with:", collider.name)
