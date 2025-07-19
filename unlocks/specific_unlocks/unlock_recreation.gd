extends AbstractUnlock

class_name UnlockRecreation


func checkVisible() -> bool:
	return Population.population_total >= 200


func checkUnlock() -> bool:
	return Population.population_total >= 500


func unlock() -> void:
	GlobalSignals.unlock_job.emit(Enums.jobs.RECREATION)
	GlobalSignals.unlock_resource.emit(Enums.resource_types.CULTURE)


func _ready() -> void:
	if PrestigeData.prestige_upgrades[Enums.prestige_upgrades.REMOVE_RECREATION].enabled:
		unlock_state = Enums.unlock_state.UNLOCKED
		# setting this without using unlock function practically removes the unlock
	description_1 = "Reach 500 population"
	description_2 = "Recreation"
