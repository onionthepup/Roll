extends Pickup

func _init():
	heal = 2

func healing():
	if roll.hp == 28:
		heal = 0
	else:
		roll.heal(1)
		heal -= 1
		if not sound.playing:
			sound.play()
