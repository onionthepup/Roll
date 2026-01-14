extends TileMap

@onready var pausesound : AudioStreamPlayer = $Pausing

var just = false #menu was JUST opened
var operating = false
var equipped = 0 #remove later
var ammo = [28,-1,-1,15,-1,-1,-1,22,-1]

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not operating:
		return
	
	if just:
		just = false
		return
	
	if Input.is_action_just_pressed("pause"):
		end()
		return
	
	var menucommand = 0
	
	#scroll thru menu
	if Input.is_action_just_pressed("down"):
		menucommand = 1
	elif Input.is_action_just_pressed("up"):
		menucommand = -1
	
	if menucommand != 0:
		equip(menucommand)
		while ammo[equipped] < 0:
			equip(menucommand)
		update_weapons()
		print("equipped: " + str(equipped))

func start():
	get_tree().paused = true
	pausesound.play()
	show()
	operating = true
	just = true

func end():
	hide()
	operating = false
	get_tree().paused = false

func equip(inc):
	equipped += inc
	if equipped < 0:
		equipped = 8
	elif equipped > 8:
		equipped = 0

func update_weapons():
	pass

#clear all bullets onscreen
func clear_bullets():
	pass
