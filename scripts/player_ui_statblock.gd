extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func change_color(col):
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
	
	# Change progress bar colors
	var temp = $health_progress.get_theme_stylebox("fill")
	temp.bg_color = col
	$health_progress.add_theme_stylebox_override("fill", temp)
	
