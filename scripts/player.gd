extends CharacterBody3D

var move_direction: Vector3
var move_direction_time: float

@export var move_speed = 2.0

# The player has to face in a direction this long before they start moving
@export var move_time_delay:float = 0.5

var health = 100
var main_ui: Control
var stamina = 100
var stamina_freeze_time = 0
var player_manager_ref

var hit_offset_vec: Vector3
const hit_offset_vec_initial_magnitude = 2
const hit_offset_vec_decrease_rate = 0.5

# The "id" of this player (0-3).  This corresponds to the gamepad ID (0 for
# keyboard) as well as what input messages this player looks for (ex. "left2")
# This value is set by the set_player_id method here and this method is called
# from the player_manager script
var player_id = null

# If this is ever set to non-null, it indicates that the player should have this material
# set as their main material (it will then be set to null)
var desired_material:StandardMaterial3D = null

func _ready():
	move_direction = Vector3(0, 0, 0)
	
	main_ui = get_tree().root.get_node("world_root/main_ui")
	
func _process(delta):
	if $shield.monitoring:
		stamina -= 20 * delta
		if stamina < 0:
			stamina = 0
			stamina_freeze_time = 3.0
			set_shield_state(false)
	elif stamina_freeze_time <= 0:
		stamina += 5 * delta
		if stamina > 100:
			stamina = 100
	else:
		stamina_freeze_time -= delta
	main_ui.set_player_stamina(player_id, stamina)
	
	# See if we need to update our material
	if desired_material != null:
		set_material(desired_material)
		desired_material = null
		
	# Check for input events (assuming the player_id has been set)
	if player_id != null:
		var vvector = Input.get_vector("left" + str(player_id) , 
									   "right" + str(player_id), 
									   "up" + str(player_id), 
									   "down" + str(player_id))
		set_direction(Vector3(vvector.x, 0, vvector.y), delta)
		
		for subtype in ["a", "b", "c", "d", "e", "f"]:
			if Input.is_action_just_pressed("fire" + str(player_id) + subtype):
				fire(subtype)

func _physics_process(delta):
	move_and_slide()


func fire(attack_name):
	if attack_name == "a":
		# Basic bullet
		var new_bullet = SceneManager.basic_bullet.instantiate()
		add_child(new_bullet)
		new_bullet.global_position = $player_collider/fire_port.global_position
		new_bullet.global_rotation = $player_collider/fire_port.global_rotation
		var my_mat = $player_collider/player_mesh.get_surface_override_material(0)
		new_bullet.get_node("bullet_collider/bullet_mesh").set_surface_override_material(0, my_mat)
	if attack_name == "c":
		set_shield_state(not $shield.monitoring)
		
func set_shield_state(state):
	if stamina_freeze_time > 0:
		state = false
		
	$shield.monitoring = state
	$shield/sheild_collider/shield_mesh.visible = state
	
			


func set_player_id(id):
	player_id = id

func set_material(mat):
	$player_collider/player_mesh.set_surface_override_material(0, mat)
	$spotlight.light_color = mat.albedo_color
	
	
	
func set_direction(v, delta):
	#print("v = " + str(v))
	
	# Pessimistically set the velocity to zero
	velocity = Vector3(0, 0, 0)
	
	# Adjust the hit_offset vector
	if hit_offset_vec.length_squared() > 0:
		var old_hit_offset_vec = hit_offset_vec
		hit_offset_vec += -(hit_offset_vec_decrease_rate * delta) * (hit_offset_vec.normalized())
		if hit_offset_vec.dot(old_hit_offset_vec) < 0:
			hit_offset_vec = Vector3(0, 0, 0)
	
	# if there is any indication of movement, adjust aim angle, even if we don't actually move
	if v.dot(v) > 0:
		# The player is indicating a direction -- make them face that way
		var angle = atan2(-v.z, v.x)
		$player_collider.rotation = Vector3(0, angle, 0)
		
		# The user must indicate movement for move_time_delay seconds before they actually start moving.
		# Once in motion, however, they can change directions any time they wish
		if move_direction_time >= move_time_delay:
			# The player should move in the direction they're facing
			velocity = v.normalized() * move_speed + hit_offset_vec
		else:
			# The player's waiting -- just adjust time
			move_direction_time += delta
	else:
		# The player's not indicating a direction of movement -- reset the timer
		move_direction_time = 0
			
	
	# Now, see if the player has been facing this direction long enough to warrant a move
	#velocity = Vector3(0, 0, 0)
	#if v == move_direction:
	#	if move_direction_time < move_time_delay:
			# The player is still moving in the new direction -- increment the timer
			
			# If this is now long enough, make it the 
	#	else:
			# The player has been facing long enough -- move them
			
	#else:
		# This is a new direction -- set it and reset the timer
	#	move_direction = v
	#	move_direction_time = 0.0
		
func take_damage(amt, hit_pt):
	health -= amt
	if health <= 0:
		if player_manager_ref.player_lost_life(player_id):
			health = 100
	else:
		hit_offset_vec = global_position - hit_pt
		var hit_offset_vec_mag = hit_offset_vec.length()
		if hit_offset_vec_mag > 0:
			hit_offset_vec = hit_offset_vec_initial_magnitude * (hit_offset_vec / hit_offset_vec_mag)
		
		main_ui.set_player_health(player_id, health)
		$AudioStreamPlayer3D.play()
	
		


func _on_shield_area_entered(area):
	print("shield hit by" + str(area))
	if area.is_in_group("bullet"):
		print("shield hit!")
		area.queue_free()
