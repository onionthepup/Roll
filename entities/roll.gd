extends Entity

var direction = Vector2.ZERO
@onready var animated_sprite : AnimatedSprite2D = $Sprite
@onready var landsound : AudioStreamPlayer = $Landing
@onready var bustersound : AudioStreamPlayer = $Shooting
@onready var hurtsound : AudioStreamPlayer = $Hurting
@onready var lifebar : Sprite2D = $Canvas/LifePips

var bullet = preload("res://entities/bullet.tscn")
var blastelem = preload("res://entities/blastelem.tscn")

#movement vars
var speed = 82.5   #1.6
var airspeed = 78.75
var jumpspeed = 294.375   #4.DF in 1~2, or 4.A5 in 3, or 4.C0 in 4
var accelspeed = 15.0 #was 0.2->7.5; average of rockman3 is 8.65
var acceltime = 0.116 #7; time spent in accel
var accelcount = 0
var in_air = false

#ladder vars
var climbspeed = 77.8125 #climb speed in 1-2: 45; in 3: 77.8125
var on_ladder = false
var ladderclimb = Vector2.ZERO

#bullet vars
var bulletspeed = 240 #4 pixels/frame
var busterout = 0.25 #buster stays out 15 frames
var busteranim = 0.0

#take-damage vars
var hurtanim = 0.4 #time spent recoiling from dmg
var invin = 1 #time of i-frames/flashing gained
var hurttime = 0 #timer

var takes_input = true #whether player can input anything!

#var hp = 28
var ammo = [28,-1,-1,-1,-1,-1,-1,-1,-1]

var weaponlist = [Weapon.new(), Power_Shot.new(), NeedleShot.new(), null]
var equipped = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	hp = 28
	updatehp()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if position.y < $Camera.limit_top:
		$Camera/CameraControl.adjust(-1)
	elif position.y > $Camera.limit_bottom:
		$Camera/CameraControl.adjust(1)

func _physics_process(delta):
	if hurttime > 0:
		animated_sprite.visible = not animated_sprite.visible
		if hurttime < (invin-hurtanim):
			takes_input = true
		hurttime -= delta
		if hurttime <= 0:
			set_collision_layer_value(5,true)
			animated_sprite.visible = true
	
	# get on ladders, detect when NOT on ladder
	if $LadderDetector.is_colliding() or $UpperLadderDetector.is_colliding():
		if Input.is_action_pressed("up") and takes_input:
			on_ladder = true
			position.x = 16 * round((position.x+8)/16) - 8
	else:
		on_ladder = false
	
	#get down on ladder
	if $UnderLadderDetector.is_colliding() and not $LadderDetector.is_colliding() and Input.is_action_pressed("down"):
		position.x = 16 * round((position.x+8)/16) - 8
		position.y -= 1
		on_ladder = true
		self.set_collision_mask_value(1,false) #sets collision to 0 to be able to get to the top of ladders
	
	#sets collision back to 1 after climbing a ladder
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
	if Input.is_action_just_pressed("jump") and takes_input:
		if is_on_floor():
			jump()
		elif on_ladder:
			on_ladder = false
			velocity.y = 0
	
	# fall quicker when you let go of jump
	if Input.is_action_just_released("jump") and velocity.y < -127.265625 and takes_input:
		velocity.y = -60
	
	#handle walking
	if takes_input:
		direction = Input.get_axis("left", "right")
	if direction and takes_input:
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
	if on_ladder and takes_input:
		velocity.x = 0
		ladderclimb = Input.get_axis("up", "down")
		velocity.y = ladderclimb * climbspeed
	
	#handle shooting
	if Input.is_action_just_pressed("shoot") and takes_input:
		shoot()
	
	if busteranim > 0:
		busteranim -= delta
		if on_ladder:
			velocity.y = 0
	
	#hurt movement
	if hurttime > (invin-hurtanim):
		velocity.x = direction * -45
		velocity.y += gravity * delta / 2
	
	move_and_slide()
	update_animation()
	
func update_animation():
	var state = ""
	if busteranim > 0:
		state = "_shoot"
	#can add _climb and _throw states!
	
	
	if hurttime > (invin-hurtanim):
		change_animation("hurt")
	elif on_ladder:
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

func damage(value, pos = null):
	hp = move_toward(hp,0,value)
	updatehp()
	if hp == 0:
		death()
	else:
		hurt(pos)

#hurt animation and invin. frames
func hurt(pos = null):
	hurttime = invin
	hurtsound.play()
	set_collision_layer_value(5,false)
	takes_input = false
	if pos:
		if pos > global_position.x:
			direction = 1
		else:
			direction = -1
	velocity.x = 0
	velocity.y = 0

func heal(value):
	hp += value
	if hp > maxhp:
		hp = maxhp
	updatehp()

func updatehp():
	lifebar.region_rect = Rect2(0,56-2*hp,6,2*hp)
	lifebar.position.y = 108 - 2*hp
	lifebar.region_enabled = true

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

func blasty(angle): #death animation
	var elem = blastelem.instantiate()
	elem.direction = angle
	elem.position = position
	get_parent().add_child(elem)

class RollBuster:
	var id = 0
	var cost = 0
	
#	var bustersound = $Shooting
#
#	func shoot():
#		bustersound.play()
#		busteranim = busterout
#
#		var blt = bullet.instantiate()
#
#		if animated_sprite.flip_h:
#			$Muzzle.position.x = -16
#			blt.direction = -1
#		else:
#			$Muzzle.position.x = 16
#
#		if is_on_floor():
#			$Muzzle.position.y = 5
#		else:
#			$Muzzle.position.y = -1
#
#		blt.position = $Muzzle.global_position
#
#		get_parent().add_child(blt)
#		blt.add_to_group("bullets")
	
class NeedleShot:
	var id = 1
	var cost = 0.25



