extends Area3D

const SPEED = 20.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	translate_object_local(Vector3(SPEED * delta, 0, 0))


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(5)
		print("hit")
		queue_free()
