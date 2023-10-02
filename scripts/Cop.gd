extends "res://scripts/Car.gd"

const SirenEffectScene := preload("res://entities/SirenEffect.tscn")

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
	
