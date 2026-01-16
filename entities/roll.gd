extends Entity
class_name Roll

@onready var animated_sprite : AnimatedSprite2D = $Sprite
@onready var landsound : AudioStreamPlayer = $Landing
@onready var bustersound : AudioStreamPlayer = $Shooting
@onready var hurtsound : AudioStreamPlayer = $Hurting
@onready var lifebar : Sprite2D = $Canvas/LifePips
@onready var subscreen : TileMap = $Canvas/subscreen
@onready var ammobar : Sprite2D = $Canvas/AmmoPips
@onready var ammobarbg : Sprite2D = $Canvas/AmmoBar

var bullet = preload("res://entities/bullet.tscn")
var blastelem = preload("res://entities/blastelem.tscn")

var flame = preload("res://entities/flame.tscn")
var machbullet = preload("res://entities/mgun.tscn")
var thrownaxe = preload("res://entities/axe.tscn")
var madeblock = preload("res://entities/block.tscn")

var palette0 = preload("res://palettes/roll0.png")
var palette1 = preload("res://palettes/roll1.png")
var palette2 = preload("res://palettes/roll2.png")
var palette3 = preload("res://palettes/roll3.png")
var palette4 = preload("res://palettes/roll4.png")
var palette5 = preload("res://palettes/roll5.png")
var palette6 = preload("res://palettes/roll6.png")
var palette7 = preload("res://palettes/roll7.png")
var palette8 = preload("res://palettes/roll8.png")
var palettes = [palette0,palette1,palette2,palette3,palette4,palette5,palette6,palette5,palette8]

#movement vars
var direction = 0
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

#lifting block vars
var lifting = false
var liftblock
var throwanim = 0.0
var throwout = 0.25

var takes_input = true #whether player can input anything!

var beaming = false
var firstbeam = false

@onready var checkpoint = global_position

#var hp = 28
var ammo = [28,-1,28,28,-1,-1,28,-1,28]
var ammocost = [0,0,1,0.5,0,0,2,0,4]

var weaponlist = [Roll_Buster.new(), Power_Shot.new(), NeedleShot.new(), null]
var equipped = 0

#color attempt
#var dress = Color8(216,40,0) #AKA nesred
#var ribbon = Color8(0,144,56) #AKA nesgreen
#var hair = Color8(248,184,0)
#
#var nesyellow = Color8(240,188,60)
#var nesdgray = Color8(116,116,116)
#var nespurple = Color8(128,0,240)
#var neslgray = Color8(188,188,188)
#var nesblue = Color8(0,112,236)
#var nesbrown = Color8(200,76,12)
#
#var redred = Color8(255,0,0)
#var greengreen = Color8(0,255,0)
#var blueblue = Color8(0,0,255)

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn()
	hp = 28
	updatehp()
	updateammo()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	adjust_camera()
	if Input.is_action_just_pressed("pause") and takes_input:
		subscreen.start(self)

func _physics_process(delta):
	leastfull()
	
	#beaming in anim
	if beaming and is_on_floor():
		if firstbeam:
			firstbeam = false
		else:
			beaming = false
			takes_input = true
	
	if hurttime > 0:
		animated_sprite.visible = not animated_sprite.visible
		if hurttime < (invin-hurtanim):
			takes_input = true
		hurttime -= delta
		if hurttime <= 0:
			set_collision_layer_value(5,true)
			animated_sprite.visible = true
	
	# get on ladders, detect when NOT on ladder
	if $LadderDetector.has_overlapping_bodies():
		if Input.is_action_pressed("up") and takes_input:
			on_ladder = true
			position.x = 16 * round((position.x+8)/16) - 8
	else:
		on_ladder = false
	
	#get down on ladder
	if $UnderLadderDetector.has_overlapping_bodies() and not $LadderDetector.has_overlapping_bodies() and Input.is_action_pressed("down"):
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
		if takes_input:
			landsound.play()
	
	#headbonk
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and takes_input and not lifting:
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
	if takes_input and (Input.is_action_just_pressed("shoot") or (Input.is_action_pressed("shoot") and equipped == 3)):
		shoot()
	
	if busteranim > 0:
		busteranim -= delta
		if on_ladder:
			velocity.y = 0
	
	if throwanim > 0:
		throwanim -= delta
		velocity.x = 0
	
	#hurt movement
	if hurttime > (invin-hurtanim):
		velocity.x = direction * -45
		velocity.y += gravity * delta / 2
	
	if beaming:
		velocity.y = 960.0
	
	move_and_slide()
	update_animation()
	
