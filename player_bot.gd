extends CharacterBody2D
class_name Player

const JUMP_VELOCITY = -250.0
const ROCKET_BOOST = -10.0
const MAX_BOOST = Vector2(175.0, -300.0)

var crouched = false
var is_crouching = false
var rockets = false

var list := PartData.part_list
var connected_parts: Dictionary = {}

func _ready() -> void:
	add_to_group("player")

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

func _physics_process(delta: float) -> void:
	
	#schmovement
	var direction := Input.get_axis("move_left", "move_right")
	#falling
	if !is_on_floor():
			velocity += get_gravity() * delta
			velocity.x += get_player_speed() * delta * direction
	#with body
	if connected_parts.has(list.BODY):
		if is_on_floor():
			velocity.x = direction * get_player_speed()
	#head!!!
	else:
		if is_on_floor() and Input.is_action_just_pressed("jump"):
			position.x += get_player_speed() * direction 
	#with legs
	if connected_parts.has(list.LEGS):
		if is_on_floor():
			if Input.is_action_just_pressed("jump"):
				velocity.y = JUMP_VELOCITY
			if Input.is_action_just_pressed("crouch"):
				$CrouchTimer.start()
				is_crouching = true
				crouched = true
			if $CrouchTimer.is_stopped():
				is_crouching = false
			if Input.is_action_just_released("crouch"):
				$CrouchTimer.start()
				is_crouching = true
				crouched = false
		if crouched:
			$HitBox.shape.size = Vector2(48, 32)
			$HitBox.position = Vector2(0, 16)
		else:
			$HitBox.shape.size = Vector2(28, 64)
			$HitBox.position = Vector2(0, 0)
		#with rockets
		if connected_parts.has(list.ROCKETS):
			if !is_on_floor():
				if Input.is_action_pressed("jump") and $CrouchTimer.is_stopped(): 
					rockets = true
					velocity.y += ROCKET_BOOST
					if velocity.y >= MAX_BOOST.y:
						velocity.y = MAX_BOOST.y
				if velocity.x <= -MAX_BOOST.x:
					velocity.x = -MAX_BOOST.x
				if velocity.x >= MAX_BOOST.x:
					velocity.x = MAX_BOOST.x
			else: 
				rockets = false
	#animations
	$AnimationPlayer.play(frame_animation())
	
	move_and_slide()
