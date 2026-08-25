extends AbstractVoluntaryResearch
class_name ResearchCats


func _ready():
	base_research_cost = {
		Enums.resource_types.FOOD: 1000,
		Enums.resource_types.CULTURE: 1000,
	}
	base_success_chance = 1
	research_type = Enums.research_type.CATS
	description = "Domesticate cats\n They catch vermin, increasing farming output by 20%"
	super._ready()


func finish_success():
	GlobalSignals.research_job_change.emit(Enums.jobs.FARMING, {Enums.research_job_changes.OUTPUT_MULTIPLIER: 1.2})
