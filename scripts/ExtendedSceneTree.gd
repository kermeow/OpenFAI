extends SceneTree
class_name ExtendedSceneTree

func change_scene(scene):
	if scene is String:
		var node = load(scene) as PackedScene
		if node == null: return
		call_deferred("set_scene",node)
	elif scene is PackedScene:
		call_deferred("set_scene",scene.instantiate())
	elif scene is Node:
		call_deferred("set_scene",scene)
func set_scene(scene:Node):
	paused = true
	unload_current_scene()
	root.add_child(scene)
	scene.owner = root
	current_scene = scene
	scene.request_ready()
	paused = false