func update_animation():
	var state = ""
	if busteranim > 0:
		state = "_shoot"
	elif throwanim > 0:
		state = "_throw"
	elif lifting:
		state = "_lift"
	#can add _climb and _throw states!
	
	if beaming:
		change_animation("beam")
	elif throwanim > 0:
		change_animation("idle_throw")
	elif hurttime > (invin-hurtanim):
		change_animation("hurt")
	elif on_ladder:
		change_animation("climb" + state)
		if velocity.y == 0:
			animated_sprite.pause()
		else:
			animated_sprite.play()
			if $LadderDetector.has_overlapping_bodies() and not $UpperLadderDetector.has_overlapping_bodies():
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
#	elif busteranim > 0:
#		change_animation("shoot") #animated_sprite.play("shoot")
#	else:
#		animated_sprite.play("idle")
	else:
		change_animation("idle" + state)
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
	adjust_muzzle()

#func recolor(dresscolor, ribboncolor, pocketcolor = ribboncolor):
	#pass

func recolor(palette):
	$Sprite.material.set_palette(palettes[palette])

func adjust_camera():
	if position.y < $Camera.limit_top:
		$Camera/CameraControl.adjust(-1)
	elif position.y > $Camera.limit_bottom:
		$Camera/CameraControl.adjust(1)

func adjust_camera_quick():
	while position.y < $Camera.limit_top:
		$Camera.limit_top -= 240
		$Camera.limit_bottom -= 240
	while position.y > $Camera.limit_bottom:
		$Camera.limit_top += 240
		$Camera.limit_bottom += 240
	
func spawn():
	#hp needs to be invisible
	hp = maxhp
	updatehp()
	takes_input = false
	animated_sprite.visible = false
	global_position = checkpoint
	adjust_camera_quick()
	$Canvas/READYTOROLL.visible = true
	await get_tree().create_timer(3.0).timeout
	$Canvas/READYTOROLL.visible = false
	global_position.y = $Camera.limit_top
	beaming = true
	firstbeam = true
	animated_sprite.visible = true

func check_beam():
	takes_input = true

func jump():
	velocity.y = -jumpspeed

func shoot():
	#this will check for equipped weapon etc.
	adjust_muzzle()
	if ammo[equipped] < ammocost[equipped] and equipped != 8:
		return
	match equipped:
		0: #r.buster
			var blts = get_tree().get_nodes_in_group("bullets").size()
			if blts < 3 && busteranim < 0.15: #must be 0.1s after shooting; shoot every 6 frames
				buster()
		2: #f.blast
			var blts = get_tree().get_nodes_in_group("bullets").size()
			if blts < 3 && busteranim < 0.15: #must be 0.1s after shooting; shoot every 6 frames
				ammo[equipped] -= ammocost[equipped]
				updateammo()
				flamethrower()
		3: #machinegun
			var blts = get_tree().get_nodes_in_group("bullets").size()
			if blts < 5 && busteranim < 0.16: #must be 0.1s after shooting; shoot every 6 frames
				ammo[equipped] -= ammocost[equipped]
				updateammo()
				machinegun()
		6: #axe
			var blts = get_tree().get_nodes_in_group("bullets").size()
			if blts < 1 && busteranim < 0.15: #must be 0.1s after shooting; shoot every 6 frames
				ammo[equipped] -= ammocost[equipped]
				updateammo()
				axe()
		8: #block!
			if lifting: #throws a block!
				throw_block()
			elif not $BlockArea.has_overlapping_bodies(): #makes a block!
				if ammo[equipped] < ammocost[equipped]:
					return
				ammo[equipped] -= ammocost[equipped]
				updateammo()
				makeblock()
			elif is_on_floor() and not lifting: #lifts a block!
				for body in $BlockArea.get_overlapping_bodies():
					if body is Block:
						body.lifted(self, $CarryBlock.position)
						lifting = true
						liftblock = body
						return
	
