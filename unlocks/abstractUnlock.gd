extends Label
# generic class, to be extended by specific unlock

class_name AbstractUnlock

var unlock_state: int = Enums.unlock_state.INVISIBLE
var description_1: String = "MISSING TEXT"  # ex. "reach 500 population"
var description_2: String = "MISSING TEXT"  #ex. "Clothmaking"


#####################################
# START OF FUNCTIONS TO IMPLEMENT IN CHILD
func checkVisible() -> bool:
	# test if state should move from INVISIBLE to LOCKED or LOCKED
	return false  # for implementation


func checkUnlock() -> bool:
	# test if should be unlocked
	# depends on implementation
	return false


func unlock() -> void:
	# unlock
	# locking again is handled in the unlocked part itelf
	pass


# END OF FUNCTIONS TO IMPLEMENT IN CHILD
#####################################


func _ready():
	unlock_state = Enums.unlock_state.INVISIBLE
	_draw()


func _draw():
	if unlock_state == Enums.unlock_state.LOCKED:
		visible = true
		text = description_1 + " to unlock " + description_2
	else:
		visible = false


func reset():
	unlock_state = Enums.unlock_state.INVISIBLE
	_draw()


func tick():
	if unlock_state == Enums.unlock_state.INVISIBLE:
		if checkVisible():
			unlock_state = Enums.unlock_state.LOCKED
			_draw()
	if unlock_state == Enums.unlock_state.LOCKED:
		if checkUnlock():
			unlock()
			unlock_state = Enums.unlock_state.UNLOCKED
			_draw()
			# TODO send message to user log


func save_game():
	return {
		"class_name": get_script().get_global_name(),
		"description_1": description_1,
		"description_2": description_2,
		"unlock_state": unlock_state
	}


func load_game(data_dict):
	# assuming that parrent created this class based on class_name
	description_1 = data_dict["description_1"]
	description_2 = data_dict["description_2"]
	unlock_state = data_dict["unlock_state"]
	_draw()
