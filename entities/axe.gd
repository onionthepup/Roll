extends CharacterBody2D

var speed = 360.0 #4 pixels per frame
var direction = 1

@onready var hitbox = $Hitbox

func _ready():
	hitbox.body_entered.connect(hit)

func hit(body):
	body.damage(6)
	#self.queue_free()

func _physics_process(delta):
	if direction < 0: $Sprite.flip_h = true
	
	speed -= 9.0
	
	velocity.x = speed * direction
	
	if not $Visible.is_on_screen(): #no is_on_wall check
		self.queue_free()
	
	move_and_slide()
