extends Node

@onready var subscreen : TileMap = $Subscreen

func _ready():
	pass

func _process(delta):	
	if Input.is_action_just_pressed("pause"):
		subscreen.start()

func updatehp(value):
	$Lifebar.bar(value)
