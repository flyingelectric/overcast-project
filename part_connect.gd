extends Sprite2D

const part_connect_screen_preload = preload("res://part_connect_screen.tscn")

@export var Part_to_Connect: PartData.part_list

func _ready() -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.connected_parts[Part_to_Connect] = true
		
		var new_connect_screen = part_connect_screen_preload.instantiate()
		new_connect_screen.part_to_show = Part_to_Connect
		get_parent().add_child(new_connect_screen)
		
		
		queue_free()
