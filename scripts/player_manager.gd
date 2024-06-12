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
	
func get_player_material_colors():
	var clist = []
	for pm in player_materials:
		clist.append(pm.albedo_color)
	return clist
	

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

func _unhandled_input(event):
	if event is InputEventJoypadButton:
		print("joypad button" + str(event.button_index) + "=" + str(event.pressed))
			
	"""for i in player_mapping:
		for j in [JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_BACK, JOY_BUTTON_DPAD_DOWN,
		JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_GUIDE, JOY_BUTTON_LEFT_SHOULDER,
		JOY_BUTTON_LEFT_STICK, JOY_BUTTON_MAX, JOY_BUTTON_MISC1, JOY_BUTTON_PADDLE1,
		JOY_BUTTON_PADDLE2, JOY_BUTTON_ ]
			if Input.is_joy_button_pressed(i, j):
				print("device" + str(i) + " pressed button" + str(j))
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
		new_player.set_player_id(device)
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
		keyboard_player.set_player_id(0)
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
					
	
