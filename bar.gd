extends Sprite2D

var pip = preload("res://barpip.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func bar(value):
	for n in get_children():
		n.queue_free()
	
	while(value > 0):
		var barpip = pip.instantiate()
		barpip.position = position + Vector2(-28,-23-value*2)
		add_child(barpip)
		value -= 1
