extends Node
var list = PartData.part_list
var connected_parts: Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func frame_animation() -> String:
	var is_moving : bool = velocity.x != 0
	if is_moving:
		$Sprite2D.flip_h = velocity.x > 0
	
	if !is_on_floor() and velocity.y != 0:
		if rockets:
			return "RESET"
		return "jump"
	
	if !is_moving:
		if crouched: 
			if !is_crouching:
				return "CROUCHED"
			return "crouch"
			if is_crouching:
				return "uncrouch"
	
	if is_moving:
		if crouched:
			return "crouch_walk"
		return "walk"
	return "RESET"

func get_player_speed():
	if connected_parts.has(list.BODY):
		if !is_on_floor():
			if connected_parts.has(list.ROCKETS):
				return 600.0
			return 400.0 #airtime
		if connected_parts.has(list.LEGS):
			if is_crouching:
				return 0.0
			if crouched and is_on_floor():
				return 75.0 #crawl
			return 150 #walking
		return 64.0 #no legs :(
	return 16.0 #scootin'

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if connected_parts.has(list.BODY):
		if is_on_floor():
			velocity.x = direction * get_player_speed()
	else:
		if is_on_floor() and Input.is_action_just_pressed("jump"):
			position.x += get_player_speed() * direction #head!!!
		
