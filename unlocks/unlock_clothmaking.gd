extends AbstractUnlock

class_name UnlockClothmaking


func checkVisible() -> bool:
	return true


func checkUnlock() -> bool:
	return Population.get_population_total() >= 500


func unlock() -> void:
	GlobalSignals.unlock_job.emit(Enums.jobs.CLOTHMAKING)
	GlobalSignals.unlock_resource.emit(Enums.resource_types.CLOTHES)


func _ready() -> void:
	description_1 = "Reach 500 population"
	description_2 = "Clothmaking"
