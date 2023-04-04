extends Control

func _ready():
	$FileDialog.add_filter("*.adofai","ADOFAI Maps")
	$FileDialog.canceled.connect(get_tree().quit.bind(1))
	$FileDialog.file_selected.connect(file_selected)
	$FileDialog.current_path = ProjectSettings.globalize_path("user://")
	$FileDialog.popup_centered()

func file_selected(path:String):
	var map:Map = MapReader.read_from_file(path)
	if map:
		var scene = Globals.generate_scene(map)
		get_tree().change_scene(scene)
		return
