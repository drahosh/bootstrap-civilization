extends AbstractVoluntaryResearch

class_name ResearchWoodcutting


func _ready():
	base_research_cost = {
		Enums.resource_types.MATERIALS: 20,
		Enums.resource_types.TOOLS: 50,
	}
	base_success_chance = 20
	research_type = Enums.research_type.WOODCUTTING
	description = "Use tools to cut trees, gaining materials"
	super._ready()


func finish_success():
	GlobalSignals.unlock_job.emit(Enums.jobs.WOODCUTTING)
