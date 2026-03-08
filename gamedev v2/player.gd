extends CharacterBody2D

@export var speed = 100
@export var jump_velocity = -300
@export var gravity = 900

@export var dodge_speed = 150
@export var dodge_time = 0.2

@export var attack1_damage = 20
@export var attack2_damage = 35

@onready var sprite = $AnimatedSprite2D
@onready var attack_area = $attackarea

@onready var healthbar = $HealthBar

var health = 100
var is_dodging = false
var dodge_timer = 0.0
var dodge_direction = 0

var attacking = false
var hurt = false
var dead = false
var current_damage = 0
var respawn_position = Vector2.ZERO

func _ready():
	attack_area.monitoring = false
	respawn_position = global_position

	attack_area.monitoring = false
	respawn_position = global_position

	healthbar.max_value = 100
	healthbar.value = health

func _physics_process(delta):

	if dead or hurt:
		move_and_slide()
		return

	# ATTACK INPUT
	if Input.is_action_just_pressed("attack1") and not attacking:
		attack1()

	if Input.is_action_just_pressed("attack2") and not attacking:
		attack2()

	if attacking:
		velocity.x = 0
		move_and_slide()
		return


	if is_dodging:
		dodge_timer -= delta
		velocity.x = dodge_direction * dodge_speed
		sprite.play("dodge")

		if dodge_timer <= 0:
			is_dodging = false

	else:

		if not is_on_floor():
			velocity.y += gravity * delta

		var direction = 0

		if Input.is_key_pressed(KEY_A):
			direction -= 1
		if Input.is_key_pressed(KEY_D):
			direction += 1

		velocity.x = direction * speed

		if direction != 0:
			sprite.flip_h = direction < 0
			sprite.play("walk")
		else:
			sprite.play("idle")

		if Input.is_key_pressed(KEY_SHIFT) and direction != 0:
			is_dodging = true
			dodge_timer = dodge_time
			dodge_direction = direction


	if Input.is_key_pressed(KEY_W) and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()


# ---------------- ATTACK 1 ----------------
func attack1():

	attacking = true
	current_damage = attack1_damage

	sprite.play("attack1")

	attack_area.monitoring = true
	await sprite.animation_finished
	attack_area.monitoring = false

	attacking = false


# ---------------- ATTACK 2 ----------------
func attack2():

	attacking = true
	current_damage = attack2_damage

	sprite.play("attack2")

	attack_area.monitoring = true
	await sprite.animation_finished
	attack_area.monitoring = false

	attacking = false


# ---------------- DAMAGE ENEMY ----------------
func _on_attackarea_body_entered(body):

	if body.is_in_group("enemy"):
		body.take_damage(current_damage)


# ---------------- PLAYER TAKES DAMAGE ----------------
func take_damage(amount):

	if dead:
		return

	health -= amount

	healthbar.value = health

	print("Player health:", health)

	hurt = true
	sprite.play("hurt")

	await sprite.animation_finished

	hurt = false

	if health <= 0:
		die()


# ---------------- PLAYER DEATH ----------------
func die():

	dead = true
	sprite.play("death")

	await sprite.animation_finished

	global_position = respawn_position
	health = 100
	healthbar.value = health

	dead = false
