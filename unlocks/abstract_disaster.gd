extends AbstractUnlock
class_name AbstractDisaster
#####################################
# in addition to variables and functions from abstract_unlock, implementation needs to implement these
var description_3 = "MISSING_TEXT"


func checkResolve() -> bool:
	# test if disaster should be resolved
	# depends on implementation
	# alternatively, implementation could leave this as is and implement resolving through signal in ready
	return false


func resolve():
	pass


func save_game():
	var save_data = super.save_game()
	save_data["description_3"] = description_3
	return save_data


# end of implement requiring functions
######################################


func load_game(save_data):
	description_3 = save_data["description_3"]
	super.load_game(save_data)


func _draw():
	if unlock_state == Enums.unlock_state.LOCKED:
		visible = true
		text = "%s to trigger %s\nTo prevent it, %s" % [description_1, description_2, description_3]
	elif unlock_state == Enums.unlock_state.UNLOCKED:
		visible = true
		text = "To stop %s, %s" % [description_2, description_3]
	else:
		visible = false


func tick():
	super.tick()
	if checkResolve():
		resolve()
		_draw()
