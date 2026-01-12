extends CharacterBody2D

const SPEED = 240.0 #4 pixels per frame
var direction = 1

@onready var hitbox = $Hitbox

func _ready():
	hitbox.body_entered.connect(hit)

func hit(body):
	body.damage(0)
	self.queue_free()

func _physics_process(delta):
	if direction < 0: $Sprite.flip_h = true
	
	velocity.x = SPEED * direction
	
	if is_on_wall() or not $Visible.is_on_screen():
		self.queue_free()
	
	move_and_slide()
