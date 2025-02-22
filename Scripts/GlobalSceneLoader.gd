extends Node

class_name LevelLoader

var current_scene = null
var current_scene_path

const level_paths = [
	"res://Scenes/Levels/level_1.tscn",
	"res://Scenes/Levels/level_2.tscn",
	"res://Scenes/Levels/level_4.tscn",
	"res://Scenes/Levels/level_3.tscn",
	"res://Scenes/Levels/level_5.tscn",
	"res://Scenes/ThanksForPlaying.tscn"
]

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	current_scene_path = "res://Scenes/main_menu.tscn"


func goto_next_level():
	var scene_idx: int = level_paths.find(current_scene_path)
	if scene_idx >= 0 and scene_idx + 1 < level_paths.size():
		goto_scene(level_paths[scene_idx + 1])
	else:
		goto_scene("res://Scenes/main_menu.tscn")


func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	# It is now safe to remove the current scene.
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()
	current_scene_path = path

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene
