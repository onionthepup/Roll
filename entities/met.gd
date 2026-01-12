extends Enemy

func _ready():
	maxhp = 4
	hp = 4
	$Sprite.material = ShaderMaterial.new()
