extends AnimatedSprite2D

var speed = 180.0
@export var direction = Vector2(0.0,0.0)
var angle = 15

func _process(delta):
	position += speed * direction * delta
	rotateby(angle)
	angle *= 0.90

func rotateby(angle):
	var rad = angle * PI / 180.0
	var x = direction.x * cos(rad) - direction.y * sin(rad)
	direction.y = (direction.x * sin(rad) + direction.y * cos(rad)) * 1.02
	direction.x = x * 1.02

#the original version:
#speed was 120
#angle was 6, and did not change
#direction.x and direction.y got multiplied by 1.08 instead of 1.01
