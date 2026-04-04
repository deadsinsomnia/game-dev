extends Area2D

@export var next_scene: String = "res://level_2.tscn"
@export var transition_path: NodePath

@onready var transition = get_node(transition_path)
@onready var open: AudioStreamPlayer2D = $open

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Switching to:", next_scene)
		transition.fade_to_scene(next_scene)
		open.play()
