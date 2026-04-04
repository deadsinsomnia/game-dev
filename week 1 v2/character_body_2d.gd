extends CharacterBody2D

@export var speed = 250.0
@export var acceleration = 1200.0
@export var friction = 1500.0

@export var jump_force = -400.0
@export var gravity = 1000.0

@export var dodge_speed = 300.0
@export var dodge_duration = 0.18
@export var dodge_cooldown = 0.5

var is_dodging = false
var dodge_timer = 0.0
var cooldown_timer = 0.0
var dodge_direction = 1
var air_dodge_available = true

func _physics_process(delta):
	if is_on_floor():
		air_dodge_available = true

	if not is_on_floor() and not is_dodging:
		velocity.y += gravity * delta

	if cooldown_timer > 0:
		cooldown_timer -= delta

	var direction = Input.get_axis("LEFT", "RIGHT")

	if direction != 0:
		dodge_direction = direction

	if Input.is_action_just_pressed("dodge") and not is_dodging and cooldown_timer <= 0 and (is_on_floor() or air_dodge_available):
		is_dodging = true
		dodge_timer = dodge_duration
		cooldown_timer = dodge_cooldown
		if not is_on_floor():
			air_dodge_available = false

	if is_dodging:
		velocity.x = dodge_direction * dodge_speed
		velocity.y = 0
		dodge_timer -= delta
		if dodge_timer <= 0:
			is_dodging = false
	else:
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)

	if Input.is_action_just_pressed("UP") and is_on_floor() and not is_dodging:
		velocity.y = jump_force

	move_and_slide()

	# Check collisions and disappear if touching an enemy
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("enemy"):
			queue_free()
