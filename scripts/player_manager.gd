extends Node3D

# Keys are 0...3.  Values are the player instance for that player (or null if that player is not
#  in the game).  All player instances are children of this manager object in the scene tree
var player_mapping: Dictionary

## The scene to instantiate for all player objects
@export var player_scene:PackedScene

## An array of player materials to use for each player
@export var player_materials:Array[StandardMaterial3D]

## Called when the node enters the scene tree for the first time.
func _ready():
	# Connect ourselves to the Input signal that is emitted when a gamepad is plugged in / out
	Input.connect("joy_connection_changed", joy_connection_handler)
	
	

## Searches for a new spawn point, which is furthest from all active players
## in the current map
func get_spawn_point():
	pass


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if len(player_mapping) == 0:
		# We don't have a player object yet
		print("test")
		spawn_player_if_necessary(0)
	
	# Ideally, I would've done input bindings.  But dpad button events seem to 
	# only be generated for *all* devices.  This lets me distinguish which
	# defice generated it
	var vvectors = [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	var moved = false
	for i in player_mapping:
		var vvector = Vector2(Input.get_joy_axis(i, 0), Input.get_joy_axis(i, 1))
		print("joy" + str(i) + " = " + str(vvector))
		#player_mapping[i].set_direction(vvector, delta)
		"""var vvector = Vector2(0, 0)
		
		if Input.is_joy_button_pressed(i, JOY_BUTTON_DPAD_LEFT):
			vvector.x -= 1
			moved = true
		if Input.is_joy_button_pressed(i, JOY_BUTTON_DPAD_RIGHT):
			vvector.x += 1
			moved = true
		if Input.is_joy_button_pressed(i, JOY_BUTTON_DPAD_UP):
			vvector.y -= 1
			moved = true
		if Input.is_joy_button_pressed(i, JOY_BUTTON_DPAD_DOWN):
			vvector.y += 1
			moved = true
			
		if i == 0 and not moved:
			vvector.x = Input.get_axis("left", "right")
			vvector.y = Input.get_axis("up","down")
			
		player_mapping[i].set_direction(Vector3(vvector.x, 0, vvector.y), delta)
	"""
	
func joy_connection_handler(device, connected):
	
	print("Joystick " + str(device) + " connection state changed to " + str(connected))
	if connected:
		var msg = "\tJ" + str(device) + " name='" + str(Input.get_joy_name(device)) + "'"
		msg += " info='" + str(Input.get_joy_info(device)) + "'"
		msg += " guid='" + str(Input.get_joy_guid(device)) + "'"
		print(msg)
		
		spawn_player_if_necessary(device)
		
		
func spawn_player_if_necessary(device):
	print("In spawn_player_if_necessary(" + str(device) + ")")
	if device in player_mapping:
		# We already have this player bound, skip
		return
	else:
		# Create a player bound to this gamepad
		var new_player = player_scene.instantiate()
		add_child(new_player)
		
		# Get the spawn position which is furthest away from any other players
		new_player.global_position = find_player_spawn_point() 
		
		# Put this player in our device mapping
		player_mapping[device] = new_player

		# This "queues" a material change (the next time the player's process method is called).  I was
		# initially trying to directly call set_material (which changes the material), but the node
		# structure of the player might not be fully set up yet since we just created it.
		new_player.desired_material= player_materials[device]
		
		# (temp)
		print("Created gamepad-oriented player" + str(device) + " at " + str(new_player.global_position))
			
	# If we don't have any players in player_mapping, it means there are no
	# gamepads connected -- make a keyboard-driven player instance for player0
	if device == 0 and len(player_mapping) == 0:
		var keyboard_player = player_scene.instantiate()
		add_child(keyboard_player)
		player_mapping[0] = keyboard_player
		keyboard_player.desired_material = player_materials[0]
		keyboard_player.global_position = find_player_spawn_point()
		
		print("Created keyboard-oriented player0 at " + str(keyboard_player.global_position))
	#keyboard_player.set_material(player_materials[0])
	
	
## Attempts to find a spawn point which is farthest away from other players
func find_player_spawn_point():
	var spoints = get_tree().get_nodes_in_group("player_spawn")
	var best_sp = null
	var best_dist = null
	for sp in spoints:
		# Find the shortest distance, closest_d, to any existing players
		var closest_d = null
		for p in player_mapping:
			var temp = (player_mapping[p].global_position - sp.global_position).length_squared()
			if closest_d == null or temp < closest_d:
				closest_d = temp
		
		# If we haven't picked any spawn points yet, or if d
		# is BIGGER than any other distances we've found yet, make this the
		# (tentative) chosen spawn point
		if best_sp == null or (closest_d != null and closest_d > best_dist):
			best_sp = sp
			best_dist = closest_d
	return best_sp.global_position
					
	
