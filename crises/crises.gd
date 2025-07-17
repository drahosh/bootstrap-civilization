extends VBoxContainer

# originally wanted to also make AbstractCrisis class, but realized they are too diverse to make a useful prototype for


func _ready() -> void:
	# Add all crises as children (they start invisible)
	add_child(CrisisCompetition.new())


func reset():
	for child in get_children():
		child.free()
	_ready()


func save_game():
	var list = []
	for child in get_children():
		list.append(child.save_game())
	return list


func load_game(list):
	for child in get_children():
		child.free()
	for dict in list:
		var type = int(dict["type"])
		var child = Enums.crisis_to_class[type].new()
		child.load_game(dict)
		add_child(child)


func tick():
	for child in get_children():
		child.tick()
