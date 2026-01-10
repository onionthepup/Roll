extends TileMap

@onready var pausesound : AudioStreamPlayer = $Pausing

var just = false
var operating = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pause") and operating and not just:
		end()
	just = false

func start():
	get_tree().paused = true
	pausesound.play()
	show()
	operating = true
	just = true

func end():
	hide()
	operating = false
	get_tree().paused = false
