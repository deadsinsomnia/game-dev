extends CanvasLayer

@onready var anim = $AnimationPlayer

func fade_to_scene(scene_path: String) -> void:
	anim.play("fade_out")
	await anim.animation_finished

	var tree = get_tree()
	tree.change_scene_to_file(scene_path)

	# Wait a tiny bit so the new scene is fully loaded
	await tree.create_timer(0.05).timeout

	anim.play("fade_in")
