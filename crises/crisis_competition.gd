extends Label
class_name CrisisCompetition
const type = Enums.crises.COMPETITION
var competition = 0
static var effect = 1.0
const reduction_per_tick = 0.002
var ongoing = false


func _ready() -> void:
	GlobalSignals.start_crisis.connect(start_crisis)
	GlobalSignals.end_crisis.connect(end_crisis)
	toggle_visible()


func toggle_visible():
	visible = ongoing


func start_crisis(_type: int):
	if type == _type:
		ongoing = true
		toggle_visible()


func end_crisis(_type: int):
	if type == _type:
		competition = 0
		effect = 1.0
		ongoing = false
		toggle_visible()


func _draw():
	text = (
		"Competition: %s\nReduces land-based jobs capacity to %s%% capacity"
		% [competition, snapped(effect * 100, 0.01)]
	)


func tick():
	if visible:
		competition += 1
		effect = max(0, effect - reduction_per_tick)
		_draw()


func save_game():
	return {"type": type, "competition": competition, "ongoing": ongoing}


func load_game(data_dict):
	competition = int(data_dict["competition"])
	effect = max(0, 1 - reduction_per_tick * competition)
	ongoing = data_dict["ongoing"]
	toggle_visible()
