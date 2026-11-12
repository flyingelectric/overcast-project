extends CharacterBody2D

const part_connect_screen_preload = preload("res://part_connect_screen.tscn")
@export var Part_to_Connect: PartData.part_list

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var body_container: Node2D = $BodyContainer
@onready var body_position: Marker2D = $BodyPosition
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

const JUMP_VELOCITY = -250.0

var crouched = false
var is_crouching = false

var mounted = false
var inUse = false

func _ready() -> void:
	add_to_group("legs")

func frame_animation() -> String:
	var is_moving : bool = velocity.x != 0
	if is_moving:
		body_container.scale.x = 1 if velocity.x < 0 else -1
		$Sprite2D.flip_h = velocity.x > 0
	
	if !is_on_floor() and velocity.y != 0:
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
	if !is_on_floor():
		return 400
	if is_crouching:
		return 0.0
	if crouched and is_on_floor():
		return 75.0 #crawl
	return 150 #walking

func _physics_process(delta: float) -> void:
	#collision_shape_2d.disabled = inUse
	#$HitBox.disabled = not inUse
	
	if Input.is_action_just_pressed("connect_part") && inUse: _dismount()
	
	if not mounted:
		return
	
	var direction := Input.get_axis("move_left", "move_right")
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		velocity.x += get_player_speed() * delta * direction
	if is_on_floor():
		if Input.is_action_just_pressed("jump") and !crouched:
			velocity.y = JUMP_VELOCITY
		velocity.x = direction * get_player_speed()
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
		$HitBox.shape.size = Vector2(96, 64)
		$HitBox.position = Vector2(0, -30)
	else:
		$HitBox.shape.size = Vector2(56, 128)
		$HitBox.position = Vector2(0, -46)
	
	move_and_slide()
	$AnimationPlayer.play(frame_animation())


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("bodies"):
		body.inUse = false
		sprite_2d.flip_h = body.sprite_2d.flip_h
		
		call_deferred("do_ride", body)
		
		var new_connect_screen = part_connect_screen_preload.instantiate()
		new_connect_screen.part_to_show = Part_to_Connect
		get_parent().add_child(new_connect_screen)

func do_ride(rider):
	rider.reparent(body_container)
	rider.global_position = body_position.global_position
	inUse = true

func _mount(mount):
	reparent(mount.leg_container)
	global_position = mount.leg_position.global_position

func _dismount():
	inUse = false
	
	sprite_2d.flip_h = false
	body_container.scale.x = 1
	
	var player = body_container.get_children()[0]
	player.reparent(get_tree().current_scene)
	player.inUse = true
	
	player.position.x -= 75
