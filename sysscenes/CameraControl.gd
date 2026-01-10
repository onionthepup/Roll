extends Node2D

var scrollstep = 0
var change = 0
var operating = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not operating:
		return
	
	get_parent().limit_top += scrollstep
	get_parent().limit_bottom += scrollstep
	change -= scrollstep
	
	if change == 0:
		operating = false
		scrollstep = 0
		get_tree().paused = false

func adjust(value):
	get_tree().paused = true
	operating = true
	change = value * 240
	scrollstep = value * 4
