extends Node

func generate_scene(map:Map):
	var scene:GameScene = preload("res://scenes/GameScene.tscn").instantiate()
	scene.map = map
	return scene
