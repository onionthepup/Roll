extends CharacterBody2D

const SPEED = 240.0 #4 pixels per frame
@export var direction = 1 #roll can set the direction

func _physics_process(delta):
	if direction < 0: $Sprite.flip_h = true
	
	velocity.x = SPEED * direction
	
	if is_on_wall() or not $Visible.is_on_screen():
		self.queue_free()
	
	move_and_slide()
