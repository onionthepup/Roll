extends Entity
class_name Enemy

var contact_damage = 4
var damagetable = [1,1,1,1,1,1,1,1,99]
var flashing = 0
var flashingalter = false
var dead = false
@onready var initialposition = global_position #position enemy respawns in

#will be used to respawn the enemy on death!
@onready var onscreen : VisibleOnScreenNotifier2D = $Onscreen
@onready var hitbox : Area2D = $Hitbox
@onready var sprite : AnimatedSprite2D = $Sprite

var white = preload("res://white.gdshader")
var deathblast = preload("res://entities/death.tscn")

#loot values, out of 128
var small_life = 15 #15 in MM1 and 2
var small_ammo = 25 #15 in MM1, 25 in MM2
var large_life = 4 #2 in MM1, 4 in MM2
var large_ammo = 5 #2 in MM1, 5 in MM2
var one_up = 1

var smalllife = preload("res://entities/cap_hp_small.tscn")
var smallammo = preload("res://entities/cap_am_small.tscn")
var largelife = preload("res://entities/cap_hp_large.tscn")
var largeammo = preload("res://entities/cap_am_large.tscn")

func _ready():
	hitbox.body_entered.connect(contact)
	sprite.material = ShaderMaterial.new()
	inithp()

func _process(delta):
	if not onscreen.is_on_screen():
		undie()
	if dead:
		return
	
	#handle flashing after damage
	if flashing > 0:
		if flashingalter:
			$Sprite.visible = not $Sprite.visible
			if flashing < 14:
				$Sprite.material.shader = null
		flashingalter = not flashingalter
		flashing -= 1
	else:
		$Sprite.visible = true
		$Sprite.material.shader = null
		flashingalter = false

func _physics_process(delta): #don't mess w this
	if dead:
		return
	gravity_pull(delta)
	entity_movement(delta)
	move_and_slide()

func inithp():
	pass

func contact(body):
	body.damage(contact_damage,global_position.x)

func damage(id):
	hp -= damagetable[id]
	if hp <= 0:
		die(id == 6)
	else:
		$Sprite.material.shader = white
		flashing = 15
		flashingalter = false

func die(cut = false):
	set_collision_layer_value(6,false)
	hitbox.set_collision_mask_value(5,false)
	dead = true
	sprite.visible = false
	#add 'cut' animation???
	var dyingblast = deathblast.instantiate()
	dyingblast.position = global_position
	get_parent().add_child(dyingblast)
	loot()

func undie():
	$Sprite.visible = true
	set_collision_layer_value(6,true)
	hitbox.set_collision_mask_value(5,true)
	dead = false
	hp = maxhp
	global_position = initialposition

func loot():
	var rng = randi_range(1,128)
	var loot
	if rng <= small_life:
		loot = smalllife.instantiate()
	elif rng <= (small_life + small_ammo):
		loot = smallammo.instantiate()
	elif rng <= (small_life + small_ammo + large_life):
		loot = largelife.instantiate()
	elif rng <= (small_life + small_ammo + large_life + large_ammo):
		loot = largeammo.instantiate()
	else:
		return
	loot.position = global_position
	get_parent().add_child(loot)
