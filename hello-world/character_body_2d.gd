extends CharacterBody2D

var speed := 300

func _physics_process(_delta):
	# Get input vector
	var dir = Vector2(
		Input.get_action_strength("RIGHT") - Input.get_action_strength("LEFT"),
		Input.get_action_strength("DOWN") - Input.get_action_strength("UP")
	)

	# Normalize to prevent faster diagonal movement
	if dir != Vector2.ZERO:
		dir = dir.normalized()

	# Apply movement
	velocity = dir * speed
	move_and_slide()
