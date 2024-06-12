extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var clist = get_node("../player_manager").get_player_material_colors()
	for i in range(4):
		var color:Color = clist[i]
		color.a = 0.5
		$bar_container/top_status.get_child(i).change_color(color)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
