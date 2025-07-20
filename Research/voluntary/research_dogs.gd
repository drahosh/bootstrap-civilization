extends AbstractVoluntaryResearch
class_name ResearchDogs


func _ready():
	base_research_cost = {
		Enums.resource_types.FOOD: 1000,
		Enums.resource_types.CULTURE: 200,
	}
	base_success_chance = 5
	research_type = Enums.research_type.DOGS
	description = "Domesticate dogs\n halve hunting capacity but double output"
	super._ready()


func finish_success():
	GlobalSignals.research_job_change.emit(
		Enums.jobs.HUNTING,
		{Enums.research_job_changes.CAPACITY_MULTIPLIER: 0.5, Enums.research_job_changes.OUTPUT_MULTIPLIER: 2}
	)
	GlobalSignals.unlock_research.emit(Enums.research_type.BIRDS)
