extends Entity
class_name Enemy

var contact_damage = 4
var damagetable = [1,1,1,1,1,1,1,1,1]
var flashing = 0
var flashingalter = false
var dead = false
@onready var initialposition = global_position #position enemy respawns in

#will be used to respawn the enemy on death!
@onready var onscreen : VisibleOnScreenNotifier2D = $Onscreen
@onready var hitbox : Area2D = $Hitbox
@onready var sprite : AnimatedSprite2D = $Sprite

var white = preload("res://white.gdshader")

#respawn when offscreen

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
		die()
	else:
		$Sprite.material.shader = white
		flashing = 15

func die():
	$Sprite.visible = false
	set_collision_layer_value(6,false)
	hitbox.set_collision_mask_value(5,false)
	dead = true

func undie():
	$Sprite.visible = true
	set_collision_layer_value(6,true)
	hitbox.set_collision_mask_value(5,true)
	dead = false
	hp = maxhp
	global_position = initialposition

func loot():
	pass
