extends Area3D

const SPEED = 20.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	translate_object_local(Vector3(SPEED * delta, 0, 0))
