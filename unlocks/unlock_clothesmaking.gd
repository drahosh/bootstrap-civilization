extends AbstractUnlock

class_name UnlockClothesmaking


func checkVisible() -> bool:
	return true


func checkUnlock() -> bool:
	return Population.population_total >= 200


func unlock() -> void:
	GlobalSignals.unlock_job.emit(Enums.jobs.CLOTHESMAKING)
	GlobalSignals.unlock_resource.emit(Enums.resource_types.CLOTHES)


func _ready() -> void:
	description_1 = "Reach 200 population"
	description_2 = "Making clothes"
