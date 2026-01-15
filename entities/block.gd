extends CharacterBody2D
class_name Block

var gravity = 1800.0
var timer = 0.2 #stops it from moving for a bit on spawn
var is_lifted = false
var direction = 1

func _ready():
	$Hitbox.body_entered.connect(hit)

func hit(body):
	body.damage(8)

func _physics_process(delta):
	if is_lifted:
		return
	
	if timer > 0:
		timer -= delta
		return
	
	if is_on_floor():
		$Hitbox.monitoring = false
	else:
		velocity.y += gravity * delta
		if velocity.x == 0:
			$Hitbox.monitoring = true
	
	if not $Visible.is_on_screen():
		self.queue_free()
	
	move_and_slide()

func lifted(roll, new_position):
	reparent(roll)
	gravity = 0
	position = new_position
	set_collision_layer_value(1,false)
	set_collision_mask_value(1,false)
	$Hitbox.monitoring = false
	is_lifted = true

func thrown():
	$ThrownHitbox.monitoring=true
	$ThrownHitbox.body_entered.connect(thrownhit)
	velocity.x = 400.0 * direction
	velocity.y = -240.0
	gravity = 1800.0
	is_lifted = false

func thrownhit(body):
	body.damage(8)
	self.queue_free()
