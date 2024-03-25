extends Node3D

@onready var window_materials: Array[Material] = [
		preload("res://Assets/Mat/window_mat.tres"),
		preload("res://Assets/Mat/window_tex_mat.tres")
]

func _ready():
	#go through all children (deep search) and add them to the correct groups
	for c in get_children(true):
		if c.get_groups().find("window") == -1:
			
			if c is CyclopsBlock:
				var temp_block: CyclopsBlock = c as CyclopsBlock
				var found: bool = false
				for m in temp_block.materials:
					if not found and (m == window_materials[0] or m == window_materials[1]):
						temp_block.add_to_group("window")
						found = true
			
			if c is RectWall:
				var temp_wall: RectWall = c as RectWall
				
