extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var clist = get_node("../player_manager").get_player_material_colors()
	for i in range(4):
		var color:Color = clist[i]
		
		#$bar_container/top_status.get_child(i).change_color(color)
		get_child(i + 1).change_color(color)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func set_num_coins(index, num):
	#get_node("bar_container/top_status/p" + str(index) + "stats").set_num_coins(num)
	get_node("p" + str(index) + "stats").set_num_coins(num)
	
func set_num_lives(index, num):
	#get_node("bar_container/top_status/p" + str(index) + "stats").set_num_lives(num)
	get_node("p" + str(index) + "stats").set_num_lives(num)
	
func set_playerstats_active(index, is_active):
	get_node("p" + str(index) + "stats").set_active(is_active)
	
func set_player_health(index, new_amt):
	get_node("p" + str(index) + "stats").set_health(new_amt)
	
