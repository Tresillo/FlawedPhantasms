extends Node3D

@onready var collectible_found: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var interactible_level_objs = find_child("LevelGeometry/Interactables")
	
	#connect to collectible
	for c in interactible_level_objs.get_children():
		if c is Collectible:
			(c as Collectible).pickup_collected.connect(col_fnd)
	
	for p in get_tree().get_nodes_in_group("player"):
		if p._starting_player:
			p.starting_player_start_animation()


func col_fnd():
	collectible_found = true
