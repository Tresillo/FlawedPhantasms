extends Node3D

@export var level_index: int
@export var level_name: String

@onready var collectible_found: bool = false
@onready var num_times_swapped: int = 0
@onready var time_taken: float = 0.0

@onready var paused: bool = true

var level_data: LevelData

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var interactible_level_objs = get_node("LevelGeometry/Interactables")
	
	#connect to collectible
	for c in interactible_level_objs.get_children():
		if c is Collectible:
			(c as Collectible).pickup_collected.connect(col_fnd)
		elif c is LevelGoal:
			(c as LevelGoal).level_finished.connect(level_finished)
	
	for p in get_tree().get_nodes_in_group("player"):
		(p as Player).body_swapped.connect(func(): num_times_swapped += 1)
		if p._starting_player:
			p.starting_player_start_animation()
			(p as Player).finished_start_animation.connect(func(): paused = false)
	
	level_data = get_node("/root/DataLoaderAutoload").save_data.level_data[level_index]


func _process(delta):
	if not paused:
		time_taken += delta


func col_fnd():
	collectible_found = true


func level_finished():
	paused = true
