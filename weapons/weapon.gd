extends Node
class_name Weapon

var wname = ""
var id
var ammo = 28
var ammocost
var palette
var maxbullets
var delay = 0.15		#how many seconds between shots

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func shoot(busteranim):
	var blts = get_tree().get_nodes_in_group("bullets").size()
	if blts < maxbullets && busteranim < delay && ammo >= ammocost: #must be 0.1s after shooting; shoot every 6 frames
		buster()

func buster():
	pass
