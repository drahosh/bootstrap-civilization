extends AbstractUnlock

class_name UnlockUpgrades


func checkVisible() -> bool:
	return Population.population_total >= 800


func checkUnlock() -> bool:
	return Resources.resources[Enums.resource_types.CULTURE] >= 100


func unlock() -> void:
	GlobalSignals.unlock_section.emit(Enums.UnlockableSections.UPGRADES)


func _ready() -> void:
	description_1 = "Amass 100 culture"
	description_2 = "Job Upgrades"
