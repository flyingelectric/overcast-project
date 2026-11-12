extends CharacterBody2D

const part_connect_screen_preload = preload("res://part_connect_screen.tscn")
@export var Part_to_Connect: PartData.part_list

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player_container: Node2D = $HeadContainer
@onready var player_position: Marker2D = $HeadPosition
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var leg_container: Node2D = $LegContainer
@onready var leg_position: Marker2D = $LegPosition

const BODY_SPEED = 64
var inUse = false
var mounted = false

func _ready() -> void:
	add_to_group("bodies")

func _physics_process(delta: float) -> void:
	collision_shape_2d.disabled = not inUse
	$HitBox.disabled = not inUse
	
	
	if not inUse:
		if mounted:
			velocity.x = 0
			player_container.scale.x = -1 if velocity.x < 0 else 1
		return
	
	var direction := Input.get_axis("move_left", "move_right")
	if Input.is_action_just_pressed("connect_part") && inUse: 
		_dismount(direction)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		velocity.x += BODY_SPEED * delta * direction
	if is_on_floor():
			velocity.x = direction * BODY_SPEED
	
	set_animation()
	move_and_slide()

func set_animation():
	var is_moving : bool = velocity.x != 0
	if is_moving:
		player_container.scale.x = 1 if velocity.x < 0 else -1
		sprite_2d.flip_h = velocity.x > 0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		#show prompt
		body.inUse = false
		body.rotation = 0
		body.sprite_2d.flip_h = sprite_2d.flip_h
		call_deferred("do_ride", body)
		#else: hide prompt
		var new_connect_screen = part_connect_screen_preload.instantiate()
		new_connect_screen.part_to_show = Part_to_Connect
		get_parent().add_child(new_connect_screen)

func do_ride(rider):
	rider.reparent(player_container)
	rider.global_position = player_position.global_position
	
	mounted = true
	inUse = true

func _dismount(_direction):
	inUse = false
	mounted = false
	sprite_2d.flip_h = false
	player_container.scale.x = 1
	
	var player = player_container.get_children()[0]
	player.reparent(get_tree().current_scene)
	player.inUse = true
	
	player.position.x -= 50
