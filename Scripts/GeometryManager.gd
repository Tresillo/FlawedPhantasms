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
					if not found and window_materials.find(m) > -1:
						temp_block.add_to_group("window")
						found = true
			
			if c is RectWall:
				var temp_wall: RectWall = c as RectWall
				if window_materials.find(temp_wall.display_material) > -1:
					temp_wall.add_to_group("window")
			
			if c is Door:
				var temp_door: Door = c as Door
				if window_materials.find(temp_door.display_material) > -1:
					temp_door.add_to_group("window")
