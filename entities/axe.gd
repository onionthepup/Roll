extends CharacterBody2D

var speed = 360.0 #4 pixels per frame
var direction = 1
var guidable = true

@onready var hitbox = $Hitbox

func _ready():
	hitbox.body_entered.connect(hit)

func hit(body):
	if body is Roll:
		if speed < 0:
			self.queue_free()
	else:
		body.damage(6)
	#self.queue_free()

func _physics_process(delta):
	if direction < 0: $Sprite.flip_h = true
	
	speed -= 9.0
	
	if guidable and abs(speed) < 10:
		if Input.is_action_pressed("up"):
			velocity.y = -100.0
			guidable = false
		elif Input.is_action_pressed("down"):
			velocity.y = 100.0
			guidable = false
	
	velocity.x = speed * direction
	velocity.y *= 0.98
	
	if not $Visible.is_on_screen(): #no is_on_wall check
		self.queue_free()
	
	move_and_slide()
