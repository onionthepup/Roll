extends Pickup

func healing():
	if roll.hp == 28:
		heal = 0
	else:
		roll.heal(1)
		heal -= 1
