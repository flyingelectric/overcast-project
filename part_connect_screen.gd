extends CanvasLayer

@onready var NameLabel = $ColorRect/CenterContainer/VBoxContainer/VBoxContainer/NameLabel
@onready var DescriptionLabel = $ColorRect/CenterContainer/VBoxContainer/VBoxContainer/DescriptionLabel

@onready var IconIMGNode = $ColorRect/CenterContainer/VBoxContainer/IconIMG

var part_to_show: PartData.part_list

func _ready() -> void:
	get_tree().paused = true
	
	$ColorRect/CenterContainer/VBoxContainer/VBoxContainer/CloseLabel.hide()
	
	NameLabel.text = PartData.INFO[part_to_show]["name"]
	DescriptionLabel.text = PartData.INFO[part_to_show]["description"]
	IconIMGNode.texture = PartData.INFO[part_to_show]["icon"]

func _input(_event: InputEvent) -> void:
	await get_tree().create_timer(1.5).timeout
	$ColorRect/CenterContainer/VBoxContainer/VBoxContainer/CloseLabel.show()
	if $ColorRect/CenterContainer/VBoxContainer/VBoxContainer/CloseLabel.visible:
		while ! Input.is_anything_pressed():
			await get_tree().process_frame
		get_tree().paused = false
		queue_free()
