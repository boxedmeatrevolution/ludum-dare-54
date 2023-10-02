extends Node

const Level := preload("res://scripts/Level.gd")

var level_paths : Array[String]
var current_level : int = 0

func _ready() -> void:
	var level_dir := DirAccess.open("res://levels")
	for file in level_dir.get_files():
		if file.ends_with(".remap"):
			file = file.replace(".remap", "")
		if file.ends_with(".tscn"):
			level_paths.append(level_dir.get_current_dir() + "/" + file)
	print(level_paths)
	
	var level_index = 0
	
	# In editor load current scene
	if OS.has_feature("editor"):
		var current_scene_path = get_tree().current_scene.scene_file_path
		level_index = max(0, level_paths.find(current_scene_path))
	change_level(level_index)

func _process(_delta : float) -> void:
	if Input.is_action_just_pressed("next_level"):
		change_level(current_level + 1)
	elif Input.is_action_just_pressed("previous_level"):
		change_level(current_level - 1)
	elif Input.is_action_just_pressed("restart_level"):
		change_level(current_level)

func change_level(idx : int) -> void:
	current_level = posmod(idx, level_paths.size())
	get_tree().change_scene_to_file(level_paths[current_level])
	
