extends RefCounted
class_name PrestigeUpgrade
# Non-ui part of prestige upgrade. Ui is handled separately, but uses description and cost from this

var title: String
var description: String
var type: int
var cost: int
var apply: Callable
var id: int
var unlocked = false
var enabled = false


func _init(
	_id: int, p_title: String, p_description: String, p_type: int, p_cost: int, p_apply: Callable = func(): pass
):
	id = _id
	title = p_title
	description = p_description
	type = p_type
	cost = p_cost
	apply = p_apply


func load_game(data):
	unlocked = data["unlocked"]
	enabled = data["enabled"]


func save_game():
	return {"unlocked": unlocked, "enabled": enabled}


func apply_if_enabled():
	if enabled:
		apply.call()
