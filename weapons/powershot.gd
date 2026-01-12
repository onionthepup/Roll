extends Weapon
class_name Power_Shot

# Called when the node enters the scene tree for the first time.
func _ready():
	wname = "P.Shot"
	id = 1
	ammocost = 4
	palette = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func ammo_cost():
	return 4

func curr_ammo():
	ammo -= 1
	return ammo
