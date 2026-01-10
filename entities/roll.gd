extends "res://entities/entity.gd"

var direction = Vector2.ZERO
@onready var animated_sprite : AnimatedSprite2D = $Sprite
@onready var landsound : AudioStreamPlayer = $Landing
@onready var bustersound : AudioStreamPlayer = $Shooting

var bullet = preload("res://entities/bullet.tscn")
var blastelem = preload("res://entities/blastelem.tscn")

var speed = 82.5   #1.6
var airspeed = 78.75
var jumpspeed = 294.375   #4.DF in 1~2, or 4.A5 in 3, or 4.C0 in 4
var gravity = 900.0 #0.4
var accelspeed = 15.0 #was 0.2->7.5; average of rockman3 is 8.65
var acceltime = 0.116 #7; time spent in accel
var accelcount = 0
var in_air = false
var climbspeed = 77.8125 #climb speed in 1-2: 45; in 3: 77.8125
var on_ladder = false
var ladderclimb = Vector2.ZERO

var bulletspeed = 240 #4 pixels/frame
var busterout = 0.25 #buster stays out 15 frames
var busteranim = 0.0

var hp = 28
var ammo = [28,-1,-1,-1,-1,-1,-1,-1,-1]

# Called when the node enters the scene tree for the first time.
func _ready():
	updatehp()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if position.y < $Camera.limit_top:
		$Camera/CameraControl.adjust(-1)
	elif position.y > $Camera.limit_bottom:
		$Camera/CameraControl.adjust(1)

func _physics_process(delta):
	
#	if Input.is_action_pressed("up") and $LadderDetector.is_colliding():
#		on_ladder = true
#	elif not $LadderDetector.is_colliding():
#		on_ladder = false
	
	if $LadderDetector.is_colliding():
		if Input.is_action_pressed("up"):
			on_ladder = true
			position.x = 16 * round((position.x+8)/16) - 8
	else:
		on_ladder = false
	
	if $UnderLadderDetector.is_colliding() and not $LadderDetector.is_colliding() and Input.is_action_pressed("down"):
		position.x = 16 * round((position.x+8)/16) - 8
		position.y -= 1
		on_ladder = true
		self.set_collision_mask_value(1,false)
	
	if not on_ladder:
		self.set_collision_mask_value(1,true)
	
	#gravity.
	if not is_on_floor():
		in_air = true
		if on_ladder:
			velocity.y = 0
		else:
			velocity.y += gravity * delta
			if velocity.y > 420:
				velocity.y = 420
	elif in_air: #handle landing
		in_air = false
		landsound.play()
	
	#headbonk
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump()
		elif on_ladder:
			on_ladder = false
			velocity.y = 0
	
	# fall quicker when you let go of jump
	if Input.is_action_just_released("jump") and velocity.y < -127.265625:
		velocity.y = -60
	
	#handle walking
	direction = Input.get_axis("left", "right")
	if direction:
		if is_on_floor():
			if accelcount >= acceltime:
				velocity.x = direction * speed
			else:
				velocity.x = direction * accelspeed
				accelcount += delta
		else:
			velocity.x = direction * airspeed
	else:
		if not is_on_floor():
			accelcount = 0
		if accelcount >= acceltime:
			accelcount = 0
		else:
			velocity.x = 0
	
	#handle climbing
	if on_ladder:
		velocity.x = 0
		ladderclimb = Input.get_axis("up", "down")
		velocity.y = ladderclimb * climbspeed
	
	#handle shooting
	if Input.is_action_just_pressed("shoot"):
		shoot()
	
	if busteranim > 0:
		busteranim -= delta
		if on_ladder:
			velocity.y = 0
	
	move_and_slide()
	update_animation()
	
func update_animation():
	var state = ""
	if busteranim > 0:
		state = "_shoot"
	#can add _climb and _throw states!
	
	if on_ladder:
		change_animation("climb" + state)
		if velocity.y == 0:
			animated_sprite.pause()
		else:
			animated_sprite.play()
			if $LadderDetector.is_colliding() and not $UpperLadderDetector.is_colliding():
				animated_sprite.play("climb_top")
	elif not is_on_floor():
		animated_sprite.play("jump" + state)
	elif direction and accelcount >= acceltime:
		change_animation("walk" + state)
	elif direction:
		if busteranim > 0:
			change_animation("walk_shoot")
		else:
			animated_sprite.play("accel")
	elif busteranim > 0:
		change_animation("shoot") #animated_sprite.play("shoot")
	else:
		animated_sprite.play("idle")
	flippy()

func change_animation(newanim):
	var frame = animated_sprite.frame
	var frameprogress = animated_sprite.frame_progress
	animated_sprite.play(newanim)
	animated_sprite.frame = frame
	animated_sprite.frame_progress = frameprogress

#updates flipping
func flippy():
	if direction > 0:
		animated_sprite.flip_h = false
		$Shape.position.x = -1
	elif direction < 0:
		animated_sprite.flip_h = true
		$Shape.position.x = 1
	if on_ladder:
		$Shape.position.x = 0

func jump():
	velocity.y = -jumpspeed

func shoot():
	#this will check for equipped weapon etc.
	var blts = get_tree().get_nodes_in_group("bullets").size()
	if blts < 3 && busteranim < 0.15: #must be 0.1s after shooting; shoot every 6 frames
		buster()
	
func buster():
	damage(1)
	
	bustersound.play()
	busteranim = busterout
	
	var blt = bullet.instantiate()
	
	if animated_sprite.flip_h:
		$Muzzle.position.x = -16
		blt.direction = -1
	else:
		$Muzzle.position.x = 16
	
	if is_on_floor():
		$Muzzle.position.y = 5
	else:
		$Muzzle.position.y = -1
	
	blt.position = $Muzzle.global_position
	
	get_parent().add_child(blt)
	blt.add_to_group("bullets")

func damage(value):
	hp -= value
	updatehp()
	if hp <= 0:
		death()
	
func updatehp():
	get_parent().updatehp(hp)

func death():
	$Dying.play()
	animated_sprite.hide()
	
	var angle = 0
	
	while angle < 2*PI:
		blasty(Vector2(cos(angle),sin(angle)))
		angle += PI/4
	
	while angle < 4*PI:
		blasty(Vector2(cos(angle)/2,sin(angle)/2))
		angle += PI/2
	
func blasty(angle):
	var elem = blastelem.instantiate()
	elem.direction = angle
	elem.position = position
	get_parent().add_child(elem)
