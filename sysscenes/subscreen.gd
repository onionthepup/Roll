extends TileMap

@onready var pausesound : AudioStreamPlayer = $Pausing

var just = false #menu was JUST opened
var operating = false
var equipped = 0 #weapon equipped in the menu; only updates roll's on menu end
var roll
@onready var icons = [$Icon0,$Icon1,$Icon2,$Icon3,$Icon4,$Icon5,$Icon6,$Icon7,$Icon8]
@onready var names = [$Name0,$Name1,$Name2,$Name3,$Name4,$Name5,$Name6,$Name7,$Name8]
@onready var ammos = [$Ammo0,$Ammo1,$Ammo2,$Ammo3,$Ammo4,$Ammo5,$Ammo6,$Ammo7,$Ammo8]

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
	
	if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("jump"):
		end(true)
		return
	
	if Input.is_action_just_pressed("shoot"):
		end(false)
		return
	
	var menucommand = 0
	
	#scroll thru menu
	if Input.is_action_just_pressed("down"):
		menucommand = 1
	elif Input.is_action_just_pressed("up"):
		menucommand = -1
	
	if menucommand != 0:
		equip(menucommand)
		while roll.ammo[equipped] < 0:
			equip(menucommand)
		update_weapons()

func start(getroll):
	roll = getroll
	equipped = roll.equipped
	get_tree().paused = true
	pausesound.play()
	show()
	update_weapons()
	operating = true
	just = true

func end(confirm):
	hide()
	if confirm:
		roll.equipped = equipped
		clear_bullets()
	operating = false
	get_tree().paused = false
	roll.updateammo()

func equip(inc):
	equipped += inc
	if equipped < 0:
		equipped = 8
	elif equipped > 8:
		equipped = 0

func update_weapons():
	for i in range(9):
		if i == equipped:
			icons[i].frame = 0
			names[i].frame = 0
			ammos[i].frame = 0
			ammos[i].region_rect = Rect2(0,0,2*roll.ammo[i],18)
			ammos[i].position.x = 41 + roll.ammo[i]
			ammos[i].region_enabled = true
		elif roll.ammo[i] >= 0:
			icons[i].frame = 1
			names[i].frame = 1
			ammos[i].frame = 1
			ammos[i].region_rect = Rect2(0,0,2*roll.ammo[i],18)
			ammos[i].position.x = 41 + roll.ammo[i]
			ammos[i].region_enabled = true
		else:
			icons[i].frame = 2
			names[i].frame = 2
			ammos[i].frame = 2

#clear all bullets onscreen
func clear_bullets():
	for bullet in get_tree().get_nodes_in_group("bullets"):
		bullet.queue_free()
