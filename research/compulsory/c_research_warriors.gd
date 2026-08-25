extends AbstractCompulsoryResearch
class_name CResearchWarriors


func _ready():
	base_delay_cost = {Enums.resource_types.CULTURE: 200}

	super._ready()
