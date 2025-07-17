extends AbstractDisaster

class_name DisasterCompetition


func checkVisible() -> bool:
	return TopBar.year >= 100


func checkUnlock() -> bool:
	return TopBar.year >= 500


func unlock() -> void:
	GlobalSignals.start_crisis.emit(Enums.crises.COMPETITION)


func resolve():
	GlobalSignals.end_crisis.emit(Enums.crises.COMPETITION)


func resolve_by_signal(age: int):
	if age == Enums.ages.SETTLED:
		unlock_state = Enums.unlock_state.RESOLVED
		resolve()


func _ready() -> void:
	description_1 = "Reach year 500"
	description_2 = "lack of natural resources due to other nomads"
	description_3 = "research farming to settle down"
	GlobalSignals.change_age.connect(resolve_by_signal)
