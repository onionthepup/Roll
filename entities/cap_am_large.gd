extends Pickup

func healing():
	if roll.full():
		heal = 0
	else:
		roll.fill(1)
		heal -= 1
		if not sound.playing:
			sound.play()
