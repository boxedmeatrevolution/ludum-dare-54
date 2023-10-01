extends "res://scripts/Car.gd"

func _on_damage_received(damage : float, total_damage : float, destroyed : bool) -> void:
	print(total_damage)
