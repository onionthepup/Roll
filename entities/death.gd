extends AnimatedSprite2D

func _ready():
	animation_finished.connect(end)

func end():
	self.queue_free()
