extends Weapon
class_name Roll_Buster

var bullet = preload("res://entities/bullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	wname = "R.Buster"
	id = 0
	ammocost = 0
	palette = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func ammo_cost():
	return 4

func curr_ammo():
	ammo -= 1
	return ammo
