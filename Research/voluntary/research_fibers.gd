extends AbstractVoluntaryResearch
class_name ResearchFibers


func _ready():
	base_research_cost = {
		Enums.resource_types.TEXTILES: 20,
		Enums.resource_types.CULTURE: 50,
	}
	base_success_chance = 10
	research_type = Enums.research_type.FIBERS
	description = "Figure out how to make textiles out of fibers \nGathering/Farming also produces textiles"
	super._ready()


func finish_success():
	GlobalSignals.research_job_change.emit(
		Enums.jobs.GATHERING, {Enums.research_job_changes.CHANGE_OUTPUT: {Enums.resource_types.TEXTILES: 0.4}}
	)
