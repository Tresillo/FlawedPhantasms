extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	for p in get_tree().get_nodes_in_group("player"):
		if p._starting_player:
			p.starting_player_start_animation()
			break
