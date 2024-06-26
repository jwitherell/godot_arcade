extends Control

const MAX_HEALTH = 100.0
const MAX_SHIELDS = 100.0

var displayed_health = MAX_HEALTH
var desired_health = MAX_HEALTH
var displayed_shields = MAX_SHIELDS
var desired_shields = MAX_SHIELDS

var active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$health_progress.max_value = MAX_HEALTH
	$health_progress.value = MAX_HEALTH
	$shield_progress.max_value = MAX_SHIELDS
	$shield_progress.value = MAX_SHIELDS
	
	set_active(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func change_color(col=null):
	if col == null:
		col = $border_img.modulate
		
	if active:
		col.a = 1.0
	else:
		col.a = 0.4
	
	# Change the image-type color modulations
	$border_img.modulate = col
	$health_icon.modulate = col
	$shield_icon.modulate = col
	$life_icon.modulate = col
	$coin_icon.modulate = col
	
	# Change the text colors
	$player_name.add_theme_color_override("default_color", col)
	$x1.add_theme_color_override("default_color", col)
	$x2.add_theme_color_override("default_color", col)
	$num_lives.add_theme_color_override("default_color", col)
	$num_coins.add_theme_color_override("default_color", col)
	$score.add_theme_color_override("default_color", col)
	$game_over.add_theme_color_override("default_color", col)
	
	# Change progress bar colors
	var temp = $health_progress.get_theme_stylebox("fill")
	temp.bg_color = col
	$health_progress.add_theme_stylebox_override("fill", temp)
	
func set_num_coins(num):
	$num_coins.text = str(num)
	
func set_num_lives(num):
	$num_lives.text = str(num)
	
func set_health(new_desired):
	# Eventually, I want a damage-over-time look to the health bar.  But
	# for now, just set the displayed and real health values
	displayed_health = new_desired     # This part will change
	desired_health = new_desired
	$health_progress.value = new_desired		# As will this
	
func set_shields(new_desired):
	displayed_shields = new_desired
	desired_shields = new_desired
	$shield_progress.value = new_desired
	
func set_active(is_active):
	active = is_active
	
	print("setting to " + str(is_active))
	$player_name.visible = is_active
	$score.visible = is_active
	$health_icon.visible = is_active
	$health_progress.visible = is_active
	$shield_icon.visible = is_active
	$shield_progress.visible = is_active
	$game_over.visible = not is_active
	
	change_color()
	
	
