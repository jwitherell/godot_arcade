extends CharacterBody3D

var move_direction: Vector3
var move_direction_time: float

@export var move_speed = 10.0

# The player has to face in a direction this long before they start moving
@export var move_time_delay:float = 0.5

# If this is ever set to non-null, it indicates that the player should have this material
# set as their main material (it will then be set to null)
var desired_material = null

func _start():
	move_direction = Vector3(0, 0, 0)

func _physics_process(delta):
	move_and_slide()

func set_material(mat):
	$player_collider/player_mesh.set_surface_override_material(0, mat)
	
	
func set_direction(v, delta):
	print("v = " + str(v))
	
	# if there is any indication of movement, adjust aim angle, even if we don't actually move
	if v.dot(v) > 0:
		var angle = rad_to_deg(atan2(v.y, v.x))
		$player_collider.rotation = Vector3(0, angle, 0)
	
	# Now, see if the player has been facing this direction long enough to warrant a move
	velocity = Vector3(0, 0, 0)
	if v == move_direction:
		if move_direction_time < move_time_delay:
			# The player is still moving in the new direction -- increment the timer
			move_direction_time += delta
			# If this is now long enough, make it the 
		else:
			# The player has been facing long enough -- move them
			velocity = v.normalized() * move_speed
	else:
		# This is a new direction -- set it and reset the timer
		move_direction = v
		move_direction_time = 0.0
		
func _process(delta):
	if desired_material != null:
		set_material(desired_material)
		desired_material = null
		
