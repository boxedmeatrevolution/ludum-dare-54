extends "res://scripts/Car.gd"

const Car := preload("res://scripts/Car.gd")
const PlayerAI := preload("res://scripts/PlayerAI.gd")
const SirenEffectScene := preload("res://entities/SirenEffect.tscn")

@onready var player_car_parent := get_node("/root/Level/PlayerCarParent")
var death_animation_triggered : bool = false

func _on_damage_received(_damage : float, _total_damage : float, destroyed : bool) -> void:
	if destroyed && !death_animation_triggered:
		death_animation_triggered = true
		var siren := SirenEffectScene.instantiate()
		light_parent.add_child(siren)
		siren.global_transform = global_transform
		siren.car = self
		sprite_headlight_left.visible = true
		sprite_headlight_right.visible = true
		sprite_rearlight.visible = true
		for child in player_car_parent.get_children():
			if child is Car:
				for grandchild in child.get_children():
					if grandchild is PlayerAI:
						grandchild.has_lost = true
	
