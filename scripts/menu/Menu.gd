extends Control

func _ready():
	$FileDialog.add_filter("*.adofai","ADOFAI Maps")
	$FileDialog.file_selected.connect(file_selected)
	$FileDialog.canceled.connect($FileDialog.popup_centered)
	$FileDialog.popup_centered()

func file_selected(path:String):
	var map:Map = MapReader.read_from_file(path)
	if map:
		var scene = Globals.generate_scene(map)
		get_tree().change_scene(scene)
		return
	$FileDialog.popup_centered()
