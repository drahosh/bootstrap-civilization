extends ScrollContainer

################
# How research works:
#      -  VBoxContainer has all research attached to it at startup, sorted with tempting before voluntary
#      -  All start as invisible, when unlocked by signal they set themselves to visible,
#   when complete they go back to invisible
#      - Tick calls tick for each research, but they only do something with it if
#   visible (and enabled through checkbox in case of voluntary)
################

var voluntary_scene = preload("res://Research/voluntary_research.tscn")
var compulsory_scene = preload("res://research/compulsory_research.tscn")


func tick():
	for child in $VBoxContainer.get_children():
		child.tick()


func save_game():
	var to_return = []
	for child in $VBoxContainer.get_children():
		to_return.append(child.save_game())
	return to_return


func load_game(data_array):
	# Both data_array and children should be sorted from lowest to highest
	# We go from lowest to highest research in save and code both, loading when numbers match
	# Skipping one can happen if new research is deleted or added in between code and save versions
	# TODO manage removing effects of research removed in new version
	var child_index = 0
	var array_index = 0
	var code_researches = $VBoxContainer.get_children()
	var child_max_index = len(code_researches) - 1
	var array_max_index = len(data_array) - 1
	while child_index <= child_max_index and array_index <= array_max_index:
		var child_type = code_researches[child_index].research_type
		var save_type = data_array[array_index]["research_type"]
		if child_type == save_type:
			code_researches[child_index].load_game(data_array[array_index])
			array_index += 1
			child_index += 1
			continue
		if child_type > save_type:
			array_index += 1
			continue
		if child_type < save_type:
			child_index += 1
			continue


func _ready():
	# Attaches all researches as children, in order defined by enum
	# They start as invisible
	# TODO make sure it doesn't ruin performance
	for research_type in Enums.research_type.values():
		var script = Enums.research_type_to_class[research_type]
		var instance
		if research_type < 0:
			instance = compulsory_scene.instantiate()
		if research_type > 0:
			instance = voluntary_scene.instantiate()
		instance.set_script(script)
		$VBoxContainer.add_child(instance)


func reset():
	for child in $VBoxContainer.get_children():
		child.reset()


func hard_reset():
	for child in $VBoxContainer.get_children():
		child.free()
	_ready()
