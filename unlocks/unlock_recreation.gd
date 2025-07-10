extends AbstractUnlock

class_name UnlockRecreation


func checkVisible() -> bool:
	return Resources.resources[Enums.resource_types.FOOD] >= 2000


func checkUnlock() -> bool:
	return Resources.resources[Enums.resource_types.FOOD] >= 10000


func unlock() -> void:
	GlobalSignals.unlock_job.emit(Enums.jobs.RECREATION)
	GlobalSignals.unlock_resource.emit(Enums.resource_types.CULTURE)


func _ready() -> void:
	description_1 = "Stockpile 1000 food"
	description_2 = "Recreation"
