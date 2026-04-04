extends Node

@onready var battle = $battle
@onready var bg = $bg

func battlemusic():
	if bg and bg.playing:
		bg.stop()
	if battle:
		battle.play()

func bgmusic():
	if battle and battle.playing:
		battle.stop()
	if bg:
		bg.play()
