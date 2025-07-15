extends AbstractVoluntaryResearch
class_name ResearchBones


func _ready():
	base_research_cost = {
		Enums.resource_types.TOOLS: 20,
		Enums.resource_types.CULTURE: 50,
	}
	base_success_chance = 20
	research_type = Enums.research_type.BONES
	description = "Use bone tools\n hunting will produce materials"
	super._ready()


func finish_success():
	GlobalSignals.research_job_change.emit(
		Enums.jobs.HUNTING, {Enums.research_job_changes.CHANGE_OUTPUT: {Enums.resource_types.MATERIALS: 0.3}}
	)
