extends CharacterBody2D

@export var speed = 100
@export var jump_velocity = -300
@export var gravity = 900

@export var dodge_speed = 150
@export var dodge_time = 0.2

var is_dodging = false
var dodge_timer = 0.0
var dodge_direction = 0

func _physics_process(delta):

	# Dodge timer
	if is_dodging:
		dodge_timer -= delta
		velocity.x = dodge_direction * dodge_speed
		if dodge_timer <= 0:
			is_dodging = false

	else:
		# Apply gravity
		if not is_on_floor():
			velocity.y += gravity * delta

		# Left / Right movement
		var direction = 0
		if Input.is_key_pressed(KEY_A):
			direction -= 1
		if Input.is_key_pressed(KEY_D):
			direction += 1

		velocity.x = direction * speed

		# Start dodge
		if Input.is_key_pressed(KEY_SHIFT) and direction != 0:
			is_dodging = true
			dodge_timer = dodge_time
			dodge_direction = direction

	# Jump
	if Input.is_key_pressed(KEY_W) and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()