func adjust_muzzle():
	if animated_sprite.flip_h:
		$Muzzle.position.x = -16
		$BlockArea.position.x = -60
	else:
		$Muzzle.position.x = 16
		$BlockArea.position.x = 0
	
	if is_on_floor():
		$Muzzle.position.y = 5
	else:
		$Muzzle.position.y = -1
	
func buster():
	bustersound.play()
	busteranim = busterout
	
	var blt = bullet.instantiate()
	
	if animated_sprite.flip_h:
		blt.direction = -1
	
	blt.position = $Muzzle.global_position
	
	get_parent().add_child(blt)
	blt.add_to_group("bullets")

func flamethrower():
	$Flame.play()
	busteranim = busterout
	
	var fire = flame.instantiate()
	#var fire2 = flame.instantiate()
	
	if animated_sprite.flip_h:
		fire.direction = -1
		#fire2.direction = -1
	
	fire.position = $Muzzle.global_position
	#fire2.position = $Muzzle.global_position
	
	#fire.angle = PI/2
	
	#fire2.angle = PI
	#fire2.SPEED *= 1.1
	#fire2.YSPEED *= 0
	
	get_parent().add_child(fire)
	#get_parent().add_child(fire2)
	fire.add_to_group("bullets")
	#fire2.add_to_group("bullets")

func machinegun():
	bustersound.play()
	busteranim = busterout
	
	var blt = machbullet.instantiate()
	
	var spray = randi_range(-3,2)
	
	if animated_sprite.flip_h:
		blt.direction = -1
	
	blt.position = $Muzzle.global_position
	blt.position.y += spray
	
	get_parent().add_child(blt)
	blt.add_to_group("bullets")

func axe():
	bustersound.play()
	busteranim = busterout
	
	var ax = thrownaxe.instantiate()
	
	if animated_sprite.flip_h:
		ax.direction = -1
	
	ax.position = $Muzzle.global_position
	
	get_parent().add_child(ax)
	ax.add_to_group("bullets")

func makeblock():
	var block = madeblock.instantiate()
	
	block.position = $BlockArea/BlockSpawn.global_position
	
	get_parent().add_child(block)

func throw_block():
	throwanim = throwout
	
	if animated_sprite.flip_h:
		liftblock.direction = -1
		
	liftblock.reparent(get_parent())
		
	liftblock.add_to_group("bullets")
	
	liftblock.thrown()
	
	liftblock = null
	lifting = false

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

func fill(value):
	if ammo[equipped] < 28:
		ammo[equipped] += value
		updateammo()
	else:
		ammo[leastfull()] += value

func leastfull(): #returns ID of weapon with least ammo
	var ammofilter = ammo.filter(func(element): return element != -1)
	var min = ammofilter.min()
	for i in range(9):
		if ammo[i] == min:
			return i

func full(): #check if all weapons full
	for i in range(9):
		if ammo[i] > -1 and ammo[i] < 28:
			return false
	return true

func updatehp():
	lifebar.region_rect = Rect2(0,56-2*hp,6,2*hp)
	lifebar.position.y = 108 - 2*hp
	lifebar.region_enabled = true

#maybe do ceiling of ammo to better reflect mgun
func updateammo():
	if equipped == 0:
		ammobarbg.visible = false
	else:
		ammobarbg.visible = true
	ammobar.frame = equipped
	ammobar.region_rect = Rect2(0,56-2*ammo[equipped],54,2*ammo[equipped])
	ammobar.position.y = 108 - 2*ammo[equipped]
	ammobar.region_enabled = true
	
#still playing landing sound
func death():
	takes_input = false
	velocity = Vector2.ZERO
	$Dying.play()
	animated_sprite.hide()
	
	var angle = 0
	
	while angle < 2*PI:
		blasty(Vector2(cos(angle),sin(angle)))
		angle += PI/4
	
	while angle < 4*PI:
		blasty(Vector2(cos(angle)/2,sin(angle)/2))
		angle += PI/2
	
	await get_tree().create_timer(2.0).timeout
	spawn()

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
