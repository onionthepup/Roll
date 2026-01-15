extends CharacterBody2D
class_name Pickup

@onready var area : Area2D  = $Area
@onready var sprite : AnimatedSprite2D  = $Sprite
@onready var sound : AudioStreamPlayer = $Sound
@export var heal = 10
var operating = false
var delay = true
var delay2 = 3

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
			if delay2 == 0: #delay:
				healing()
				delay2 = 3
			else:
				#delay = not delay
				delay2 -= 1
		else:
			if not sound.playing:
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
