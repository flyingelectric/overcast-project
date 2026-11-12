extends CharacterBody2D

const part_connect_screen_preload = preload("res://part_connect_screen.tscn")
@export var Part_to_Connect: PartData.part_list

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var body_container: Node2D = $BodyContainer
@onready var body_position: Marker2D = $BodyPosition
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

const JUMP_VELOCITY = -250.0
const ROCKET_BOOST = -10.0
const MAX_BOOST = Vector2(175.0, -300.0)

var inUse = false

func _ready() -> void:
	add_to_group("legs")

func get_player_speed():
	if !is_on_floor():
		return 600.0 
	return 125 #walking

func _physics_process(delta: float) -> void:
	collision_shape_2d.disabled = inUse
	$HitBox.disabled = not inUse
	
	if Input.is_action_just_pressed("connect_part") && inUse: _dismount()
	
	if not inUse:
		return
	
	var direction := Input.get_axis("move_left", "move_right")
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		velocity.x += get_player_speed() * delta * direction
		if velocity.x <= -MAX_BOOST.x:
			velocity.x = -MAX_BOOST.x
		if velocity.x >= MAX_BOOST.x:
			velocity.x = MAX_BOOST.x
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
		velocity.x = direction * get_player_speed()
	if !is_on_floor() && Input.is_action_pressed("jump"): 
		velocity.y += ROCKET_BOOST
		if velocity.y >= MAX_BOOST.y:
			velocity.y = MAX_BOOST.y
	
	
	move_and_slide()
	set_animation()

func set_animation():
	var is_moving : bool = velocity.x != 0
	if is_moving:
		body_container.scale.x = 1 if velocity.x < 0 else -1
		sprite_2d.flip_h = velocity.x > 0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("bodies"):
		body.inUse = false
		body.sprite_2d.flip_h = sprite_2d.flip_h
		
		call_deferred("do_ride", body)
		
		var new_connect_screen = part_connect_screen_preload.instantiate()
		new_connect_screen.part_to_show = Part_to_Connect
		get_parent().add_child(new_connect_screen)

func do_ride(rider):
	rider.reparent(body_container)
	rider.global_position = body_position.global_position
	inUse = true

func _dismount():
	inUse = false
	
	sprite_2d.flip_h = false
	body_container.scale.x = 1
	
	var player = body_container.get_children()[0]
	player.reparent(get_tree().current_scene)
	player.inUse = true
	
	player.position.x -= 75
