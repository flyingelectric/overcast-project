extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var inUse = true

const HEAD_SPEED = 16

var list := PartData.part_list
var connected_parts: Dictionary = {}

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	collision_shape_2d.disabled = not inUse
	
	if not inUse:
		return
	
	var direction := Input.get_axis("move_left", "move_right")
	
	if !is_on_floor():#falling
			velocity += get_gravity() * delta
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		head_roll(direction)
	
	move_and_slide()

func head_roll(direction):
	position.x += HEAD_SPEED * direction
	position.y -= 16
	rotation_degrees += 90 * direction

func set_animation():
	var is_moving : bool = velocity.x != 0
	if is_moving:
		sprite_2d.flip_h = velocity.x > 0
