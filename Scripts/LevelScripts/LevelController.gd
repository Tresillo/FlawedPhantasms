extends Node3D

@onready var collectible_found: bool = false
@onready var num_times_swapped: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var interactible_level_objs = get_node("LevelGeometry/Interactables")
	
	#connect to collectible
	for c in interactible_level_objs.get_children():
		if c is Collectible:
			(c as Collectible).pickup_collected.connect(col_fnd)
	
	for p in get_tree().get_nodes_in_group("player"):
		(p as Player).body_swapped.connect(func(): num_times_swapped += 1)
		if p._starting_player:
			p.starting_player_start_animation()
			


func col_fnd():
	collectible_found = true
