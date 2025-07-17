extends VBoxContainer

class_name Unlocks


func _ready() -> void:
	reset()


func reset():
	for child in get_children():
		child.free()
	# Create all disasters and unlocks
	# Disasters:
	add_child(DisasterCompetition.new())
	# Unlocks:
	add_child(UnlockClothesmaking.new())
	add_child(UnlockRecreation.new())
	add_child(UnlockUpgrades.new())
	add_child(UnlockResearch.new())


func tick():
	for child in get_children():
		child.tick()


func save_game():
	var list = []
	for child in get_children():
		list.append(child.save_game())
	return list


func load_game(list):
	for child in get_children():
		child.free()
	for dict in list:
		var className = dict["class_name"]
		var child = Enums.unlock_name_to_class[className].new()
		child.load_game(dict)
		add_child(child)
