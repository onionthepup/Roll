extends CharacterBody2D
class_name Entity

var maxhp = 28
var hp
var flying = false
var gravity = 900.0		#the thing that pulls you downwards
var terminalv = 420.0	#max velocity downwards

#moving?
#gravity

# Called when the node enters the scene tree for the first time.
func _ready():
	hp = maxhp

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta): #don't mess w this
	gravity_pull(delta)
	entity_movement(delta)
	move_and_slide()

func entity_movement(delta): #mess w this instead
	pass

func damage(id):
	pass

func gravity_pull(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y > terminalv:
			velocity.y = terminalv
