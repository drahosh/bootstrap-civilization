extends AbstractUnlock

class_name UnlockUpgrades


func checkVisible() -> bool:
	return Population.population_total >= 500


func checkUnlock() -> bool:
	return Resources.resources[Enums.resource_types.CULTURE] >= 200


func unlock() -> void:
	GlobalSignals.unlock_section.emit(Enums.UnlockableSections.UPGRADES)


func _ready() -> void:
	description_1 = "Amass 200 culture"
	description_2 = "Job Upgrades"
