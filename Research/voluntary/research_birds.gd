extends AbstractVoluntaryResearch
class_name ResearchBirds


func _ready():
	base_research_cost = {
		Enums.resource_types.TOOLS: 500,
		Enums.resource_types.FOOD: 5000,
	}
	base_success_chance = 2
	research_type = Enums.research_type.BIRDS
	description = "Domesticate birds\n increase hunting output by a quarter"
	super._ready()


func finish_success():
	GlobalSignals.research_job_change.emit(Enums.jobs.HUNTING, {Enums.research_job_changes.OUTPUT_MULTIPLIER: 1.25})
