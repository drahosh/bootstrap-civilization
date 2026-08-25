extends AbstractVoluntaryResearch
class_name ResearchGranary


func _ready():
	base_research_cost = {
		Enums.resource_types.KNOWLEDGE: 000,
		Enums.resource_types.MATERIALS: 100,
		Enums.resource_types.FOOD: 100,
	}
	base_success_chance = 10
	research_type = Enums.research_type.GRANARY
	description = "Find a way to store food without decay, for up to 7x max population this run"
	super._ready()


func finish_success():
	Resources.granary_enabled = true
