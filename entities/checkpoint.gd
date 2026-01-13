extends Marker2D

func _ready():
	$Area.body_entered.connect(mark)
	
func mark(body):
	pass
