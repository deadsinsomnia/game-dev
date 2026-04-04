extends CharacterBody2D

@export var speed: float = 100.0
@export var gravity: float = 900.0

var direction: int = 1
var turning: bool = false

@onready var floor_ray = $FloorRay
@onready var sprite = $Sprite2D

func _ready():
	randomize()
	direction = [-1, 1].pick_random()

func _physics_process(delta):

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	velocity.x = direction * speed

	move_and_slide()

	# Only turn if not already turning
	if not turning:
		if is_on_wall() or not floor_ray.is_colliding():
			turn_around()


func turn_around():
	turning = true
	
	direction *= -1
	sprite.flip_h = direction < 0
	floor_ray.position.x *= -1

	# Push slightly away from wall to prevent glitch
	position.x += direction * 2

	# Small delay before allowing next turn
	await get_tree().create_timer(0.2).timeout
	turning = false
