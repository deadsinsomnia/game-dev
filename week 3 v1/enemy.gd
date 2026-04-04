extends CharacterBody2D

@export var speed = 60
@export var gravity = 900

@export var max_health = 100
@export var damage = 20
@export var attack_cooldown = 1.5
@export var hurt_stun_time = 0.4

@export var patrol_distance = 100
@export var patrol_speed = 40

@export var knockback_force = 200


var start_position
var patrol_direction = 1

var health = 0
var player: Node2D = null

var attacking = false
var can_attack = true
var hurt = false
var dead = false

@onready var sprite = $AnimatedSprite2D
@onready var healthbar = $HealthBar
@onready var detection_area = $enemydetection
@onready var attack_area = $enemyattack
@onready var atk_1: AudioStreamPlayer2D = $atk1
@onready var dth: AudioStreamPlayer2D = $dth
@onready var dmg: AudioStreamPlayer2D = $dmg
@onready var battle: AudioStreamPlayer2D = $battle
@onready var MusicManager = get_node("/root/MusicManager")

func _ready():
	start_position = global_position
	health = max_health

	if healthbar != null:
		healthbar.max_value = max_health
		healthbar.value = health


func _physics_process(delta):

	if dead or hurt:
		move_and_slide()
		return

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# ---------------- ATTACK ----------------
	if attacking:
		velocity.x = 0

	# ---------------- CHASE PLAYER ----------------
	elif player != null:

		var direction = sign(player.global_position.x - global_position.x)

		velocity.x = direction * speed
		sprite.flip_h = direction < 0

		if sprite.animation != "walk":
			sprite.play("walk")

	# ---------------- PATROL ----------------
	else:

		var distance = global_position.x - start_position.x

		if abs(distance) > patrol_distance or is_on_wall():
			patrol_direction *= -1

		velocity.x = patrol_direction * patrol_speed
		sprite.flip_h = patrol_direction < 0

		if sprite.animation != "walk":
			sprite.play("walk")

	move_and_slide()


# ---------------- DETECT PLAYER ----------------
func _on_enemydetection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		MusicManager.battlemusic()
		

func _on_enemydetection_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		MusicManager.bgmusic()


# ---------------- ATTACK RANGE ----------------
func _on_enemyattack_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		try_attack()


func _on_enemyattack_body_exited(body: Node2D) -> void:
	if body == player:
		player = null


# ---------------- TRY ATTACK ----------------
func try_attack():

	if player == null:
		return

	if can_attack and not attacking and not hurt:
		attack()


# ---------------- ATTACK ----------------
func attack():

	if dead or hurt:
		return

	attacking = true
	can_attack = false

	velocity.x = 0
	sprite.play("enemyattack")
	atk_1.play()

	await sprite.animation_finished

	if player != null and player.has_method("take_damage"):
		player.take_damage(damage)

	attacking = false

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

	if player != null:
		try_attack()


# ---------------- TAKE DAMAGE ----------------
func take_damage(amount):

	if dead:
		return

	health -= amount

	if healthbar != null:
		healthbar.value = health

	hurt = true
	can_attack = false

	sprite.play("hurt")
	dmg.play()

	if player != null:
		var direction = sign(global_position.x - player.global_position.x)
		

	await sprite.animation_finished

	# stun delay
	await get_tree().create_timer(hurt_stun_time).timeout

	hurt = false
	can_attack = true

	if health <= 0:
		die()


# ---------------- DEATH ----------------
func die():

	dead = true
	velocity = Vector2.ZERO

	sprite.play("death")
	dth.play()

	await sprite.animation_finished

	queue_free()
