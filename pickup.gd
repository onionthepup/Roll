extends CharacterBody2D
class_name Pickup

@onready var area : Area2D  = $Area
@onready var sprite : AnimatedSprite2D  = $Sprite
var heal = 10
var operating = false
var delay = true

var gravity = 900.0
var terminalv = 420.0

var roll : CharacterBody2D

func _ready():
	area.body_entered.connect(start)
	roll = get_parent().roll()

func _process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y > terminalv:
			velocity.y = terminalv
	
	if operating:
		if heal > 0:
			if delay:
				healing()
			else:
				delay = not delay
		else:
			get_tree().paused = false
			self.queue_free()
	
	move_and_slide()

func start(body):
	sprite.visible = false
	get_tree().paused = true
	operating = true
	healing()

func healing():
	pass
