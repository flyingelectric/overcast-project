extends Node

var current_legs : Legs
const connect_time = 10.0
var connecting = 0.0
signal connected


func connect_legs(pt_key: String):
	var new_part = Legs.type[pt_key].instantiate()
	
	if current_legs:
		current_legs.queue_free()
	
	add_child(new_part)
	current_legs = new_part

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect_legs("normal")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#connecting
	if Input.is_action_pressed("connect_part"):
		connecting += 0.1
		if connecting >= connect_time:
			connecting = 0.0
			connected.emit()
			print("connected")
	elif Input.is_action_just_released("connect_part"):
		connecting = 0.0
