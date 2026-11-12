extends Node
class_name PartData

enum part_list {
	BODY,
	LEGS,
	ROCKETS,
	LEFT_ARM,
	RIGHT_ARM,
}


const INFO: Dictionary = {
	part_list.BODY: {
		"name": "Your body",
		"description": "The one you were built with.",
		"icon": preload("res://robot ref sheet/robot ref sheet(body) _0001.png")
	},
	
	part_list.LEGS: {
		"name": "Legs",
		"description": "Now you can walk!",
		"icon": preload("res://robot ref sheet/robot ref sheet(legs) _0001.png"),
	},
	
	part_list.ROCKETS: {
		"name": "Rockets",
		"description": "Now you can fly?",
		"icon": preload("res://robot ref sheet/robot ref sheet(legs_rocket) _0001.png")
	},
	
	part_list.LEFT_ARM: {
		"name": "left arm",
		"description": "Wonder where your other one went...",
		"icon": preload("res://robot ref sheet/robot ref sheet(arm 1) _0001.png")
	},
	
	part_list.RIGHT_ARM: {
		"name": "right_arm",
		"description": "There it is!",
		"icon": preload("res://robot ref sheet/robot ref sheet(arm 2) _0001.png")
	}
}
