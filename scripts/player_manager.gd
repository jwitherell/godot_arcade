extends Node3D

# Keys are 0...3.  Values are the player instance for that player (or null if that player is not
#  in the game).  All player instances are children of this manager object in the scene tree
var player_mapping: Dictionary

# The scene to instantiate for all player objects
@export var player_scene:PackedScene

# An array of player materials to use for each player
@export var player_materials:Array[StandardMaterial3D]

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect ourselves to the Input signal that is emitted when a gamepad is plugged in / out
	Input.connect("joy_connection_changed", joy_connection_handler)
	
	# (temporary) Set the first player driven
	var default_player = player_scene.instantiate()
	add_child(default_player)
	player_mapping[0] = default_player
	
	# This "queues" a material change (the next time the player's process method is called).  I was
	# initially trying to directly call set_material (which changes the material), but the node
	# structure of the player might not be fully set up yet since we just created it.
	default_player.desired_material= player_materials[0]
	#keyboard_player.set_material(player_materials[0])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Ideally, I would've done input bindings.  But dpad button events seem to 
	# only be generated for *all* devices.  This lets me distinguish which
	# defice generated it
	var vvectors = [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	var moved = false
	for i in player_mapping:
		var vvector = Vector2(0, 0)
		
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
	
	
func joy_connection_handler(device, connected):
	print("Joystick " + str(device) + " connection state changed to " + str(connected))
