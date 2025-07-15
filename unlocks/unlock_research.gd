extends AbstractUnlock

class_name UnlockResearch


func checkVisible() -> bool:
	return Population.population_total >= 500


func checkUnlock() -> bool:
	return Population.population_total >= 2000


func unlock() -> void:
	GlobalSignals.unlock_section.emit(Enums.UnlockableSections.RESEARCH)
	GlobalSignals.unlock_research.emit(Enums.research_type.WOODCUTTING)
	GlobalSignals.unlock_research.emit(Enums.research_type.FIBERS)
	GlobalSignals.unlock_research.emit(Enums.research_type.BONES)
	GlobalSignals.unlock_research.emit(Enums.research_type.DOGS)


func _ready() -> void:
	description_1 = "Reach 3000 population"
	description_2 = "Research"
