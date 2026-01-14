extends CharacterBody2D

var SPEED = 200.0 #4 pixels per frame
var YSPEED = 160.0 #was 300
var direction = 1
var angle = 0

@onready var hitbox = $Hitbox

func _ready():
	hitbox.body_entered.connect(hit)
	#velocity.y = 100.0

func hit(body):
	body.damage(2)
	self.queue_free()

func _physics_process(delta):
	if direction < 0: $Sprite.flip_h = true
	
	velocity.x = SPEED * direction
	velocity.y = cos(angle) * YSPEED
	angle += PI/8
	YSPEED += 20.0
	
	if not $Visible.is_on_screen(): #not is_on_wall
		self.queue_free()
	
	move_and_slide()
