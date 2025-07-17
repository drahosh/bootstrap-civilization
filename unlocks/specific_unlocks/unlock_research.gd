extends AbstractUnlock

class_name UnlockResearch


func checkVisible() -> bool:
	return Population.population_total >= 500 or TopBar.year >= 500


func checkUnlock() -> bool:
	return Population.population_total >= 1000 or TopBar.year >= 550


func unlock() -> void:
	GlobalSignals.unlock_section.emit(Enums.UnlockableSections.RESEARCH)
	GlobalSignals.unlock_research.emit(Enums.research_type.WOODCUTTING)
	GlobalSignals.unlock_research.emit(Enums.research_type.FIBERS)
	GlobalSignals.unlock_research.emit(Enums.research_type.BONES)
	GlobalSignals.unlock_research.emit(Enums.research_type.DOGS)


func _ready() -> void:
	description_1 = "Reach 1000 population or year 550"
	description_2 = "Research"
