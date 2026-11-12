extends CharacterBody2D


var speed = 150.0
const JUMP_VELOCITY = -250.0


func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#movement
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var direction := Input.get_axis("move_left", "move_right")
	var crouch = Input.is_action_pressed("crouch")
	var hit_box = $CollisionShape2D.get_shape()
	if crouch:
		speed = 75
		hit_box.size = Vector2(64, 32)
	else:
		speed = 150
		hit_box.size = Vector2(32, 64)
	
	if direction:
		velocity.x = direction * speed
	elif not is_on_floor():
		var air_resist = velocity.x - (velocity.x * delta)
		velocity.x = move_toward(velocity.x, air_resist, direction)
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, speed)
	
	#animations
	var current_frame = $AnimatedSprite2D.get_frame()
	if velocity.x != 0 and is_on_floor():
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.flip_h = velocity.x > 0
	elif velocity.y != 0:
		$AnimatedSprite2D.play("jump")
	elif crouch:
		$AnimatedSprite2D.play("crouch")
		await current_frame <= 4
		$AnimatedSprite2D.pause()
	else:
		$AnimatedSprite2D.stop()

	move_and_slide()
